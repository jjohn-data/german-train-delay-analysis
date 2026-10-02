from pathlib import Path
import sqlite3
import sys

import pandas as pd


PROJECT_ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = PROJECT_ROOT / "data"
DATABASE_DIR = PROJECT_ROOT / "database"
DATABASE_PATH = DATABASE_DIR / "train_delay.db"
TABLE_NAME = "train_data"


def find_source_csv() -> Path:
    csv_files = sorted(DATA_DIR.glob("*.csv"))
    if len(csv_files) == 1:
        return csv_files[0]
    if not csv_files:
        raise FileNotFoundError(
            "No CSV file found in data/. Download the Kaggle dataset and place the CSV in that folder."
        )
    raise RuntimeError(
        "Multiple CSV files found in data/. Keep only the Deutsche Bahn delay CSV before running this script."
    )


def main() -> None:
    source = find_source_csv()
    DATABASE_DIR.mkdir(parents=True, exist_ok=True)

    print(f"Reading {source.name} ...")
    df = pd.read_csv(source, low_memory=False)

    required_columns = {
        "arrival_plan",
        "arrival_delay_m",
        "line",
        "station",
        "state",
        "lat",
        "long",
    }
    missing = required_columns.difference(df.columns)
    if missing:
        raise ValueError(
            "Dataset is missing required columns: " + ", ".join(sorted(missing))
        )

    with sqlite3.connect(DATABASE_PATH) as conn:
        df.to_sql(TABLE_NAME, conn, if_exists="replace", index=False)
        conn.execute(
            "CREATE INDEX IF NOT EXISTS idx_train_arrival_plan ON train_data(arrival_plan)"
        )
        conn.execute(
            "CREATE INDEX IF NOT EXISTS idx_train_line ON train_data(line)"
        )
        conn.execute(
            "CREATE INDEX IF NOT EXISTS idx_train_state ON train_data(state)"
        )
        conn.execute(
            "CREATE INDEX IF NOT EXISTS idx_train_station ON train_data(station)"
        )

    print(f"Created {DATABASE_PATH}")
    print(f"Rows imported: {len(df):,}")


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        print(f"Error: {exc}", file=sys.stderr)
        raise
