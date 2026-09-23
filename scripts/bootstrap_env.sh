#!/usr/bin/env bash
set -euo pipefail

python --version
Rscript --version

python - <<'PY'
import numpy
import pandas
import scipy
import sklearn
import lifelines
import statsmodels
import matplotlib
import pyarrow
import openpyxl
import joblib
print("PASS: Python research packages import")
PY

Rscript -e 'pkgs <- c("survival","boot","ggplot2","data.table","readr","dplyr"); stopifnot(all(vapply(pkgs, requireNamespace, logical(1), quietly=TRUE))); cat("PASS: R research packages import\n")'

mkdir -p data/private data/processed results checkpoints
echo "Codespaces environment ready."
