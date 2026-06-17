ARG UBUNTU_VERSION=24.04
FROM ubuntu:${UBUNTU_VERSION}

ARG GO_VERSION=bundled
ARG SSH_TPM_AGENT_VERSION=latest

ENV DEBIAN_FRONTEND=noninteractive
ENV GO_VERSION=${GO_VERSION}
ENV SSH_TPM_AGENT_VERSION=${SSH_TPM_AGENT_VERSION}

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    debhelper \
    devscripts \
    dh-golang \
    fakeroot \
    git \
    golang-go \
    lintian \
    pkg-config \
    unzip \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

RUN if [ "$GO_VERSION" != "bundled" ]; then \
      (curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" -o go.tar.gz || \
       curl -fsSL "https://storage.googleapis.com/golang/go${GO_VERSION}.linux-amd64.tar.gz" -o go.tar.gz) && \
      rm -rf /usr/local/go && \
      tar -C /usr/local -xzf go.tar.gz && \
      rm go.tar.gz; \
    fi

ENV PATH="/usr/local/go/bin:${PATH}"
ENV GO111MODULE=on
ENV GOPROXY="https://proxy.golang.org,direct"
ENV DH_GOPKG="github.com/Foxboron/ssh-tpm-agent"

RUN useradd -m builder
WORKDIR /home/builder
USER builder

RUN git clone https://github.com/Foxboron/ssh-tpm-agent.git && \
    cd ssh-tpm-agent && \
    if [ "$SSH_TPM_AGENT_VERSION" = "latest" ]; then \
      SSH_TPM_AGENT_VERSION="$(git tag --sort=-version:refname | grep -E '^v?[0-9]' | head -n 1)"; \
    fi && \
    git checkout "$SSH_TPM_AGENT_VERSION" && \
    for i in 1 2 3 4 5; do go mod tidy && break || [ "$i" -eq 5 ]; sleep 2; done

WORKDIR /home/builder/ssh-tpm-agent
COPY --chown=builder:builder debian ./debian
RUN for i in 1 2 3 4 5; do go mod download && break || [ "$i" -eq 5 ]; sleep 2; done
RUN debuild -us -uc

USER root
RUN mkdir -p /output
USER builder
CMD ["bash", "-c", "cp ../*.deb /output && ls -lh ../*.deb"]
