# PaySim Data Quality Findings

## 1. Missing Value Investigation

Dataset: PaySim

Total Records Processed: 6,362,620
Total Columns: 11
Total Missing Values: 0

### Methodology

- Used Python and Pandas.
- Processed the CSV using chunk-based reading.
- Chunk size: 100,000 records.
- Used isna().sum() to calculate missing values.
- Calculated missing-value percentages column-wise.

### Finding

No missing values were detected by Pandas
across the complete dataset using its standard
CSV missing-value recognition.

### Limitation

Zero values are not automatically treated as
missing values. Structurally unavailable data
requires separate investigation.