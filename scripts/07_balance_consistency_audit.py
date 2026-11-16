
import csv
import math

from collections import Counter
from pathlib import Path

import pandas as pd


# 1. Define paths
file_path = Path(
    "data/original/PS_20174392719_1491204439457_log.csv"
)

output_dir = Path("research")

sender_path = output_dir / "sender_balance_movement.csv"
recipient_path = output_dir / "recipient_balance_movement.csv"


# 2. Define comparison tolerance
# Differences up to one cent are treated as matching.
tolerance = 0.01


# 3. Initialize counters
total_records = 0

sender_totals = Counter()
sender_movements = Counter()

recipient_totals = Counter()
recipient_movements = Counter()
merchant_counts = Counter()


# 4. Define movement classification
def classify_movement(delta, amount, side):

    # Check unchanged balances first
    if math.isclose(
        delta, 0,
        rel_tol=0,
        abs_tol=tolerance
    ):
        return "unchanged"

    if side == "sender":

        if math.isclose(
            delta, -amount,
            rel_tol=0,
            abs_tol=tolerance
        ):
            return "matches_minus_amount"

        if math.isclose(
            delta, amount,
            rel_tol=0,
            abs_tol=tolerance
        ):
            return "matches_plus_amount"

    elif side == "recipient":

        if math.isclose(
            delta, amount,
            rel_tol=0,
            abs_tol=tolerance
        ):
            return "matches_plus_amount"

        if math.isclose(
            delta, -amount,
            rel_tol=0,
            abs_tol=tolerance
        ):
            return "matches_minus_amount"

    return "other"


# 5. Verify source file
if not file_path.exists():
    raise FileNotFoundError(
        f"Dataset not found: {file_path}"
    )

output_dir.mkdir(parents=True, exist_ok=True)


# 6. Read the complete CSV
with file_path.open(
    "r",
    encoding="utf-8-sig",
    newline=""
) as csv_file:

    reader = csv.DictReader(csv_file)

    required_columns = {
        "type",
        "amount",
        "nameDest",
        "oldbalanceOrg",
        "newbalanceOrig",
        "oldbalanceDest",
        "newbalanceDest",
        "isFraud"
    }

    if not required_columns.issubset(
        reader.fieldnames or []
    ):
        raise ValueError(
            "Required columns are missing."
        )

    for row in reader:

        total_records += 1

        transaction_type = row["type"]
        fraud = row["isFraud"]

        amount = float(row["amount"])

        # A. Sender movement
        old_sender = float(row["oldbalanceOrg"])
        new_sender = float(row["newbalanceOrig"])

        sender_delta = new_sender - old_sender

        sender_result = classify_movement(
            sender_delta,
            amount,
            "sender"
        )

        sender_key = (transaction_type, fraud)

        sender_totals[sender_key] += 1
        sender_movements[
            (transaction_type, fraud, sender_result)
        ] += 1

        # B. Recipient movement
        recipient_id = row["nameDest"]

        recipient_key = (transaction_type, fraud)

        if recipient_id.startswith("M"):

            # Merchant balance information is unavailable
            merchant_counts[recipient_key] += 1

        else:

            old_recipient = float(
                row["oldbalanceDest"]
            )

            new_recipient = float(
                row["newbalanceDest"]
            )

            recipient_delta = (
                new_recipient - old_recipient
            )

            recipient_result = classify_movement(
                recipient_delta,
                amount,
                "recipient"
            )

            recipient_totals[recipient_key] += 1

            recipient_movements[
                (
                    transaction_type,
                    fraud,
                    recipient_result
                )
            ] += 1


# 7. Build sender report
sender_rows = []

for (transaction_type, fraud), count in sorted(
    sender_totals.items()
):

    row = {
        "transaction_type": transaction_type,
        "isFraud": fraud,
        "total_records": count
    }

    for result in [
        "unchanged",
        "matches_minus_amount",
        "matches_plus_amount",
        "other"
    ]:

        row[result] = sender_movements[
            (transaction_type, fraud, result)
        ]

    sender_rows.append(row)


# 8. Build recipient report
recipient_keys = (
    set(recipient_totals)
    | set(merchant_counts)
)

recipient_rows = []

for transaction_type, fraud in sorted(recipient_keys):

    customer_count = recipient_totals[
        (transaction_type, fraud)
    ]

    row = {
        "transaction_type": transaction_type,
        "isFraud": fraud,
        "non_merchant_records": customer_count,
        "merchant_records": merchant_counts[
            (transaction_type, fraud)
        ]
    }

    for result in [
        "unchanged",
        "matches_plus_amount",
        "matches_minus_amount",
        "other"
    ]:

        row[result] = recipient_movements[
            (transaction_type, fraud, result)
        ]

    recipient_rows.append(row)


# 9. Save reports
sender_report = pd.DataFrame(sender_rows)
recipient_report = pd.DataFrame(recipient_rows)

sender_report.to_csv(
    sender_path,
    index=False
)

recipient_report.to_csv(
    recipient_path,
    index=False
)


# 10. Display results
print("\n--- BALANCE CONSISTENCY AUDIT ---")
print(f"Total records processed: {total_records:,}")

print("\n--- SENDER BALANCE MOVEMENT ---")
print(sender_report.to_string(index=False))

print("\n--- RECIPIENT BALANCE MOVEMENT ---")
print(recipient_report.to_string(index=False))

print("\n--- REPORTS SAVED ---")
print(sender_path)
print(recipient_path)
