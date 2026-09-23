# RIS Cloud Research Workflow

This repository is configured for a two-node workflow:

**GitHub Codespaces = development/control plane**  
**Kaggle = heavy-compute plane**

## Codespaces

Open the repository in Codespaces. The devcontainer installs Python, R, Jupyter and common survival/data-analysis packages.

Recommended cycle:

1. Edit code in Codespaces.
2. Test on a small/de-identified sample.
3. Commit a reproducible version.
4. Move only de-identified analysis data to Kaggle.
5. Run the large bootstrap/modeling job in Kaggle.
6. Return derived CSV/figures/model summaries to the project.

## Suggested repository layout

```
R/                  R analysis code
scripts/            utility/bootstrap scripts
kaggle/             heavy-compute entry points
data/private/       local only; gitignored
data/processed/     analysis-ready data; avoid committing patient data
checkpoints/        restartable computation checkpoints
results/            derived outputs
```

## Resource strategy

Codespaces: code, debugging, Git, R/Python/Jupyter, small tests.  
Kaggle: long bootstrap runs, larger matrices, ML training, GPU-capable jobs.

Do not waste Kaggle GPU quota on standard Cox regression or ordinary statistical analysis.

## Immediate next milestone

Replace the generic `kaggle/run_heavy.py` example with the project's validated RIS prediction pipeline (Cox/C-index/calibration/Brier/time-dependent AUC/DCA) after the statistical reference implementation is locked.
