FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

COPY requirements-cloud.txt /tmp/requirements-cloud.txt

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    python3 python3-pip python3-venv \
    r-base r-base-dev \
    r-cran-survival r-cran-boot r-cran-ggplot2 r-cran-data.table r-cran-readr r-cran-dplyr \
    build-essential git curl \
    libcurl4-openssl-dev libssl-dev libxml2-dev \
    && python3 -m venv /opt/ris-venv \
    && /opt/ris-venv/bin/python -m pip install --upgrade pip \
    && /opt/ris-venv/bin/pip install -r /tmp/requirements-cloud.txt \
    && rm -rf /var/lib/apt/lists/* /root/.cache/pip /tmp/requirements-cloud.txt

ENV PATH="/opt/ris-venv/bin:${PATH}"
