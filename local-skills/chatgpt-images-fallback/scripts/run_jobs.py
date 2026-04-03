#!/usr/bin/env python3
import argparse
import json
import subprocess
import sys
from pathlib import Path


def run_job(script_path, job):
    cmd = [
        sys.executable,
        str(script_path),
        "--output-dir",
        job["output_dir"],
        "--filename",
        job["filename"],
        "--primary",
        job.get("primary", "google-gemini"),
    ]
    if job.get("google_api_key_env"):
        cmd.extend(["--google-api-key-env", job["google_api_key_env"]])
    if job.get("google_model"):
        cmd.extend(["--google-model", job["google_model"]])
    if job.get("aspect_ratio"):
        cmd.extend(["--aspect-ratio", job["aspect_ratio"]])
    if job.get("prompt_file"):
        cmd.extend(["--prompt-file", job["prompt_file"]])
    elif job.get("prompt_text"):
        cmd.extend(["--prompt-text", job["prompt_text"]])
    else:
        raise ValueError(f"Job missing prompt: {job}")

    proc = subprocess.run(cmd, capture_output=True, text=True, cwd=str(script_path.parent))
    payload = {
        "returncode": proc.returncode,
        "stdout": proc.stdout,
        "stderr": proc.stderr,
        "job": job,
    }
    try:
        payload["result"] = json.loads(proc.stdout) if proc.stdout.strip() else None
    except Exception:
        payload["result"] = None
    return payload


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--jobs-file", required=True)
    parser.add_argument("--fallback-manifest", required=True)
    args = parser.parse_args()

    jobs_file = Path(args.jobs_file).resolve()
    manifest_path = Path(args.fallback_manifest).resolve()

    jobs = json.loads(jobs_file.read_text(encoding="utf-8-sig"))
    if not isinstance(jobs, list):
        raise SystemExit("jobs-file must contain a JSON array")

    script_path = Path(__file__).with_name("generate_with_fallback.py")
    saved = []
    fallback = []
    failed = []

    for job in jobs:
        outcome = run_job(script_path, job)
        result = outcome.get("result") or {}
        status = result.get("status")
        if status == "saved":
            saved.append({"job": job, "result": result})
        elif status == "needs_chatgpt_fallback":
            fallback.append({"job": job, "result": result})
        else:
            failed.append(outcome)

    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    manifest = {
        "fallback_jobs": fallback,
        "saved_jobs": saved,
        "failed_jobs": failed,
    }
    manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps({
        "status": "ok",
        "saved_count": len(saved),
        "fallback_count": len(fallback),
        "failed_count": len(failed),
        "fallback_manifest": str(manifest_path),
    }, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
