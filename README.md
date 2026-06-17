# ssh-tpm-agent Debian Packaging

This repository builds `.deb` packages for [ssh-tpm-agent](https://github.com/Foxboron/ssh-tpm-agent) for multiple Ubuntu versions.

## Supported build targets

`versions.conf` is the single source of truth for build targets:

```ini
# ubuntu_version go_version
24.04 1.23.0
26.04 bundled
```

- `go_version=bundled` uses the distro-provided Go.
- Any explicit Go version downloads from `https://go.dev/dl/` inside the container.

## Build locally

Build all configured targets and collect `.deb` files in `output/`:

```bash
./scripts/build.sh
```

The build script resolves the latest upstream release tag from:

- `https://github.com/Foxboron/ssh-tpm-agent/releases`

## Build a single target manually

```bash
docker build \
  --build-arg UBUNTU_VERSION=24.04 \
  --build-arg GO_VERSION=1.23.0 \
  --build-arg SSH_TPM_AGENT_VERSION="$(./scripts/get-latest-version.sh)" \
  -t ssh-tpm-agent-deb:24.04 .
```

## CI/CD

GitHub Actions workflow `.github/workflows/build.yml`:

- Builds packages for every target in `versions.conf`
- Uploads artifacts from each matrix job
- Publishes `.deb` files as assets on the upstream release tag
