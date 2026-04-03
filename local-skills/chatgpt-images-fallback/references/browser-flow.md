# Browser Fallback Flow

Use this flow only after `generate_with_fallback.py` returns `needs_chatgpt_fallback`.
For repeated or batch work, prefer `scripts/run_chatgpt_fallback.mjs`.

## Site

- URL: `https://chatgpt.com/images`
- Requirement: the user must already be logged in
- Recommendation: reuse the same browser profile so the login session survives later runs

## Steps

1. Open `https://chatgpt.com/images`
2. Focus the main prompt box
3. Paste the exact prompt returned by the primary script
4. Submit generation
5. Wait until the first result is visible and downloadable
6. Download the first result only
7. Pass the downloaded file into `scripts/finalize_download.py`

## Download Rule

- Always take the first generated image unless the user explicitly asked to review options.
- Save the browser download anywhere convenient first.
- The final canonical path is produced by `finalize_download.py`.

## Rename Rule

- The target filename comes from the caller, not from the website.
- If the target file already exists, keep a timestamped backup and write the new file to the requested name.

## Non-Goals

- Do not use this flow for editing an existing image.
- Do not use this flow for choosing among multiple candidates unless the user asks.
- Do not silently change the prompt during fallback.
