# Kaggle compute node

Use Kaggle for the heavy run, not for primary code editing.

## Fast workflow

1. Develop and smoke-test in Codespaces.
2. Commit/push code to GitHub.
3. In Kaggle, add a **de-identified** dataset.
4. Copy or sync the relevant script, then run:

```bash
python kaggle/run_heavy.py \
  --input /kaggle/input/YOUR_DATASET/analysis.csv \
  --bootstrap 2000
```

5. Download only derived outputs from `/kaggle/working/results/`.

## Data rule

Never upload names, national IDs, phone numbers, medical-record numbers, addresses, or direct patient identifiers. Keep the re-identification key inside the approved institutional environment.

## Compute rule

Use CPU for Cox models, classical statistics, PCA, ordinary tree models and most bootstrap validation. Turn on GPU only for workloads that actually support GPU acceleration.
