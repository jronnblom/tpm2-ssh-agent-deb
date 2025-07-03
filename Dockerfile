# Use Ubuntu 24.04 as the base image
FROM ubuntu:24.04

# Set non-interactive mode for apt
ENV DEBIAN_FRONTEND=noninteractive

# Install required build tools and dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    git \
    devscripts \
    dh-make \
    debhelper \
    dh-golang \
    fakeroot \
    lintian \
    tar \
    xz-utils \
    curl \
    unzip \
    libssl-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.23+ manually (Ubuntu 24.04 only ships with 1.22)
ENV GO_VERSION=1.23.0
RUN curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" -o go.tar.gz && \
    rm -rf /usr/local/go && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz

# Set Go environment paths and create symlinks
ENV PATH="/usr/local/go/bin:$PATH"
ENV GOROOT="/usr/local/go"
ENV DH_GOLANG_GO="/usr/local/go/bin/go"
ENV DH_GOPKG="github.com/Foxboron/ssh-tpm-agent"

# Make Go available in system PATH
RUN ln -s /usr/local/go/bin/go /usr/local/bin/go && \
    ln -s /usr/local/go/bin/gofmt /usr/local/bin/gofmt

# Create a build user and switch to it
RUN useradd -m builder
WORKDIR /home/builder
USER builder

# Clone the ssh-tpm-agent source
RUN git clone https://github.com/Foxboron/ssh-tpm-agent.git
WORKDIR /home/builder/ssh-tpm-agent

# Patch go.mod if necessary (normally not needed anymore)
RUN go mod tidy

# Copy your prepared debian/ directory (assuming you have it ready)
COPY --chown=builder:builder debian ./debian

# 
RUN /usr/local/go/bin/go mod download

# Build the Debian package
RUN PATH="/usr/local/go/bin:$PATH" debuild -us -uc

# Final output step (optional, to extract .deb from the container)  
USER root
RUN mkdir -p /output
USER builder
CMD ["bash", "-c", "cp ../*.deb /output && ls -lh ../*.deb"]

