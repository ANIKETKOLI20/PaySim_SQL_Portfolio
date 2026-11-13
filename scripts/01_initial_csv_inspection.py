
from pathlib import Path
import pandas as pd

# 1. Define the CSV file location
file_path = Path(
    "data/original/PS_20174392719_1491204439457_log.csv"
)

# 2. Verify that the file exists
if not file_path.exists():
    raise FileNotFoundError(f"Dataset not found: {file_path}")

# 3. Read only the first 10,000 records
df = pd.read_csv(file_path, nrows=10_000)

# 4. Display dataset dimensions
print("\n--- DATASET DIMENSIONS ---")
print(df.shape)

# 5. Display column names
print("\n--- COLUMN NAMES ---")
print(df.columns.tolist())

# 6. Display inferred data types
print("\n--- DATA TYPES ---")
print(df.dtypes)

# 7. Display the first five records
print("\n--- FIRST FIVE RECORDS ---")
print(df.head().to_string(index=False))

# 8. Display structural information
print("\n--- DATAFRAME INFORMATION ---")
df.info()
