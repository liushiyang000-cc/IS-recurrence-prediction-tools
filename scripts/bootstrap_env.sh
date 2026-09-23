#!/usr/bin/env bash
set -euo pipefail

# The image bakes the Python environment into /opt/ris-venv.
# Explicitly prepend it because login/user switching can reset PATH.
if [ -d /opt/ris-venv/bin ]; then
  export PATH="/opt/ris-venv/bin:${PATH}"
fi

PYTHON_BIN="$(command -v python || true)"
if [ -z "$PYTHON_BIN" ]; then
  PYTHON_BIN="$(command -v python3 || true)"
fi
if [ -z "$PYTHON_BIN" ]; then
  echo "ERROR: Python interpreter not found." >&2
  exit 1
fi

"$PYTHON_BIN" --version
Rscript --version

"$PYTHON_BIN" - <<'PY'
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
