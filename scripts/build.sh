#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
versions_file="$repo_root/versions.conf"
out_dir="$repo_root/output"

if [[ ! -f "$versions_file" ]]; then
  echo "Missing versions file: $versions_file" >&2
  exit 1
fi

latest_tag="$($repo_root/scripts/get-latest-version.sh)"
mkdir -p "$out_dir"

while read -r ubuntu_version go_version _; do
  [[ -z "${ubuntu_version:-}" || "${ubuntu_version:0:1}" == "#" ]] && continue

  image_tag="ssh-tpm-agent-deb:${ubuntu_version}"
  container_name="ssh-tpm-agent-deb-${ubuntu_version//./-}"

  echo "Building Ubuntu ${ubuntu_version} (go=${go_version}, source=${latest_tag})"

  docker build \
    --build-arg UBUNTU_VERSION="$ubuntu_version" \
    --build-arg GO_VERSION="$go_version" \
    --build-arg SSH_TPM_AGENT_VERSION="$latest_tag" \
    -t "$image_tag" \
    "$repo_root"

  docker rm -f "$container_name" >/dev/null 2>&1 || true
  docker create --name "$container_name" "$image_tag" >/dev/null
  docker cp "$container_name:/output/." "$out_dir/"
  docker rm -f "$container_name" >/dev/null

done < "$versions_file"

echo "Packages written to $out_dir"
ls -lh "$out_dir"/*.deb
