#!/usr/bin/env node
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import { chromium } from "playwright";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

function parseArgs(argv) {
  const out = {
    profileDir: path.join(os.homedir(), ".chatgpt-images-fallback-profile"),
    manifestOut: "",
    waitMs: 240000,
    headed: true,
  };
  for (let i = 2; i < argv.length; i += 1) {
    const arg = argv[i];
    const next = argv[i + 1];
    if (arg === "--manifest") out.manifest = next, i += 1;
    else if (arg === "--profile-dir") out.profileDir = next, i += 1;
    else if (arg === "--manifest-out") out.manifestOut = next, i += 1;
    else if (arg === "--wait-ms") out.waitMs = Number(next), i += 1;
    else if (arg === "--headless") out.headed = false;
    else if (arg === "--headed") out.headed = true;
  }
  if (!out.manifest) {
    throw new Error("--manifest is required");
  }
  return out;
}

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function writeJson(filePath, data) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, `${JSON.stringify(data, null, 2)}\n`, "utf8");
}

async function waitForPromptInput(page, waitMs) {
  const selectors = [
    "textarea",
    '[contenteditable="true"]',
    "#prompt-textarea",
  ];
  const deadline = Date.now() + waitMs;
  while (Date.now() < deadline) {
    for (const selector of selectors) {
      const locator = page.locator(selector).first();
      if (await locator.count()) {
        try {
          await locator.waitFor({ state: "visible", timeout: 1000 });
          return { locator, selector };
        } catch {}
      }
    }
    const url = page.url();
    const bodyText = await page.locator("body").innerText().catch(() => "");
    if (url.includes("/auth/error") || bodyText.includes("Log in") || bodyText.includes("Sign up")) {
      console.log("Waiting for manual login or Cloudflare verification in ChatGPT...");
    }
    await page.waitForTimeout(1500);
  }
  throw new Error("Prompt input not found. Ensure chatgpt.com/images is open and logged in.");
}

async function setPrompt(input, text) {
  await input.click();
  await input.press("Control+A").catch(() => {});
  await input.press("Meta+A").catch(() => {});
  await input.press("Backspace").catch(() => {});
  try {
    await input.fill(text);
  } catch {
    await input.type(text, { delay: 5 });
  }
}

async function submitPrompt(page, input) {
  const buttonSelectors = [
    'button[data-testid="send-button"]',
    'button[aria-label*="Send"]',
    'form button[type="submit"]',
  ];
  for (const selector of buttonSelectors) {
    const button = page.locator(selector).first();
    if (await button.count()) {
      try {
        await button.click({ timeout: 1000 });
        return;
      } catch {}
    }
  }
  await input.press("Enter");
}

async function collectCandidateImages(page) {
  return await page.evaluate(() => {
    const visible = (el) => {
      const style = window.getComputedStyle(el);
      const rect = el.getBoundingClientRect();
      return style.visibility !== "hidden" && style.display !== "none" && rect.width > 180 && rect.height > 180;
    };
    return Array.from(document.images)
      .filter((img) => visible(img))
      .map((img) => {
        const rect = img.getBoundingClientRect();
        return {
          src: img.currentSrc || img.src,
          width: img.naturalWidth || rect.width,
          height: img.naturalHeight || rect.height,
          area: (img.naturalWidth || rect.width) * (img.naturalHeight || rect.height),
          alt: img.alt || "",
          y: rect.top,
        };
      })
      .filter((img) => img.src && img.area > 120000)
      .sort((a, b) => b.area - a.area || a.y - b.y);
  });
}

async function waitForFirstGeneratedImage(page, baselineSrcs, waitMs) {
  const deadline = Date.now() + waitMs;
  while (Date.now() < deadline) {
    const images = await collectCandidateImages(page);
    const fresh = images.find((img) => !baselineSrcs.has(img.src));
    if (fresh) {
      return fresh;
    }
    if (images.length > 0 && baselineSrcs.size === 0) {
      return images[0];
    }
    await page.waitForTimeout(2000);
  }
  throw new Error("Timed out waiting for generated image.");
}

