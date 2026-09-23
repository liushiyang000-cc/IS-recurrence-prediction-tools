# Kaggle compute node

Use Kaggle for heavy computation, not as the primary code-editing environment.

## First validation

Kaggle uses separate Python and R notebook languages. Test them separately:

1. Create a **Python** notebook, set **Internet = On**, **Accelerator = None**, and use `01_kaggle_smoke_test.ipynb`.
2. Create an **R** notebook, set **Internet = On**, **Accelerator = None**, and use `02_kaggle_r_smoke_test.ipynb`.
3. Both notebooks clone the protected `cloud-research-setup` branch and use synthetic data only.
4. Only after both tests pass should real de-identified analysis data be attached.

## Heavy Python run

After validation:

```bash
python kaggle/run_heavy.py \
  --input /kaggle/input/YOUR_DATASET/analysis.csv \
  --bootstrap 2000
```

Derived outputs are written under `/kaggle/working/results/`.

## Data rule

Never upload names, national IDs, phone numbers, medical-record numbers, addresses, or direct patient identifiers. Keep the re-identification key inside the approved institutional environment.

## Compute rule

Use CPU for Cox models, classical statistics, PCA, ordinary tree models, and most bootstrap validation. Enable a GPU only for code that actually uses GPU acceleration.

## Scientific scope

The current `run_heavy.py` is an infrastructure smoke-test worker. Its test AUC is not a manuscript result. The validated RIS Cox/C-index/calibration/Brier/time-dependent AUC/DCA pipeline must replace it before scientific use.
