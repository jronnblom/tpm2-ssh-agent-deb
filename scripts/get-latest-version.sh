#!/usr/bin/env bash
set -euo pipefail

api_url="https://api.github.com/repos/Foxboron/ssh-tpm-agent/releases/latest"

if ! tag_name="$(curl -fsSL "$api_url" | python3 -c 'import json,sys; print(json.load(sys.stdin)["tag_name"])')"; then
  echo "Failed to resolve latest release tag" >&2
  exit 1
fi

if [[ -z "$tag_name" || "$tag_name" == "null" ]]; then
  echo "Latest release tag is empty" >&2
  exit 1
fi

printf '%s\n' "$tag_name"
