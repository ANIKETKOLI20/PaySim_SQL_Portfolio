
import csv
import sqlite3
import tempfile

from collections import Counter
from pathlib import Path

import pandas as pd


# 1. Define paths
file_path = Path(
    "data/original/PS_20174392719_1491204439457_log.csv"
)

output_dir = Path("research")

summary_path = output_dir / "identifier_frequency_summary.csv"
sender_path = output_dir / "top_10_senders.csv"
recipient_path = output_dir / "top_10_recipients.csv"

# 2. Verify source file
if not file_path.exists():
    raise FileNotFoundError(f"Dataset not found: {file_path}")

output_dir.mkdir(parents=True, exist_ok=True)

# 3. Configure processing
batch_size = 50_000
total_records = 0

sender_batch = []
recipient_batch = []

# 4. Define a function to save batch frequencies
def save_batch(conn):

    sender_counts = Counter(sender_batch)
    recipient_counts = Counter(recipient_batch)

    conn.executemany("""
        INSERT INTO sender_counts
        (account_id, occurrence_count)
        VALUES (?, ?)
        ON CONFLICT(account_id)
        DO UPDATE SET occurrence_count =
            occurrence_count + excluded.occurrence_count
    """, sender_counts.items())

    conn.executemany("""
        INSERT INTO recipient_counts
        (account_id, occurrence_count)
        VALUES (?, ?)
        ON CONFLICT(account_id)
        DO UPDATE SET occurrence_count =
            occurrence_count + excluded.occurrence_count
    """, recipient_counts.items())

    conn.commit()

    sender_batch.clear()
    recipient_batch.clear()


# 5. Create temporary SQLite database
with tempfile.TemporaryDirectory(
    prefix="paysim_identifier_audit_",
    dir=output_dir
) as temp_dir:

    db_path = Path(temp_dir) / "identifier_counts.sqlite"
    conn = sqlite3.connect(db_path)

    conn.execute("PRAGMA synchronous = NORMAL")

    conn.execute("""
        CREATE TABLE sender_counts (
            account_id TEXT PRIMARY KEY,
            occurrence_count INTEGER NOT NULL
        ) WITHOUT ROWID
    """)

    conn.execute("""
        CREATE TABLE recipient_counts (
            account_id TEXT PRIMARY KEY,
            occurrence_count INTEGER NOT NULL
        ) WITHOUT ROWID
    """)

    try:

        # 6. Read original CSV
        with file_path.open(
            "r",
            encoding="utf-8-sig",
            newline=""
        ) as csv_file:

            reader = csv.reader(csv_file)

            header = next(reader, None)

            if header is None:
                raise ValueError("CSV file is empty.")

            sender_idx = header.index("nameOrig")
            recipient_idx = header.index("nameDest")

            for row in reader:

                if len(row) != len(header):
                    raise ValueError(
                        f"Invalid row structure at record "
                        f"{total_records + 1}"
                    )

                sender = row[sender_idx]
                recipient = row[recipient_idx]

                if not sender or not recipient:
                    raise ValueError(
                        "Missing account identifier detected."
                    )

                sender_batch.append(sender)
                recipient_batch.append(recipient)

                total_records += 1

                # Process every 50,000 records
                if len(sender_batch) >= batch_size:
                    save_batch(conn)

            # Process final incomplete batch
            if sender_batch:
                save_batch(conn)

        # 7. Calculate identifier statistics
        def get_statistics(table):

            return conn.execute(f"""
                SELECT
                    COUNT(*),
                    SUM(
                        CASE
                            WHEN occurrence_count > 1 THEN 1
                            ELSE 0
                        END
                    )
                FROM {table}
            """).fetchone()

        sender_unique, sender_repeated = get_statistics(
            "sender_counts"
        )

        recipient_unique, recipient_repeated = get_statistics(
            "recipient_counts"
        )

        # 8. Find top 10 identifiers
        top_senders = conn.execute("""
            SELECT account_id, occurrence_count
            FROM sender_counts
            ORDER BY occurrence_count DESC, account_id
            LIMIT 10
        """).fetchall()

        top_recipients = conn.execute("""
            SELECT account_id, occurrence_count
            FROM recipient_counts
            ORDER BY occurrence_count DESC, account_id
            LIMIT 10
        """).fetchall()

    finally:
        conn.close()


# 9. Create summary report
summary = pd.DataFrame([
    {"metric": "total_records", "value": total_records},
    {"metric": "unique_sender_ids", "value": sender_unique},
    {"metric": "sender_ids_with_multiple_transactions",
     "value": sender_repeated},
    {"metric": "unique_recipient_ids", "value": recipient_unique},
    {"metric": "recipient_ids_with_multiple_transactions",
     "value": recipient_repeated}
])

summary.to_csv(summary_path, index=False)


# 10. Save top 10 frequency reports
pd.DataFrame(
    top_senders,
    columns=["sender_id", "transaction_count"]
).to_csv(sender_path, index=False)

pd.DataFrame(
    top_recipients,
    columns=["recipient_id", "transaction_count"]
).to_csv(recipient_path, index=False)


# 11. Display results
print("\n--- IDENTIFIER FREQUENCY AUDIT ---")
print(f"Total records processed: {total_records:,}")

print(f"\nUnique sender IDs: {sender_unique:,}")
print(f"Repeated sender IDs: {sender_repeated:,}")

print(f"\nUnique recipient IDs: {recipient_unique:,}")
print(f"Repeated recipient IDs: {recipient_repeated:,}")

print("\n--- TOP 10 SENDERS ---")
print(pd.DataFrame(
    top_senders,
    columns=["sender_id", "transaction_count"]
).to_string(index=False))

print("\n--- TOP 10 RECIPIENTS ---")
print(pd.DataFrame(
    top_recipients,
    columns=["recipient_id", "transaction_count"]
).to_string(index=False))

print("\nReports saved successfully.")
