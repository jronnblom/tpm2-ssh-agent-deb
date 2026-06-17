#!/usr/bin/env bash
set -euo pipefail

api_url="https://api.github.com/repos/Foxboron/ssh-tpm-agent/releases/latest"
fallback_url="https://github.com/Foxboron/ssh-tpm-agent/releases/latest"

tag_name=""

if response="$(curl -fsSL \
  -H 'Accept: application/vnd.github+json' \
  -H 'User-Agent: tpm2-ssh-agent-deb-build' \
  "$api_url" 2>/dev/null)"; then
  tag_name="$(printf '%s' "$response" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("tag_name",""))')"
fi

if [[ -z "$tag_name" || "$tag_name" == "null" ]]; then
  redirect_url="$(curl -fsSLI -o /dev/null -w '%{url_effective}' "$fallback_url" 2>/dev/null || true)"
  tag_name="${redirect_url##*/}"
fi

if [[ -z "$tag_name" || "$tag_name" == "null" ]]; then
  echo "Latest release tag is empty" >&2
  exit 1
fi

printf '%s\n' "$tag_name"
