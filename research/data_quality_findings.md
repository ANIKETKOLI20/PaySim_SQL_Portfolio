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

## 2. Exact Duplicate Record Investigation

### Methodology

- Processed the complete CSV.
- Compared all 11 columns.
- Used Python CSV reader and SQLite.
- Processed records in batches of 50,000.
- Compared complete parsed row values.

### Results

Total Records: 6,362,620
Unique Records: 6,362,620
Exact Duplicate Rows: 0
Duplicate Percentage: 0.000000%

### Finding

No exact duplicate records were detected.

### Limitations

- PaySim does not provide a dedicated transaction ID.
- Repeated sender and recipient identifiers
  are not necessarily duplicate transactions.
- Near-duplicates were not investigated in this audit.


## 3. Identifier Frequency Investigation

### Methodology
- Processed all transaction records.
- Counted sender occurrences using nameOrig.
- Counted recipient occurrences using nameDest.
- Used SQLite for disk-based frequency aggregation.
- Processed records in batches of 50,000.

### Results

Total Records: 6,362,620

Unique Sender IDs: 6,353,307
Sender IDs Appearing More Than Once: 9,298

Unique Recipient IDs: 2,722,362
Recipient IDs Appearing More Than Once: 459,658

Highest Sender Frequency: 3
Highest Recipient Frequency: 113

### Findings

Recipient identifiers appear repeatedly
more frequently than sender identifiers.

The most frequent recipient appeared in
113 transaction records.

The ten sender identifiers returned by
the ranking query each appeared three times.

### Limitations

- Identifiers do not necessarily represent unique human customers.
- Recipient identifiers can represent customer accounts or merchants.
- Repeated identifiers do not indicate duplicate transactions.
- Frequency alone cannot establish fraudulent activity.
