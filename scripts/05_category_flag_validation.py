
import csv
import math

from collections import Counter
from pathlib import Path

import pandas as pd


# 1. Define source and output paths
file_path = Path(
    "data/original/PS_20174392719_1491204439457_log.csv"
)

output_dir = Path("research")

category_path = output_dir / "transaction_category_counts.csv"
flag_path = output_dir / "fraud_flag_value_counts.csv"
numeric_path = output_dir / "numeric_quality_summary.csv"


# 2. Define expected values
expected_types = {
    "CASH_IN",
    "CASH_OUT",
    "DEBIT",
    "PAYMENT",
    "TRANSFER"
}

expected_flags = {"0", "1"}


# 3. Define columns to investigate
flag_columns = ["isFraud", "isFlaggedFraud"]

numeric_columns = [
    "step",
    "amount",
    "oldbalanceOrg",
    "newbalanceOrig",
    "oldbalanceDest",
    "newbalanceDest"
]


# 4. Verify source file
if not file_path.exists():
    raise FileNotFoundError(f"Dataset not found: {file_path}")

output_dir.mkdir(parents=True, exist_ok=True)


# 5. Initialize counters
total_records = 0

category_counts = Counter()

flag_counts = {
    column: Counter()
    for column in flag_columns
}

numeric_stats = {
    column: {
        "blank_count": 0,
        "non_numeric_count": 0,
        "non_finite_count": 0,
        "negative_count": 0,
        "zero_count": 0,
        "out_of_expected_range_count": (
            0 if column == "step" else None
         ), 
        "minimum": None,
        "maximum": None
    }
    for column in numeric_columns
}


# 6. Read and investigate the entire CSV
with file_path.open(
    "r",
    encoding="utf-8-sig",
    newline=""
) as csv_file:

    reader = csv.reader(csv_file)

    header = next(reader, None)

    if header is None:
        raise ValueError("CSV file is empty.")

    # Identify column positions
    column_positions = {
        name: header.index(name)
        for name in (
            ["type"]
            + flag_columns
            + numeric_columns
        )
    }

    expected_column_count = len(header)

    for row_number, row in enumerate(reader, start=2):

        if len(row) != expected_column_count:
            raise ValueError(
                f"Unexpected number of fields at CSV "
                f"line {row_number}"
            )

        total_records += 1

        # A. Transaction category frequency
        category_value = row[column_positions["type"]]
        category_counts[category_value] += 1

        # B. Fraud flag value frequency
        for column in flag_columns:

            value = row[column_positions[column]]

            flag_counts[column][value] += 1

        # C. Numeric quality investigation
        for column in numeric_columns:

            raw_value = row[column_positions[column]]
            stats = numeric_stats[column]

            if raw_value == "":
                stats["blank_count"] += 1
                continue

            try:
                value = float(raw_value)

            except ValueError:
                stats["non_numeric_count"] += 1
                continue

            if not math.isfinite(value):
                stats["non_finite_count"] += 1
                continue

            if value < 0:
                stats["negative_count"] += 1

            if value == 0:
                stats["zero_count"] += 1

            # Record minimum and maximum values
            if stats["minimum"] is None:
                stats["minimum"] = value
                stats["maximum"] = value
            else:
                stats["minimum"] = min(
                    stats["minimum"], value
                )
                stats["maximum"] = max(
                    stats["maximum"], value
                )

            # Validate simulation step range
            if column == "step":
                if (
                    not value.is_integer()
                    or value < 1
                    or value > 744
                ):
                    stats["out_of_expected_range_count"] += 1


# 7. Prepare category report
category_rows = [
    {
        "transaction_type": value if value else "<EMPTY>",
        "transaction_count": count,
        "is_expected": value in expected_types
    }
    for value, count in category_counts.items()
]

category_rows.sort(
    key=lambda row: (
        not row["is_expected"],
        -row["transaction_count"]
    )
)


# 8. Prepare fraud flag report
flag_rows = []

for column, counts in flag_counts.items():

    for value, count in counts.items():

        flag_rows.append({
            "column_name": column,
            "flag_value": value if value else "<EMPTY>",
            "record_count": count,
            "is_expected": value in expected_flags
        })


# 9. Prepare numeric quality report
numeric_rows = []

for column, stats in numeric_stats.items():

    numeric_rows.append({
        "column_name": column,
        **stats
    })


# 10. Save reports
pd.DataFrame(category_rows).to_csv(
    category_path,
    index=False
)

pd.DataFrame(flag_rows).to_csv(
    flag_path,
    index=False
)

pd.DataFrame(numeric_rows).to_csv(
    numeric_path,
    index=False
)


# 11. Calculate unexpected category and flag totals
unexpected_categories = sum(
    count
    for value, count in category_counts.items()
    if value not in expected_types
)

unexpected_flags = {
    column: sum(
        count
        for value, count in counts.items()
        if value not in expected_flags
    )
    for column, counts in flag_counts.items()
}


# 12. Display results
print("\n--- TRANSACTION CATEGORY VALIDATION ---")
print(f"Total records: {total_records:,}")

print(pd.DataFrame(category_rows).to_string(index=False))

print(f"\nUnexpected category records: {unexpected_categories:,}")


print("\n--- FRAUD FLAG VALIDATION ---")

print(pd.DataFrame(flag_rows).to_string(index=False))

for column, count in unexpected_flags.items():
    print(f"Unexpected values in {column}: {count:,}")


print("\n--- NUMERIC QUALITY VALIDATION ---")

numeric_report = pd.DataFrame(numeric_rows)

print(numeric_report.to_string(index=False))


print("\n--- REPORTS SAVED ---")
print(category_path)
print(flag_path)
print(numeric_path)
