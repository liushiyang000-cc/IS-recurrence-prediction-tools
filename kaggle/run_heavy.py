"""Kaggle/CPU worker template for heavy RIS computation.

Expected input: /kaggle/input/.../analysis.csv
Outputs: /kaggle/working/results/
No direct identifiers should ever be uploaded.
"""
from pathlib import Path
import argparse
import json
import time

import numpy as np
import pandas as pd
from sklearn.model_selection import StratifiedKFold
from sklearn.metrics import roc_auc_score
from sklearn.linear_model import LogisticRegression


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--input", required=True)
    p.add_argument("--out", default="/kaggle/working/results")
    p.add_argument("--bootstrap", type=int, default=1000)
    p.add_argument("--seed", type=int, default=20260923)
    args = p.parse_args()

    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    checkpoint = out / "bootstrap_auc.csv"

    df = pd.read_csv(args.input)
    if "event" not in df.columns:
        raise ValueError("Input must contain binary outcome column: event")

    y = df["event"].astype(int).to_numpy()
    X = df.drop(columns=["event"]).select_dtypes(include=[np.number]).copy()
    X = X.replace([np.inf, -np.inf], np.nan).fillna(X.median())

    rng = np.random.default_rng(args.seed)
    done = 0
    aucs = []

    if checkpoint.exists():
        prev = pd.read_csv(checkpoint)
        aucs = prev["auc"].tolist()
        done = len(aucs)

    for i in range(done, args.bootstrap):
        idx = rng.integers(0, len(df), len(df))
        if np.unique(y[idx]).size < 2:
            continue
        model = LogisticRegression(max_iter=2000)
        model.fit(X.iloc[idx], y[idx])
        pred = model.predict_proba(X)[:, 1]
        aucs.append(roc_auc_score(y, pred))

        if (i + 1) % 50 == 0:
            pd.DataFrame({"auc": aucs}).to_csv(checkpoint, index=False)

    pd.DataFrame({"auc": aucs}).to_csv(checkpoint, index=False)
    summary = {
        "n_bootstrap_completed": len(aucs),
        "auc_mean": float(np.mean(aucs)),
        "auc_ci_2_5": float(np.quantile(aucs, 0.025)),
        "auc_ci_97_5": float(np.quantile(aucs, 0.975)),
        "finished_unix": time.time(),
    }
    (out / "summary.json").write_text(json.dumps(summary, indent=2), encoding="utf-8")
    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()
