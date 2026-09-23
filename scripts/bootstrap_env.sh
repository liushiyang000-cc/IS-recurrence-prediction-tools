#!/usr/bin/env bash
set -euo pipefail

python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
pip install -r requirements-cloud.txt

Rscript -e 'pkgs <- c("survival","boot","ggplot2","data.table","readr","dplyr"); miss <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly=TRUE)]; if(length(miss)) install.packages(miss, repos="https://cloud.r-project.org")'

mkdir -p data/private data/processed results checkpoints
echo "Codespaces environment ready."
