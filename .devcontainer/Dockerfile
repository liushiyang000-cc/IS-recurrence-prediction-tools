FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    python3 python3-pip python3-venv \
    r-base r-base-dev \
    build-essential git curl \
    libcurl4-openssl-dev libssl-dev libxml2-dev \
    && rm -rf /var/lib/apt/lists/*
