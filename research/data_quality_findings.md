
# PaySim Data Quality Audit

## 1. Dataset Overview

**Dataset:** Synthetic Financial Datasets For Fraud Detection

**Creator:** Edgar Alonso Lopez-Rojas

**Source:** Kaggle

**Dataset URL:**
https://www.kaggle.com/datasets/ealaxi/paysim1

**Original Research Paper:**
PaySim: A Financial Mobile Money Simulator for Fraud Detection (2016).

**File:** PS_20174392719_1491204439457_log.csv

**File Size:** Approximately 470 MB

**Total Records:** 6,362,620

**Total Columns:** 11

**Data Nature:** Synthetic mobile-money transaction data.

**Time Coverage:** 744 hourly simulation steps are described
in the source documentation. The observed transaction
step range in this CSV is 1 to 743.

---

## 2. Initial Structural Inspection

### Methodology

- Used Python 3.13.13.
- Used Pandas 3.1.1.
- Initially inspected the first 10,000 records.
- Examined column names, inferred data types and sample records.

### Observed Columns

1. step
2. type
3. amount
4. nameOrig
5. oldbalanceOrg
6. newbalanceOrig
7. nameDest
8. oldbalanceDest
9. newbalanceDest
10. isFraud
11. isFlaggedFraud

### Observed Data Types

The first 10,000 records produced these inferred types:

| Column | Pandas dtype |
|---|---|
| step | int64 |
| type | string |
| amount | float64 |
| nameOrig | string |
| oldbalanceOrg | float64 |
| newbalanceOrig | float64 |
| nameDest | string |
| oldbalanceDest | float64 |
| newbalanceDest | float64 |
| isFraud | int64 |
| isFlaggedFraud | int64 |

Note: These inferred data types were initially
observed using a 10,000-record sample.

---

## 3. Missing Value Investigation

### Methodology

- Processed the complete CSV.
- Used Pandas chunk-based reading.
- Chunk size: 100,000 records.
- Used isna().sum() to calculate missing values.
- Calculated column-wise missing percentages.

### Results

Total Records Processed: 6,362,620

Total Missing Values: 0

| Column | Missing Count | Missing Percentage |
|---|---:|---:|
| step | 0 | 0% |
| type | 0 | 0% |
| amount | 0 | 0% |
| nameOrig | 0 | 0% |
| oldbalanceOrg | 0 | 0% |
| newbalanceOrig | 0 | 0% |
| nameDest | 0 | 0% |
| oldbalanceDest | 0 | 0% |
| newbalanceDest | 0 | 0% |
| isFraud | 0 | 0% |
| isFlaggedFraud | 0 | 0% |

### Finding

No missing values were detected by Pandas using
its standard CSV missing-value recognition.

Note: Blank, whitespace-only and structurally
unavailable values should be considered separately.

---

## 4. Exact Duplicate Record Investigation

### Methodology

- Processed the complete CSV.
- Compared all 11 columns.
- Used Python CSV reader and SQLite.
- Processed records in batches of 50,000.
- Compared complete parsed row values.

### Results

| Metric | Value |
|---|---:|
| Total Records | 6,362,620 |
| Unique Records | 6,362,620 |
| Exact Duplicate Rows | 0 |
| Duplicate Percentage | 0.000000% |

### Finding

No exact duplicate records were detected
across the complete dataset.

### Limitation

- The dataset does not provide a dedicated
  transaction ID.
- Repeated sender or recipient identifiers
  do not necessarily indicate duplicate transactions.
- Near-duplicate records were not investigated.

---

## 5. Sender and Recipient Identifier Investigation

### Methodology

- Processed all transaction records.
- Counted sender and recipient identifier occurrences.
- Used SQLite for disk-based frequency aggregation.
- Processed records in batches of 50,000.

### Results

| Metric | Value |
|---|---:|
| Total Records | 6,362,620 |
| Unique Sender IDs | 6,353,307 |
| Sender IDs Appearing More Than Once | 9,298 |
| Unique Recipient IDs | 2,722,362 |
| Recipient IDs Appearing More Than Once | 459,658 |

### Top Frequency Findings

- Highest sender transaction frequency: 3.
- Highest recipient transaction frequency: 113.

### Interpretation

Recipient identifiers appear repeatedly more
frequently than sender identifiers.

This indicates greater concentration of transaction
appearances among receiving identifiers.

### Limitations

- Identifiers do not necessarily represent unique humans.
- Recipient identifiers can represent customer accounts
  or merchant accounts.
- Frequency alone cannot establish fraudulent activity.

---