async function fetchImageToTemp(page, src, stem) {
  const result = await page.evaluate(async (imageSrc) => {
    const response = await fetch(imageSrc);
    const blob = await response.blob();
    const buffer = await blob.arrayBuffer();
    let binary = "";
    const bytes = new Uint8Array(buffer);
    for (let i = 0; i < bytes.length; i += 1) {
      binary += String.fromCharCode(bytes[i]);
    }
    return {
      mime: blob.type || "image/png",
      base64: btoa(binary),
    };
  }, src);
  const ext = result.mime.includes("jpeg") ? ".jpg" : result.mime.includes("webp") ? ".webp" : ".png";
  const tempPath = path.join(os.tmpdir(), `${stem}-${Date.now()}${ext}`);
  fs.writeFileSync(tempPath, Buffer.from(result.base64, "base64"));
  return tempPath;
}

function finalizeDownload(tempPath, job) {
  const script = path.join(__dirname, "finalize_download.py");
  const proc = spawnSync("python", [
    script,
    "--downloaded-file", tempPath,
    "--output-dir", job.output_dir,
    "--filename", job.filename,
  ], {
    encoding: "utf8",
  });
  if (proc.status !== 0) {
    throw new Error(proc.stdout || proc.stderr || "finalize_download.py failed");
  }
  return JSON.parse(proc.stdout);
}

async function runJob(page, job, waitMs) {
  const prompt = (job.result?.prompt || job.job?.prompt_text || "").trim();
  if (!prompt) {
    throw new Error("Fallback job is missing prompt text.");
  }

  await page.goto("https://chatgpt.com/images", { waitUntil: "domcontentloaded" });
  const { locator } = await waitForPromptInput(page, waitMs);
  const baseline = await collectCandidateImages(page);
  const baselineSrcs = new Set(baseline.map((img) => img.src));
  await setPrompt(locator, prompt);
  await submitPrompt(page, locator);
  const firstImage = await waitForFirstGeneratedImage(page, baselineSrcs, waitMs);
  const tempPath = await fetchImageToTemp(page, firstImage.src, job.job?.name || "chatgpt-image");
  const finalized = finalizeDownload(tempPath, job.job);
  return {
    image_src: firstImage.src,
    temp_path: tempPath,
    finalized,
  };
}

async function main() {
  const args = parseArgs(process.argv);
  const manifest = readJson(args.manifest);
  const fallbackJobs = manifest.fallback_jobs || [];
  const completed = [];
  const failed = [];

  if (fallbackJobs.length === 0) {
    const out = {
      status: "ok",
      message: "No fallback jobs to process.",
      completed_count: 0,
      failed_count: 0,
    };
    console.log(JSON.stringify(out, null, 2));
    if (args.manifestOut) writeJson(args.manifestOut, out);
    return;
  }

  const context = await chromium.launchPersistentContext(args.profileDir, {
    channel: "chrome",
    headless: !args.headed,
    viewport: { width: 1440, height: 980 },
  });
  const page = context.pages()[0] || await context.newPage();

  try {
    for (const job of fallbackJobs) {
      try {
        const result = await runJob(page, job, args.waitMs);
        completed.push({ job, result });
      } catch (error) {
        failed.push({
          job,
          error: String(error?.message || error),
        });
      }
    }
  } finally {
    await context.close();
  }

  const out = {
    status: failed.length ? "partial" : "ok",
    completed_count: completed.length,
    failed_count: failed.length,
    completed,
    failed,
  };
  console.log(JSON.stringify(out, null, 2));
  if (args.manifestOut) writeJson(args.manifestOut, out);
}

main().catch((error) => {
  console.error(JSON.stringify({
    status: "error",
    message: String(error?.message || error),
  }, null, 2));
  process.exit(1);
});
