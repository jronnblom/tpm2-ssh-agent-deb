# ssh-tpm-agent Debian Packaging (Ubuntu 24.04)

This repo builds a `.deb` package for [ssh-tpm-agent](https://github.com/Foxboron/ssh-tpm-agent) using either:

- Docker ✅ (isolated and reproducible)
- Native Ubuntu 24.04 system ✅

Warning: This probably builds the latest version and not the 0.8.0.
Tested on MacOS.

---

## 🔧 Building with Docker

### 1. Build the image:

```bash
docker build -t ssh-tpm-agent-deb .