## 6. Transaction Category Validation

### Methodology

- Processed all 6,362,620 records.
- Counted distinct transaction categories.
- Compared observed categories against
  the five documented expected categories.

### Results

| Transaction Type | Transaction Count |
|---|---:|
| CASH_OUT | 2,237,500 |
| PAYMENT | 2,151,495 |
| CASH_IN | 1,399,284 |
| TRANSFER | 532,909 |
| DEBIT | 41,432 |
| **Total** | **6,362,620** |

Unexpected Category Records: 0

### Finding

All five expected transaction categories were found.

No unexpected category values were detected.

---

## 7. Fraud Flag Validation

### Methodology

Investigated the distinct values and frequencies
of isFraud and isFlaggedFraud.

### isFraud Results

| Value | Records |
|---|---:|
| 0 | 6,354,407 |
| 1 | 8,213 |
| **Total** | **6,362,620** |

### isFlaggedFraud Results

| Value | Records |
|---|---:|
| 0 | 6,362,604 |
| 1 | 16 |
| **Total** | **6,362,620** |

Unexpected Values: 0 in both columns.

### Finding

Both fraud indicator columns contain only
the expected binary values 0 and 1.

Note: isFraud represents the existing simulated
fraud label. isFlaggedFraud represents a separate
rule-based flag. They are not interchangeable.

---

## 8. Numeric Quality Investigation

### Methodology

Investigated six numeric columns:

- step
- amount
- oldbalanceOrg
- newbalanceOrig
- oldbalanceDest
- newbalanceDest

Checked for:

- Blank values
- Non-numeric values
- Non-finite values
- Negative values
- Zero values
- Minimum and maximum values

### Results

| Column | Negative | Zero | Minimum | Maximum |
|---|---:|---:|---:|---:|
| step | 0 | 0 | 1 | 743 |
| amount | 0 | 16 | 0 | 92,445,516.64 |
| oldbalanceOrg | 0 | 2,102,449 | 0 | 59,585,040.37 |
| newbalanceOrig | 0 | 3,609,566 | 0 | 49,585,040.37 |
| oldbalanceDest | 0 | 2,704,388 | 0 | 35,601,588.35 |
| newbalanceDest | 0 | 2,439,433 | 0 | 35,617,928.92 |

No blank, non-numeric, non-finite or negative
values were detected in the investigated columns.

### Range Validation

The step column was checked against the
expected range of 1 to 744.

Observed range: 1 to 743.

Out-of-range step records: 0.

No defined business-range validation was performed
for the other five numeric columns.

### Finding

No negative numeric values were detected.

However, zero values require contextual interpretation
and should not automatically be considered missing.

---

## 9. Zero-Amount Transaction Investigation

### Methodology

- Processed the complete CSV.
- Extracted records where amount = 0.
- Examined transaction type, balances and fraud indicators.

### Results

Total Zero-Amount Transactions: 16

| Attribute | Finding |
|---|---|
| Transaction Type | CASH_OUT |
| isFraud = 1 | 16 |
| isFlaggedFraud = 1 | 0 |
| isFlaggedFraud = 0 | 16 |

All 16 records have:

- Zero transaction amount.
- Zero sender opening balance.
- Zero sender closing balance.
- Unchanged recipient balance.

### Interpretation

All 16 zero-amount records belong to CASH_OUT
and carry the simulated fraud label.

They represent an unusual pattern of zero-value
cash-out transactions.

The precise reason for their classification
cannot be established from the available
transaction fields alone.

### Limitation

These records should not automatically be
classified as invalid or removed.

---

## 10. Balance Consistency Investigation

### Methodology

- Processed all 6,362,620 records.
- Calculated sender balance movement.
- Calculated recipient balance movement.
- Used a numerical tolerance of 0.01.
- Excluded merchant destination balances
  from recipient reconciliation.
- Grouped results by transaction type and fraud label.

### Sender Balance Movement Results

| Type | Fraud | Records | Unchanged | -Amount | +Amount | Other |
|---|---:|---:|---:|---:|---:|---:|
| CASH_IN | 0 | 1,399,284 | 33 | 0 | 1,288,608 | 110,643 |
| CASH_OUT | 0 | 2,233,384 | 1,025,764 | 243,069 | 0 | 964,551 |
| CASH_OUT | 1 | 4,116 | 37 | 4,076 | 0 | 3 |
| DEBIT | 0 | 41,432 | 6,158 | 29,089 | 0 | 6,185 |
| PAYMENT | 0 | 2,151,495 | 774,245 | 995,783 | 0 | 381,467 |
| TRANSFER | 0 | 528,812 | 282,780 | 20,085 | 0 | 225,947 |
| TRANSFER | 1 | 4,097 | 20 | 4,076 | 0 | 1 |
| **Total** | | **6,362,620** | | | | |

