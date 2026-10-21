"""Profile the raw A/B test CSV before loading it anywhere.

Answers Step 2's questions: row count vs unique users, the values in group and
landing_page (and how they combine), the timestamp format and date range, and
the overall conversion rate.

Usage (from the repo root, in the abtest conda env):
    python scripts/01_profile_raw.py [path/to/ab_data.csv]
"""

import sys

import pandas as pd

TIMESTAMP_FORMAT = "%Y-%m-%d %H:%M:%S.%f"
TIMESTAMP_PATTERN = r"^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{6}$"
EXPECTED_PAIRS = {("control", "old_page"), ("treatment", "new_page")}


def section(title):
    print(f"\n== {title} ==")


def main(path):
    # Read everything as text first so nothing is silently coerced.
    df = pd.read_csv(path, dtype=str)

    section("Shape")
    print(f"rows:    {len(df):,}")
    print(f"columns: {list(df.columns)}")
    print(f"nulls:   {df.isna().sum().to_dict()}")

    section("Rows vs unique users")
    rows_per_user = df["user_id"].value_counts()
    repeat_users = rows_per_user[rows_per_user > 1]
    print(f"unique users:              {len(rows_per_user):,}")
    print(f"extra rows beyond 1/user:  {len(df) - len(rows_per_user):,}")
    print(f"users with >1 row:         {len(repeat_users):,}")
    print(f"max rows for one user:     {rows_per_user.max()}")
    print(f"fully identical rows:      {df.duplicated().sum():,}")

    section("Column values")
    for col in ["group", "landing_page", "converted"]:
        print(f"{col}: {df[col].value_counts().to_dict()}")

    section("group x landing_page")
    print(pd.crosstab(df["group"], df["landing_page"], margins=True))
    is_mismatch = [
        (g, p) not in EXPECTED_PAIRS for g, p in zip(df["group"], df["landing_page"])
    ]
    print(f"mismatched rows: {sum(is_mismatch):,}")

    section("Overlap: repeat users vs mismatched rows")
    df["is_mismatch"] = is_mismatch
    repeat_rows = df[df["user_id"].isin(repeat_users.index)]
    mismatches_per_repeat_user = repeat_rows.groupby("user_id")["is_mismatch"].sum()
    print(f"mismatched rows from repeat users:  {repeat_rows['is_mismatch'].sum():,}")
    print(f"mismatched rows from one-row users: {df.loc[~df['user_id'].isin(repeat_users.index), 'is_mismatch'].sum():,}")
    print(f"repeat users by # mismatched rows:  {mismatches_per_repeat_user.value_counts().sort_index().to_dict()}")
    in_both_groups = (repeat_rows.groupby("user_id")["group"].nunique() > 1).sum()
    print(f"repeat users recorded in both groups: {in_both_groups:,}")
    clean = df[~df["is_mismatch"]]
    print(
        f"after dropping mismatches: {len(clean):,} rows, "
        f"{clean['user_id'].nunique():,} users, "
        f"{clean['user_id'].duplicated().sum():,} still duplicated"
    )

    section("Timestamps")
    matches = df["timestamp"].str.match(TIMESTAMP_PATTERN).sum()
    print(f"rows matching YYYY-MM-DD HH:MM:SS.ffffff: {matches:,} of {len(df):,}")
    ts = pd.to_datetime(df["timestamp"], format=TIMESTAMP_FORMAT)
    print(f"min: {ts.min()}  max: {ts.max()}  span: {ts.max() - ts.min()}")
    print(f"distinct dates: {ts.dt.date.nunique()}")

    section("Conversion (raw, before any cleaning)")
    converted = df["converted"].astype(int)
    print(f"overall: {converted.sum():,} / {len(df):,} = {converted.mean():.4%}")
    by_group = converted.groupby(df["group"]).agg(["sum", "count", "mean"])
    print(by_group.rename(columns={"mean": "rate"}))


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "data/raw/ab_data.csv")
