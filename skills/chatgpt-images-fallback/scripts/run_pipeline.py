#!/usr/bin/env python3
import argparse
import json
import subprocess
import sys
from pathlib import Path


def run(cmd, cwd):
    return subprocess.run(cmd, cwd=cwd, capture_output=True, text=True)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--jobs-file", required=True)
    parser.add_argument("--fallback-manifest", required=True)
    parser.add_argument("--chatgpt-results", required=True)
    parser.add_argument("--profile-dir")
    parser.add_argument("--wait-ms", type=int, default=240000)
    parser.add_argument("--skip-chatgpt-fallback", action="store_true")
    args = parser.parse_args()

    jobs_file = str(Path(args.jobs_file).resolve())
    fallback_manifest = str(Path(args.fallback_manifest).resolve())
    chatgpt_results = str(Path(args.chatgpt_results).resolve())
    profile_dir = str(Path(args.profile_dir).resolve()) if args.profile_dir else None

    scripts_dir = Path(__file__).resolve().parent
    run_jobs = scripts_dir / "run_jobs.py"
    run_fallback = scripts_dir / "run_chatgpt_fallback.mjs"

    jobs_proc = run([
        sys.executable,
        str(run_jobs),
        "--jobs-file", jobs_file,
        "--fallback-manifest", fallback_manifest,
    ], cwd=str(scripts_dir))
    if jobs_proc.returncode != 0:
        print(jobs_proc.stdout or jobs_proc.stderr)
        raise SystemExit(jobs_proc.returncode)

    jobs_result = json.loads(jobs_proc.stdout)
    if jobs_result.get("fallback_count", 0) == 0 or args.skip_chatgpt_fallback:
        print(json.dumps({
            "status": "ok",
            "jobs_result": jobs_result,
            "chatgpt_fallback_skipped": args.skip_chatgpt_fallback,
        }, ensure_ascii=False, indent=2))
        return

    cmd = [
        "node",
        str(run_fallback),
        "--manifest", fallback_manifest,
        "--manifest-out", chatgpt_results,
        "--wait-ms", str(args.wait_ms),
    ]
    if profile_dir:
        cmd.extend(["--profile-dir", profile_dir])

    fallback_proc = run(cmd, cwd=str(scripts_dir))
    if fallback_proc.returncode != 0:
        print(fallback_proc.stdout or fallback_proc.stderr)
        raise SystemExit(fallback_proc.returncode)

    fallback_result = json.loads(fallback_proc.stdout)
    print(json.dumps({
        "status": "ok",
        "jobs_result": jobs_result,
        "fallback_result": fallback_result,
    }, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
