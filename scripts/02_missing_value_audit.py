
from pathlib import Path
import pandas as pd

# 1. Define file paths
file_path = Path(
    "data/original/PS_20174392719_1491204439457_log.csv"
)

output_path = Path(
    "research/missing_value_audit.csv"
)

# 2. Verify source file
if not file_path.exists():
    raise FileNotFoundError(f"Dataset not found: {file_path}")

# 3. Configure chunk processing
chunk_size = 100_000

missing_counts = None
total_rows = 0

# 4. Read and process the entire CSV in chunks
for chunk in pd.read_csv(file_path, chunksize=chunk_size):

    # Initialize counters using the column names
    if missing_counts is None:
        missing_counts = pd.Series(
            0,
            index=chunk.columns,
            dtype="int64"
        )

    # Count missing values in each column
    missing_counts += chunk.isna().sum()

    # Track total records processed
    total_rows += len(chunk)

# 5. Verify that data was processed
if missing_counts is None or total_rows == 0:
    raise ValueError("No records were processed.")

# 6. Calculate missing-value percentages
missing_percentage = (
    missing_counts / total_rows
) * 100

# 7. Create summary report
summary = pd.DataFrame({
    "missing_count": missing_counts,
    "missing_percentage": missing_percentage.round(4)
})

# 8. Display actual results
print("\n--- MISSING VALUE AUDIT ---")
print(f"Total records processed: {total_rows:,}")

print("\n--- COLUMN-WISE MISSING VALUES ---")
print(summary.to_string())

print("\n--- TOTAL MISSING VALUES ---")
print(f"Total missing values: {missing_counts.sum():,}")

# 9. Save the audit report
output_path.parent.mkdir(parents=True, exist_ok=True)
summary.to_csv(output_path)

print(f"\nAudit report saved to: {output_path}")
