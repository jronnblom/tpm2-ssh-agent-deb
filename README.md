# ssh-tpm-agent Debian Packaging (Ubuntu 24.04)

This repo builds a `.deb` package for [ssh-tpm-agent](https://github.com/Foxboron/ssh-tpm-agent) using either:

- Docker ✅ (isolated and reproducible)
- Native Ubuntu 24.04 system ✅

---

## 🔧 Building with Docker

### 1. Build the image:

```bash
docker build -t ssh-tpm-agent-deb .