### Recipient Balance Movement Results

Merchant destination balances were not reconciled.

| Type | Fraud | Non-Merchant | Merchant | Unchanged | +Amount | -Amount | Other |
|---|---:|---:|---:|---:|---:|---:|---:|
| CASH_IN | 0 | 1,399,284 | 0 | 160,005 | 0 | 893,650 | 345,629 |
| CASH_OUT | 0 | 2,233,384 | 0 | 1,600 | 1,790,383 | 0 | 441,401 |
| CASH_OUT | 1 | 4,116 | 0 | 18 | 3,577 | 0 | 521 |
| DEBIT | 0 | 41,432 | 0 | 0 | 33,174 | 0 | 8,258 |
| PAYMENT | 0 | 0 | 2,151,495 | 0 | 0 | 0 | 0 |
| TRANSFER | 0 | 528,812 | 0 | 106 | 413,357 | 0 | 115,349 |
| TRANSFER | 1 | 4,097 | 0 | 4,068 | 2 | 0 | 27 |

For PAYMENT, the recipient balance movement
categories were not assessed because all recipient
identifiers in this group were merchant identifiers.

### Key Findings

1. CASH_IN sender balances frequently increased
   by the transaction amount.

2. Non-fraud CASH_OUT sender balances showed
   substantial unchanged and other movements.

3. Fraud-labelled TRANSFER records frequently
   had unchanged sender or recipient balances.

4. Non-fraud TRANSFER recipient balances frequently
   increased by the transaction amount.

5. Merchant destination balances were unavailable
   for reconciliation.

### Limitations

- The comparisons use simplified balance equations.
- The "other" classification does not prove
  transaction invalidity or data corruption.
- Merchant destination balances are unavailable.
- Balance differences need transaction-level
  investigation before being classified as errors.

---

## 11. Overall Data Quality Assessment

| Dimension | Finding | Assessment |
|---|---|---|
| Dataset structure | 11 expected columns | Verified |
| Missing values | 0 detected | Passed |
| Exact duplicates | 0 detected | Passed |
| Transaction categories | Five expected categories | Passed |
| Fraud indicators | Only 0 and 1 | Passed |
| Negative numeric values | 0 detected | Passed |
| Simulation step range | 1 to 743 | Passed |
| Zero-amount transactions | 16 records | Requires interpretation |
| Identifier frequency | Repeated identifiers present | Expected behaviour to investigate |
| Balance consistency | Different balance movement patterns | Requires interpretation |
| Merchant balances | Unavailable | Dataset limitation |

### Overall Conclusion

The PaySim dataset passed the initial structural,
missing-value, exact-duplicate, category and
fraud-flag investigations.

However, the presence of zero-amount transactions,
numerous zero balances and differences from
simplified balance equations requires careful
interpretation.

The dataset is suitable for SQL analysis, provided
its synthetic nature, balance limitations and
identifier constraints are documented.

No records were removed or modified during
these investigations.

---

## 12. Dataset Limitations and Analytical Precautions

1. PaySim is synthetic data rather than actual
   production payment transaction data.

2. The dataset primarily provides one transaction
   table and has limited natural relational joins.

3. It does not contain a dedicated transaction ID.

4. The step field represents hourly simulation
   steps rather than actual calendar timestamps.

5. Merchant destination balance information
   is unavailable.

6. Repeated sender and recipient identifiers
   do not establish duplicate transactions.

7. Existing fraud labels must be distinguished
   from rule-based fraud flags.

8. Observed balance discrepancies should not
   automatically be treated as data corruption.

9. Findings from the simulated data should not
   automatically be generalised to real-world
   mobile-money or UPI platforms.


## Simulation Step Coverage

### Published Dataset Description

The published PaySim dataset description
refers to 744 hourly simulation steps.

### Actual CSV Investigation

| Metric | Observed Result |
|---|---:|
| Minimum step | 1 |
| Maximum step | 743 |
| Distinct steps | 743 |
| Grouped hourly records | 743 |

### Finding

The actual CSV contains populated simulation
steps from 1 through 743.

All 743 steps within this observed range
are represented.

The published description refers to 744 steps,
while the actual CSV contains 743 distinct
populated step values.

### Limitation

The reason for this discrepancy has not been
established.

The original dataset was not modified to
introduce an additional simulation step.

All analysis uses the actual observed records.
