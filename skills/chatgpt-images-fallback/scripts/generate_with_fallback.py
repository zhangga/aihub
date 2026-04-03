#!/usr/bin/env python3
import argparse
import base64
import json
import os
import shutil
import sys
import urllib.error
import urllib.request
from datetime import datetime
from pathlib import Path


QUOTA_MARKERS = [
    "quota exceeded",
    "insufficient credits",
    "resource_exhausted",
    "generate_content_free_tier_requests",
    "generate_content_free_tier_input_token_count",
    "check your plan and billing details",
]


def read_prompt(args):
    if args.prompt_text:
        return args.prompt_text
    if args.prompt_file:
        return Path(args.prompt_file).read_text(encoding="utf-8").strip()
    raise ValueError("One of --prompt-text or --prompt-file is required.")


def classify_error(text):
    lowered = (text or "").lower()
    for marker in QUOTA_MARKERS:
        if marker in lowered:
            return "quota_exhausted"
    return "other"


def backup_existing(path):
    if not path.exists():
        return None
    ts = datetime.now().strftime("%Y%m%d-%H%M%S")
    backup = path.with_name(f"{path.stem}-backup-{ts}{path.suffix}")
    shutil.move(str(path), str(backup))
    return str(backup)


def save_bytes(data, output_dir, filename):
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    target = output_dir / filename
    backup = backup_existing(target)
    target.write_bytes(data)
    return str(target), backup


def call_google_gemini(prompt, api_key, model, aspect_ratio):
    url = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent"
    payload = {
        "contents": [{"parts": [{"text": prompt}]}],
        "generationConfig": {
            "responseModalities": ["IMAGE"],
            "imageConfig": {"aspectRatio": aspect_ratio},
        },
    }
    body = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        url,
        data=body,
        method="POST",
        headers={
            "Content-Type": "application/json; charset=utf-8",
            "x-goog-api-key": api_key,
        },
    )
    try:
        with urllib.request.urlopen(req, timeout=120) as resp:
            return json.loads(resp.read().decode("utf-8")), None
    except urllib.error.HTTPError as exc:
        text = exc.read().decode("utf-8", errors="replace")
        return None, text
    except Exception as exc:
        return None, str(exc)


def emit(payload):
    print(json.dumps(payload, ensure_ascii=False, indent=2))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--prompt-text")
    parser.add_argument("--prompt-file")
    parser.add_argument("--output-dir", required=True)
    parser.add_argument("--filename", required=True)
    parser.add_argument("--primary", default="google-gemini")
    parser.add_argument("--google-api-key-env", default="GOOGLE_API_KEY")
    parser.add_argument("--google-model", default="gemini-3.1-flash-image-preview")
    parser.add_argument("--aspect-ratio", default="16:9")
    args = parser.parse_args()

    prompt = read_prompt(args)
    result = {
        "status": "error",
        "primary": args.primary,
        "prompt": prompt,
        "output_dir": args.output_dir,
        "filename": args.filename,
    }

    if args.primary != "google-gemini":
        result["error_class"] = "unsupported_primary"
        result["message"] = f"Unsupported primary provider: {args.primary}"
        emit(result)
        sys.exit(1)

    api_key = os.environ.get(args.google_api_key_env, "").strip()
    if not api_key:
        result["error_class"] = "missing_api_key"
        result["message"] = f"Environment variable {args.google_api_key_env} is not set."
        emit(result)
        sys.exit(1)

    response, error_text = call_google_gemini(prompt, api_key, args.google_model, args.aspect_ratio)
    if error_text:
        error_class = classify_error(error_text)
        if error_class == "quota_exhausted":
            result["status"] = "needs_chatgpt_fallback"
            result["error_class"] = error_class
            result["message"] = error_text
            result["chatgpt_images_url"] = "https://chatgpt.com/images"
            emit(result)
            sys.exit(2)
        result["error_class"] = error_class
        result["message"] = error_text
        emit(result)
        sys.exit(1)

    parts = (((response or {}).get("candidates") or [{}])[0].get("content") or {}).get("parts") or []
    inline = next((part.get("inlineData") for part in parts if part.get("inlineData")), None)
    if not inline or "data" not in inline:
        result["error_class"] = "no_image_returned"
        result["message"] = json.dumps(response, ensure_ascii=False)
        emit(result)
        sys.exit(1)

    image_bytes = base64.b64decode(inline["data"])
    saved_path, backup = save_bytes(image_bytes, args.output_dir, args.filename)
    result["status"] = "saved"
    result["saved_path"] = saved_path
    result["backup_path"] = backup
    emit(result)


if __name__ == "__main__":
    main()
