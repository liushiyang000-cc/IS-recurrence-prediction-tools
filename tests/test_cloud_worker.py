"""Cloud worker smoke test using synthetic data only."""
from pathlib import Path
import subprocess
import sys
import tempfile

import numpy as np
import pandas as pd


ROOT = Path(__file__).resolve().parents[1]
WORKER = ROOT / "kaggle" / "run_heavy.py"


def run_worker(data_path: Path, out_dir: Path, n_boot: int) -> None:
    subprocess.run(
        [
            sys.executable,
            str(WORKER),
            "--input",
            str(data_path),
            "--out",
            str(out_dir),
            "--bootstrap",
            str(n_boot),
            "--seed",
            "20260923",
        ],
        check=True,
    )


def main() -> None:
    rng = np.random.default_rng(42)
    n = 220
    age = rng.normal(65, 10, n)
    nihss = rng.poisson(5, n)
    ldl = rng.normal(2.8, 0.8, n)
    logit = -4 + 0.03 * age + 0.12 * nihss + 0.25 * ldl
    p = 1 / (1 + np.exp(-logit))
    event = rng.binomial(1, p)

    with tempfile.TemporaryDirectory() as td:
        td = Path(td)
        data_path = td / "analysis.csv"
        pd.DataFrame(
            {"event": event, "age": age, "nihss": nihss, "ldl": ldl}
        ).to_csv(data_path, index=False)

        resumed = td / "resumed"
        fresh = td / "fresh"

        run_worker(data_path, resumed, 25)
        run_worker(data_path, resumed, 50)
        run_worker(data_path, fresh, 50)

        a = pd.read_csv(resumed / "bootstrap_auc.csv")
        b = pd.read_csv(fresh / "bootstrap_auc.csv")
        if len(a) != 50 or len(b) != 50:
            raise AssertionError("Expected exactly 50 checkpoint rows")
        pd.testing.assert_frame_equal(a, b, check_exact=True)

        if not (resumed / "summary.json").exists():
            raise AssertionError("summary.json was not created")

    print("PASS: fresh and resumed runs are identical; outputs were created.")


if __name__ == "__main__":
    main()
