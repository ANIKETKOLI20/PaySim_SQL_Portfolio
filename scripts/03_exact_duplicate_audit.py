
import csv
import json
import sqlite3
import tempfile

from pathlib import Path
import pandas as pd


# 1. Define paths
file_path = Path(
    "data/original/PS_20174392719_1491204439457_log.csv"
)

output_path = Path(
    "research/exact_duplicate_audit.csv"
)

# 2. Verify source file
if not file_path.exists():
    raise FileNotFoundError(f"Dataset not found: {file_path}")

# 3. Configure processing
batch_size = 50_000

total_records = 0
exact_duplicate_rows = 0

output_path.parent.mkdir(parents=True, exist_ok=True)

# 4. Create a temporary disk-based database
with tempfile.TemporaryDirectory(
    prefix="paysim_duplicate_audit_",
    dir=output_path.parent
) as temp_dir:

    db_path = Path(temp_dir) / "seen_rows.sqlite"
    conn = sqlite3.connect(db_path)

    conn.execute("""
        CREATE TABLE seen_rows (
            row_content TEXT PRIMARY KEY
        ) WITHOUT ROWID
    """)

    try:

        # 5. Read CSV progressively
        with file_path.open(
            "r",
            encoding="utf-8-sig",
            newline=""
        ) as csv_file:

            reader = csv.reader(csv_file)

            header = next(reader, None)

            if header is None:
                raise ValueError("CSV file is empty.")

            expected_columns = len(header)

            batch = []

            for row in reader:

                # Validate row structure
                if len(row) != expected_columns:
                    raise ValueError(
                        f"Unexpected column count at record "
                        f"{total_records + 1}"
                    )

                # Convert complete row into an unambiguous string
                row_content = json.dumps(
                    row,
                    ensure_ascii=False,
                    separators=(",", ":")
                )

                batch.append((row_content,))
                total_records += 1

                # Process each batch
                if len(batch) >= batch_size:

                    before = conn.total_changes

                    conn.executemany(
                        """
                        INSERT OR IGNORE INTO seen_rows
                        (row_content)
                        VALUES (?)
                        """,
                        batch
                    )

                    inserted = conn.total_changes - before

                    exact_duplicate_rows += (
                        len(batch) - inserted
                    )

                    conn.commit()
                    batch.clear()

            # Process remaining records
            if batch:

                before = conn.total_changes

                conn.executemany(
                    """
                    INSERT OR IGNORE INTO seen_rows
                    (row_content)
                    VALUES (?)
                    """,
                    batch
                )

                inserted = conn.total_changes - before

                exact_duplicate_rows += (
                    len(batch) - inserted
                )

                conn.commit()

        # 6. Count unique records
        unique_records = conn.execute(
            "SELECT COUNT(*) FROM seen_rows"
        ).fetchone()[0]

    finally:
        conn.close()

# 7. Calculate duplicate percentage
duplicate_percentage = (
    exact_duplicate_rows / total_records
) * 100 if total_records else 0

# 8. Create audit report
summary = pd.DataFrame([{
    "total_records": total_records,
    "unique_records": unique_records,
    "exact_duplicate_rows": exact_duplicate_rows,
    "duplicate_percentage": round(
        duplicate_percentage, 6
    )
}])

# 9. Display results
print("\n--- EXACT DUPLICATE AUDIT ---")

print(f"Total records: {total_records:,}")

print(f"Unique records: {unique_records:,}")

print(
    f"Exact duplicate rows: "
    f"{exact_duplicate_rows:,}"
)

print(
    f"Duplicate percentage: "
    f"{duplicate_percentage:.6f}%"
)

# 10. Save results
summary.to_csv(output_path, index=False)

print(f"\nReport saved to: {output_path}")
