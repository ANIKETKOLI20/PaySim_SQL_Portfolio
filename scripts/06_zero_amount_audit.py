
import csv

from collections import Counter
from decimal import Decimal, InvalidOperation
from pathlib import Path


# 1. Define paths
file_path = Path(
    "data/original/PS_20174392719_1491204439457_log.csv"
)

output_dir = Path("research")

detail_path = output_dir / "zero_amount_transactions.csv"
summary_path = output_dir / "zero_amount_summary.csv"


# 2. Verify source
if not file_path.exists():
    raise FileNotFoundError(f"Dataset not found: {file_path}")

output_dir.mkdir(parents=True, exist_ok=True)


# 3. Initialize counters
total_records = 0
zero_amount_records = 0

type_counts = Counter()
fraud_counts = Counter()
flag_counts = Counter()
combination_counts = Counter()


# 4. Read the complete CSV
with file_path.open(
    "r",
    encoding="utf-8-sig",
    newline=""
) as csv_file:

    reader = csv.DictReader(csv_file)

    required_columns = {
        "amount",
        "type",
        "nameOrig",
        "nameDest",
        "oldbalanceOrg",
        "newbalanceOrig",
        "oldbalanceDest",
        "newbalanceDest",
        "isFraud",
        "isFlaggedFraud"
    }

    if not required_columns.issubset(reader.fieldnames or []):
        raise ValueError("Required columns are missing.")

    with detail_path.open(
        "w",
        encoding="utf-8",
        newline=""
    ) as output_file:

        output_fields = ["csv_line_number"] + reader.fieldnames

        writer = csv.DictWriter(
            output_file,
            fieldnames=output_fields
        )

        writer.writeheader()

        for line_number, row in enumerate(reader, start=2):

            total_records += 1

            # 5. Validate transaction amount
            try:
                amount = Decimal(row["amount"].strip())

            except InvalidOperation as exc:
                raise ValueError(
                    f"Invalid amount at CSV line {line_number}"
                ) from exc

            # 6. Investigate zero-amount records
            if amount == Decimal("0"):

                zero_amount_records += 1

                transaction_type = row["type"]
                fraud = row["isFraud"]
                flagged = row["isFlaggedFraud"]

                type_counts[transaction_type] += 1
                fraud_counts[fraud] += 1
                flag_counts[flagged] += 1

                combination_counts[
                    (transaction_type, fraud, flagged)
                ] += 1

                # Preserve the complete original record
                writer.writerow({
                    "csv_line_number": line_number,
                    **row
                })


# 7. Build summary
summary_rows = []

for value, count in type_counts.items():
    summary_rows.append({
        "dimension": "transaction_type",
        "value": value,
        "record_count": count
    })

for value, count in fraud_counts.items():
    summary_rows.append({
        "dimension": "isFraud",
        "value": value,
        "record_count": count
    })

for value, count in flag_counts.items():
    summary_rows.append({
        "dimension": "isFlaggedFraud",
        "value": value,
        "record_count": count
    })

for (transaction_type, fraud, flagged), count in (
    combination_counts.items()
):
    summary_rows.append({
        "dimension": "type_fraud_flag_combination",
        "value": f"{transaction_type}|{fraud}|{flagged}",
        "record_count": count
    })


# 8. Save summary
with summary_path.open(
    "w",
    encoding="utf-8",
    newline=""
) as output_file:

    fields = ["dimension", "value", "record_count"]

    writer = csv.DictWriter(
        output_file,
        fieldnames=fields
    )

    writer.writeheader()
    writer.writerows(summary_rows)


# 9. Display actual results
print("\n--- ZERO AMOUNT AUDIT ---")
print(f"Total records scanned: {total_records:,}")
print(f"Zero-amount records: {zero_amount_records:,}")

print("\n--- BY TRANSACTION TYPE ---")
for value, count in type_counts.items():
    print(f"{value}: {count}")

print("\n--- BY FRAUD LABEL ---")
for value, count in fraud_counts.items():
    print(f"isFraud = {value}: {count}")

print("\n--- BY FRAUD FLAG ---")
for value, count in flag_counts.items():
    print(f"isFlaggedFraud = {value}: {count}")

print("\n--- CATEGORY AND FLAG COMBINATIONS ---")
for key, count in combination_counts.items():
    print(f"{key}: {count}")

print("\nReports saved:")
print(detail_path)
print(summary_path)
