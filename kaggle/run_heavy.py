"""Infrastructure smoke-test worker for Codespaces/Kaggle.

This file verifies that the cloud compute path, checkpointing, CSV I/O and
common Python ML dependencies work. It is NOT the validated RIS scientific
prediction pipeline and its metric must not be reported in a manuscript.
"""
from pathlib import Path
import argparse
import json
import time

import numpy as np
import pandas as pd
from sklearn.metrics import roc_auc_score
from sklearn.linear_model import LogisticRegression


def _rng_for_rep(seed: int, rep: int) -> np.random.Generator:
    """Deterministic RNG per replicate so resumed runs equal fresh runs."""
    return np.random.default_rng(np.random.SeedSequence([seed, rep]))


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--input", required=True)
    p.add_argument("--out", default="/kaggle/working/results")
    p.add_argument("--bootstrap", type=int, default=1000)
    p.add_argument("--seed", type=int, default=20260923)
    args = p.parse_args()

    if args.bootstrap < 1:
        raise ValueError("--bootstrap must be >= 1")

    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    checkpoint = out / "bootstrap_auc.csv"

    df = pd.read_csv(args.input)
    if "event" not in df.columns:
        raise ValueError("Input must contain binary outcome column: event")

    y_series = df["event"]
    if y_series.isna().any():
        raise ValueError("event contains missing values")
    unique = sorted(pd.unique(y_series))
    if len(unique) != 2 or not set(unique).issubset({0, 1}):
        raise ValueError("event must be binary and coded as 0/1")
    y = y_series.astype(int).to_numpy()

    X = df.drop(columns=["event"]).select_dtypes(include=[np.number]).copy()
    if X.shape[1] == 0:
        raise ValueError("No numeric predictors found")
    X = X.replace([np.inf, -np.inf], np.nan)
    X = X.fillna(X.median(numeric_only=True))
    if X.isna().any().any():
        raise ValueError("At least one numeric predictor is entirely missing")

    aucs = []
    done = 0
    if checkpoint.exists():
        prev = pd.read_csv(checkpoint)
        if "auc" not in prev.columns:
            raise ValueError("Checkpoint is invalid: missing auc column")
        aucs = prev["auc"].astype(float).tolist()
        done = len(aucs)
        if done > args.bootstrap:
            aucs = aucs[: args.bootstrap]
            done = args.bootstrap

    for rep in range(done, args.bootstrap):
        rng = _rng_for_rep(args.seed, rep)
        idx = rng.integers(0, len(df), len(df))
        if np.unique(y[idx]).size < 2:
            # Keep one result per requested replicate while making the skip explicit.
            aucs.append(np.nan)
        else:
            model = LogisticRegression(max_iter=2000)
            model.fit(X.iloc[idx], y[idx])
            pred = model.predict_proba(X)[:, 1]
            aucs.append(float(roc_auc_score(y, pred)))

        if (rep + 1) % 50 == 0:
            pd.DataFrame({"auc": aucs}).to_csv(checkpoint, index=False)

    pd.DataFrame({"auc": aucs}).to_csv(checkpoint, index=False)
    valid = np.asarray([x for x in aucs if np.isfinite(x)], dtype=float)
    if valid.size == 0:
        raise RuntimeError("No valid bootstrap replicates completed")

    summary = {
        "purpose": "infrastructure_smoke_test_only",
        "n_bootstrap_requested": args.bootstrap,
        "n_bootstrap_valid": int(valid.size),
        "test_auc_mean": float(np.mean(valid)),
        "test_auc_ci_2_5": float(np.quantile(valid, 0.025)),
        "test_auc_ci_97_5": float(np.quantile(valid, 0.975)),
        "finished_unix": time.time(),
    }
    (out / "summary.json").write_text(
        json.dumps(summary, indent=2), encoding="utf-8"
    )
    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()
