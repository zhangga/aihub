---
name: chatgpt-images-fallback
description: Generate new images with a primary API first, then automatically fall back to https://chatgpt.com/images when the primary provider fails because image quota or credits are exhausted. Use when Codex needs to create a brand-new image file from a prompt for article illustrations, social post assets, cover images, or similar deliverables, and the result must be saved to a specific directory and filename. Do not use for editing existing images.
---

# ChatGPT Images Fallback

## Overview

Use this skill when a task needs a new image file at a known path, but API-based generation may fail because the provider has no remaining image quota. Keep the normal API-first path, and only use `chatgpt.com/images` as a fallback for quota-class failures.

## Setup

Install the browser dependency once before using website fallback:

```powershell
cd scripts
npm install
```

The browser fallback expects:
- a local Chrome installation
- a reusable ChatGPT login session
- write access to the target output directory

## Workflow Decision Tree

1. Collect:
   - prompt text or prompt file
   - output directory
   - target filename
   - primary provider settings
2. Run `scripts/generate_with_fallback.py` to try the primary provider.
3. If the script returns `saved`, stop and use the generated file.
4. If the script returns `needs_chatgpt_fallback`, open `https://chatgpt.com/images`.
5. Generate the image from the exact same prompt.
6. Download the first generated image.
7. Run `scripts/finalize_download.py` to move the downloaded file into the requested directory and rename it to the requested filename.
8. For batch fallback, prefer `scripts/run_chatgpt_fallback.mjs` over doing the website steps manually.

## Inputs

- `prompt_text` or `prompt_file`
- `output_dir`
- `filename`
- `primary_provider`
- `downloads_dir` when browser download automation is used

Default behavior:
- Fallback only for quota-like failures
- Download the first ChatGPT candidate
- Backup an existing target file before overwrite

## Primary Provider Step

Run:

```powershell
python scripts/generate_with_fallback.py `
  --prompt-file <path-or-omit> `
  --prompt-text <text-or-omit> `
  --output-dir <dir> `
  --filename <name> `
  --primary google-gemini
```

Interpret the JSON result:
- `status = "saved"`: primary generation succeeded
- `status = "needs_chatgpt_fallback"`: browser fallback is required
- `status = "error"`: do not fall back automatically unless the error class is quota-related

## ChatGPT Images Fallback Step

When fallback is required:

1. Open `https://chatgpt.com/images`
2. Ensure the user is logged in
3. Paste the exact prompt from the script result
4. Submit generation
5. Wait until the first result is visible and downloadable
6. Download the first result only
7. Finalize it with:

```powershell
python scripts/finalize_download.py `
  --downloaded-file <downloaded-image> `
  --output-dir <dir> `
  --filename <name>
```

Use the first generated image by default. Do not stop to ask the user to choose among multiple candidates unless the user explicitly asked to review options.

Detailed browser steps are in [references/browser-flow.md](references/browser-flow.md).

Batch browser fallback:

```powershell
cd scripts
npm install
node scripts/run_chatgpt_fallback.mjs `
  --manifest <fallback-manifest.json> `
  --manifest-out <chatgpt-results.json>
```

Full pipeline:

```powershell
cd scripts
python scripts/run_pipeline.py `
  --jobs-file <image-jobs.json> `
  --fallback-manifest <fallback-manifest.json> `
  --chatgpt-results <chatgpt-results.json>
```

## Error Handling

Only auto-fall back for quota-class failures such as:
- `quota exceeded`
- `insufficient credits`
- `RESOURCE_EXHAUSTED`
- provider-specific messages indicating exhausted paid or free tier image quota

Do not auto-fall back for:
- invalid prompt payloads
- authentication failures
- permission errors unrelated to quota
- file path mistakes
- network errors that look transient but not quota-related

## Scripts

- `scripts/generate_with_fallback.py`
  - tries the primary provider
  - classifies quota errors
  - saves a successful API result directly
  - returns a JSON payload for browser fallback when needed

- `scripts/finalize_download.py`
  - moves the downloaded browser image to the requested output path
  - backs up an existing target file before overwrite
  - emits JSON with the final saved path

- `scripts/run_jobs.py`
  - runs a batch of image jobs from a JSON file
  - saves successful primary generations immediately
  - writes a fallback manifest listing only the jobs that must be completed via `chatgpt.com/images`
  - is the preferred entry point for article and social-post image sets

- `scripts/run_chatgpt_fallback.mjs`
  - opens `chatgpt.com/images` in a persistent Chrome profile
  - waits for manual login if needed
  - generates each fallback image from the manifest
  - fetches the first generated image and finalizes it to the requested filename

- `scripts/run_pipeline.py`
  - runs the full sequence end to end
  - first executes `run_jobs.py`
  - then invokes browser fallback only when fallback jobs exist

## Notes

- This skill is for new image generation only.
- Keep prompt text identical between primary generation and ChatGPT fallback.
- Prefer PNG output when possible.
- If the generated website download filename is generic, rely on `finalize_download.py` for the final rename step.
- If `run_chatgpt_fallback.mjs` cannot find the prompt box, reuse the same profile directory after logging in manually once.
