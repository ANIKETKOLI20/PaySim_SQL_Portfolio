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


## 4. Transaction Category Validation

Total Records: 6,362,620

Expected Categories:
- CASH_OUT: 2,237,500
- PAYMENT: 2,151,495
- CASH_IN: 1,399,284
- TRANSFER: 532,909
- DEBIT: 41,432

Unexpected Categories: 0

Finding:
All five expected transaction categories were
identified. No unexpected category values were found.

## 5. Fraud Flag Validation

### isFraud
- Value 0: 6,354,407
- Value 1: 8,213

### isFlaggedFraud
- Value 0: 6,362,604
- Value 1: 16

Unexpected Values: 0

Finding:
Both fraud indicator columns contain only
the expected binary values.

## 6. Numeric Quality Investigation

Finding:
- No negative values were detected in the
  six investigated numeric columns.
- No blank, non-numeric or non-finite values
  were detected.
- Sixteen transactions have zero amounts.
- Multiple balance columns contain zero values.
- Observed step range: 1 to 743.

Limitation:
Zero balances are not automatically considered
missing or invalid. Further investigation is required.


## 7. Zero-Amount Transaction Investigation

### Methodology
- Processed all 6,362,620 records.
- Identified transactions where amount = 0.
- Extracted complete original transaction records.
- Examined transaction type, account balances and fraud indicators.

### Results

Total Zero-Amount Transactions: 16

Transaction Type:
- CASH_OUT: 16

Fraud Classification:
- isFraud = 1: 16
- isFlaggedFraud = 0: 16

### Key Findings

1. All 16 transactions belong to CASH_OUT.
2. All transactions have zero monetary value.
3. Sender balances remain unchanged.
4. Recipient balances remain unchanged.
5. All records are labelled fraudulent in the simulation.
6. None is flagged by the rule-based indicator.

### Interpretation

The records represent an unusual pattern of
zero-value cash-out transactions.

The existing fraud labels indicate that these
records are classified as fraudulent by the simulator.

The reason for this classification cannot be
established from the available columns alone.

### Limitation

These records should not automatically be treated
as invalid transactions or removed from the dataset.
Further investigation would be required.


## 8. Balance Consistency Investigation

### Methodology

- Processed all 6,362,620 records.
- Calculated sender balance movement.
- Calculated recipient balance movement.
- Compared movements against transaction amounts.
- Used a tolerance of 0.01.
- Excluded merchant destination balances from
  recipient reconciliation.
- Segmented results by transaction type and fraud label.

### Key Findings

1. CASH_IN sender balances frequently increased
   by the transaction amount.

2. Non-fraud CASH_OUT sender balances frequently
   did not match the simple expected balance decrease.

3. Non-fraud TRANSFER sender balances also showed
   substantial unchanged and other movements.

4. Non-fraud TRANSFER recipient balances frequently
   increased by the transaction amount.

5. 4,068 of 4,097 fraud-labelled TRANSFER records
   had unchanged recipient balances.

6. PAYMENT recipient balances could not be
   reconciled because merchant balances are unavailable.

### Limitations

- The comparison uses simplified balance equations.
- The "other" category does not prove data corruption.
- Merchant destination balances cannot be reconciled.
- The observed relationships do not establish causality.
- Further investigation is needed before classifying
  balance differences as data-quality errors.
