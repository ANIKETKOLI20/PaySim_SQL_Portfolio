
# PaySim Analytical Questions

## Q1. Transaction Volume Distribution

### Business Question

Which transaction category has the highest transaction
count, and what percentage of all transactions does
each category represent?

### Objective

Understand the distribution of simulated transaction
activity across transaction categories.

### Data Requirements

- type

### Analytical Definitions

- Dimension: Transaction type
- Metric 1: Transaction count
- Metric 2: Percentage of total transactions
- Numerator: Transaction count for each category
- Denominator: Total transaction records
- Verified dataset records: 6,362,620

### Metric Calculation

Transaction Count = COUNT(*)

Transaction Share (%) =
(Category Transaction Count / Total Transaction Count) * 100

### SQL Concepts

- COUNT
- GROUP BY
- ORDER BY
- Window functions
- Percentage calculation

### Results and Interpretation

#### Actual Query Results

| Transaction Type | Transaction Count | Transaction Share (%) |
|---|---:|---:|
| CASH_OUT | 2,237,500 | 35.17 |
| PAYMENT | 2,151,495 | 33.81 |
| CASH_IN | 1,399,284 | 21.99 |
| TRANSFER | 532,909 | 8.38 |
| DEBIT | 41,432 | 0.65 |
| **Total** | **6,362,620** | **100.00** |

#### Key Findings

1. CASH_OUT represents the highest transaction
   volume, accounting for 35.17% of all records.

2. PAYMENT represents the second-highest
   transaction volume at 33.81%.

3. CASH_OUT and PAYMENT together account for
   68.98% of total transaction records.

4. DEBIT represents the lowest transaction
   volume at 0.65%.

#### Validation

- Total category transaction counts match the
  imported PostgreSQL record count.
- Category counts reconcile with the earlier
  Python transaction category audit.
- Transaction share percentages sum to 100%.

#### Interpretation

CASH_OUT and PAYMENT account for the largest
proportions of simulated transaction activity.

The findings describe transaction frequency
and do not establish which category contributes
the highest monetary value or platform revenue.

### Limitations

The analysis describes simulated mobile-money
transaction activity, not actual UPI transaction
volume or real-world market demand.


## Q2. Transaction Monetary Analysis

### Business Question

Which transaction category has the highest total
and average transaction amount?

### Objective

Compare the aggregate monetary value and
average transaction size across transaction categories.

### Data Requirements

- type
- amount

### Analytical Definitions

- Dimension: Transaction type
- Metric 1: Total transaction value
- Metric 2: Average transaction value

### Metric Calculation

Total Transaction Value = SUM(amount)

Average Transaction Value =
SUM(amount) / COUNT(*)

### SQL Concepts

- SUM
- AVG
- GROUP BY
- ORDER BY


### Results and Interpretation

#### Actual Query Results

| Transaction Type | Transaction Count | Total Transaction Value | Average Transaction Amount |
|---|---:|---:|---:|
| TRANSFER | 532,909 | 485,291,987,263.17 | 910,647.01 |
| CASH_OUT | 2,237,500 | 394,412,995,224.49 | 176,273.96 |
| CASH_IN | 1,399,284 | 236,367,391,912.46 | 168,920.24 |
| PAYMENT | 2,151,495 | 28,093,371,138.37 | 13,057.60 |
| DEBIT | 41,432 | 227,199,221.28 | 5,483.67 |

#### Key Findings

1. TRANSFER has the highest total transaction
   value, accounting for the largest monetary
   contribution among the five categories.

2. TRANSFER also has the highest average
   transaction amount.

3. CASH_OUT has the highest transaction count
   but ranks second in total transaction value.

4. PAYMENT has substantial transaction volume
   but comparatively low average transaction value.

#### Validation

- Category transaction counts match the
  previously validated Python audit.
- Category monetary totals sum to the overall
  transaction value of 1,144,392,944,759.77.
- Average amounts are calculated using the
  number of transactions in each category.

#### Interpretation

Transaction volume and monetary value exhibit
different patterns across transaction categories.

TRANSFER contributes the highest total
transaction value despite having considerably
fewer transactions than CASH_OUT and PAYMENT.

The findings describe simulated monetary activity
and must not be interpreted as platform revenue,
profit or actual UPI payment behaviour.


### Limitations

Transaction value represents simulated monetary
activity, not platform revenue or profit.

The dataset contains synthetic mobile-money
transactions, not actual UPI payment records.


## Q3. Hourly Transaction Trends

### Business Question

How do transaction counts and total transaction
values change across simulation steps?

### Objective

Understand changes in simulated transaction
activity over time and identify high-activity
and low-activity simulation steps.

### Data Requirements

- step
- type
- amount

### Analytical Definitions

- Dimension: Simulation step
- Additional dimension: Transaction type
- Metric 1: Transaction count
- Metric 2: Total transaction value

### Metric Calculation

Transaction Count = COUNT(*)

Total Transaction Value = SUM(amount)

### SQL Concepts

- GROUP BY
- COUNT
- SUM
- ORDER BY
- CASE WHEN
- Window functions


### Results and Interpretation

#### Actual Query Results — Selected Simulation Steps

| Step | Transaction Count | Total Transaction Value |
|---:|---:|---:|
| 1 | 2,708 | 285,429,181.15 |
| 2 | 1,014 | 85,921,604.02 |
| 3 | 552 | 43,293,884.42 |
| 4 | 565 | 72,910,028.57 |
| 5 | 665 | 45,548,089.75 |
| 739 | 10 | 16,587,831.36 |
| 740 | 6 | 7,632,963.58 |
| 741 | 22 | 87,828,992.99 |
| 742 | 14 | 14,323,735.20 |
| 743 | 8 | 17,519,825.50 |

#### Key Findings

1. Transaction counts and total transaction
   values vary across simulation steps.

2. Transaction frequency and monetary value
   do not necessarily move together.

3. Step 743 records a higher total transaction
   value than Step 739 despite having fewer
   transactions.

4. The average transaction amount at Step 743
   is approximately 2,189,978.19, compared with
   1,658,783.14 at Step 739.

#### Validation

- First observed step: 1
- Last observed step: 743
- Distinct observed steps: 743
- Hourly aggregation output rows: 743
- No missing simulation steps within the
  observed range of 1–743.

#### Interpretation

Transaction frequency and monetary value show
different patterns across simulation steps.

A smaller number of transactions can generate
a higher total transaction value when the
average transaction amount is higher.

A high average transaction amount alone does
not establish suspicious activity or fraud.

The analysis describes simulated hourly
transaction activity, not actual calendar-hour
payment behaviour.


### Limitations

The step column represents an hourly simulation
index rather than an actual calendar timestamp.

The analysis cannot reliably establish calendar
dates, weekdays or real-world time-of-day patterns.

The results describe simulated transaction
activity rather than actual payment-platform activity.



## Q4. Ranking Transaction Activity

### Business Question

Which simulation steps rank highest by transaction
count, using total transaction value as a tie-breaker?

### Objective

Identify simulation steps with the highest transaction
activity and prioritise them using a consistent
ranking methodology.

### Data Requirements

- step
- amount

### Analytical Definitions

- Dimension: Simulation step
- Primary metric: Transaction count
- Secondary metric: Total transaction value

### Ranking Rules

1. Higher transaction count receives priority.
2. If transaction counts tie, higher total
   transaction value receives priority.
3. If both metrics tie, lower simulation step
   receives priority for deterministic ordering.

### Metric Calculation

Transaction Count = COUNT(*)

Total Transaction Value = SUM(amount)

### SQL Concepts

- GROUP BY
- COUNT
- SUM
- ROW_NUMBER
- Window functions
- ORDER BY


### Results and Interpretation

#### Ranking Methodology

Simulation steps were ranked using the following
criteria:

1. Transaction count — descending.
2. Total transaction value — descending.
3. Simulation step — ascending.

ROW_NUMBER() was used to assign a unique ranking
position to each simulation step.

#### Actual Query Results — Top 5

| Rank | Step | Transaction Count | Total Transaction Value |
|---:|---:|---:|---:|
| 1 | 19 | 51,352 | 71,038,465,529.97 |
| 2 | 18 | 49,579 | 72,550,715,178.26 |
| 3 | 187 | 49,083 | 73,912,594,959.56 |
| 4 | 235 | 47,491 | 72,981,450,078.92 |
| 5 | 307 | 46,968 | 85,120,050,039.48 |

#### Key Findings

1. Simulation Step 19 ranks first with 51,352
   transactions, representing the highest observed
   transaction count among all simulation steps.

2. Step 18 ranks second with 49,579 transactions.

3. Step 307 has the highest total transaction value
   among the displayed top five steps, but ranks fifth
   because transaction count is the primary ranking
   criterion.

4. Transaction frequency and total transaction value
   do not necessarily produce the same ranking.

#### Validation

| Validation Metric | Actual Result |
|---|---:|
| Total ranked simulation steps | 743 |
| Unique ranking positions | 743 |
| First ranking position | 1 |
| Last ranking position | 743 |

All 743 observed simulation steps received a unique
ranking position.

#### Interpretation

The ranking demonstrates that the simulation step
with the highest transaction count does not
necessarily have the highest monetary value.

Step 19 ranks first because transaction frequency
is the primary ranking criterion.

Step 307 generates a higher total transaction value
than Step 19 but ranks fifth because its transaction
count is lower.

This illustrates the importance of defining ranking
criteria according to the analytical objective.

The results describe simulated hourly transaction
activity and should not be interpreted as evidence
of fraud, suspicious behaviour or real-world payment
performance.

### Limitations

The step column represents an hourly simulation
index rather than an actual calendar timestamp.

The ranking describes simulated transaction
activity and should not be interpreted as
real-world payment demand.


## Q5. Fraud-Labelled Transaction Analysis

### Business Question

Which transaction categories contain the highest
number and percentage of fraud-labelled transactions?

### Objective

Understand how simulated fraud-labelled transactions
are distributed across transaction categories.

### Data Requirements

- type
- isFraud

### Analytical Definitions

- Dimension: Transaction type
- Metric 1: Fraud-labelled transaction count
- Metric 2: Within-category fraud-label rate
- Metric 3: Share of all fraud-labelled transactions

### Metric Calculations

Fraud-labelled Transaction Count =
COUNT of records where isFraud = 1

Within-Category Fraud-Label Rate (%) =
(Fraud-labelled transactions in category /
Total transactions in category) * 100

Share of All Fraud-Labelled Transactions (%) =
(Fraud-labelled transactions in category /
Total fraud-labelled transactions) * 100

### SQL Concepts

- COUNT
- GROUP BY
- CASE WHEN
- Conditional aggregation
- CTEs
- Percentage calculation


### Results and Interpretation

#### Actual Query Results

| Transaction Type | Total Transactions | Fraud-Labelled Count | Category Fraud-Label Rate (%) | Fraud-Label Concentration (%) |
|---|---:|---:|---:|---:|
| CASH_OUT | 2,237,500 | 4,116 | 0.18 | 50.12 |
| TRANSFER | 532,909 | 4,097 | 0.77 | 49.88 |
| CASH_IN | 1,399,284 | 0 | 0.00 | 0.00 |
| DEBIT | 41,432 | 0 | 0.00 | 0.00 |
| PAYMENT | 2,151,495 | 0 | 0.00 | 0.00 |
| **Total** | **6,362,620** | **8,213** | — | **100.00** |

#### Key Findings

1. CASH_OUT contains the highest number of
   fraud-labelled transactions, with 4,116 records.

2. TRANSFER contains 4,097 fraud-labelled
   transactions, only 19 fewer than CASH_OUT.

3. TRANSFER has the highest category fraud-label
   rate at 0.77%, compared with 0.18% for CASH_OUT.

4. CASH_OUT contributes 50.12% of all
   fraud-labelled transactions, while TRANSFER
   contributes 49.88%.

5. CASH_IN, DEBIT and PAYMENT contain no
   fraud-labelled transactions in this dataset.

#### Validation

- Total transactions: 6,362,620.
- Total fraud-labelled transactions: 8,213.
- CASH_OUT and TRANSFER account for all
  8,213 fraud-labelled transactions.
- Category fraud-label rates use total transactions
  within each respective category as the denominator.
- Fraud-label concentration uses all fraud-labelled
  transactions as the denominator.
- Fraud-label concentration percentages sum to 100%.

#### Interpretation

The distribution of fraud-labelled transactions
shows a difference between fraud-label count and
category fraud-label rate.

CASH_OUT has the highest fraud-labelled transaction
count because it contains 4,116 such records.

However, TRANSFER has a higher category fraud-label
rate because its fraud-labelled transaction count
is distributed across a considerably smaller
transaction population.

TRANSFER's category fraud-label rate is approximately
4.2 times that of CASH_OUT.

The concentration analysis also shows that
fraud-labelled transactions are distributed almost
equally between CASH_OUT and TRANSFER.

These findings demonstrate why transaction counts,
category-level rates and fraud-label concentration
must be evaluated separately.

The analysis describes simulated fraud labels and
does not establish independently confirmed fraud
or actual production payment-platform behaviour.


### Limitations

The isFraud column contains existing simulated
fraud labels, not independently verified real-world fraud.

The analysis describes simulated fraud-label patterns
and should not be interpreted as actual UPI fraud rates.


## Q6. Fraud Flag vs Fraud Label Analysis

### Business Question

How closely do the existing rule-based flags correspond
to the simulated fraud labels?

### Objective

Evaluate the relationship between the existing
fraud labels and the rule-based flagging mechanism.

### Data Requirements

- isFraud
- isFlaggedFraud
- type
- amount

### Analytical Definitions

Reference Label: isFraud

Rule-Based Prediction: isFlaggedFraud

### Confusion Matrix Metrics

- True Positives (TP): Fraud-labelled and flagged.
- False Positives (FP): Not fraud-labelled but flagged.
- False Negatives (FN): Fraud-labelled but not flagged.
- True Negatives (TN): Neither fraud-labelled nor flagged.

### Performance Metrics

Precision = TP / (TP + FP)

Recall = TP / (TP + FN)

False Positive Rate = FP / (FP + TN)

### SQL Concepts

- CASE WHEN
- Conditional aggregation
- COUNT
- GROUP BY
- CTEs
- Percentage calculations

### Results and Interpretation

#### Actual Query Results — Confusion Matrix

| Classification Outcome | Transaction Count |
|---|---:|
| True Positives (TP) | 16 |
| False Positives (FP) | 0 |
| False Negatives (FN) | 8,197 |
| True Negatives (TN) | 6,354,407 |
| **Total Transactions** | **6,362,620** |

#### Rule Evaluation Metrics

| Metric | Actual Result |
|---|---:|
| Precision | 100.00% |
| Recall | 0.19% |

#### Key Findings

1. The existing rule flagged 16 transactions,
   and all 16 carried the simulation's fraud label.

2. No false positives were observed in the dataset.

3. The rule failed to flag 8,197 fraud-labelled
   transactions.

4. The rule achieved 100% precision but only
   0.19% recall against the simulation labels.

5. Approximately 99.81% of all fraud-labelled
   transactions were not identified by the rule.

#### Validation

- Total transactions: 6,362,620.
- Total fraud-labelled transactions: 8,213.
- Total rule-flagged transactions: 16.
- True positives + False positives: 16.
- True positives + False negatives: 8,213.
- All four confusion matrix outcomes sum to
  the total transaction count.

#### Interpretation

The existing rule demonstrates high precision
but extremely low recall against the simulation's
fraud labels.

Its 100% precision indicates that every
transaction flagged by the rule also carries
the simulation's fraud label.

However, its 0.19% recall demonstrates that
the rule identifies only 16 out of 8,213
fraud-labelled transactions.

The remaining 8,197 fraud-labelled transactions
were not identified by the existing rule.

This demonstrates that precision alone is
insufficient when evaluating a rule-based
fraud detection mechanism.

A rule can avoid false positives among the
transactions it flags while still missing
the overwhelming majority of fraud-labelled
transactions.

#### Limitations

- The analysis evaluates alignment with
  PaySim's simulated fraud labels.
- The simulated fraud labels are treated as
  reference classifications, not independently
  verified real-world fraud outcomes.
- Precision and recall describe this dataset's
  classification results, not the effectiveness
  of a production fraud detection system.

The findings should not be interpreted as
evidence of actual financial losses or
real-world fraud detection performance.



## Q7. Sender Activity Distribution Analysis

### Business Question

How is transaction activity distributed between
one-time and repeat-originator account identifiers,
and what proportion of transaction volume and
monetary value comes from each group?

### Objective

Understand sender activity patterns by identifying
one-time and repeat-originator accounts and
comparing their transaction and monetary contributions.

### Data Requirements

- nameOrig
- amount

### Analytical Definitions

- Dimension: Sender activity segment
- Account identifier: nameOrig
- One-time sender: Exactly one transaction
- Repeat sender: More than one transaction

### Metrics

1. Distinct sender identifiers
2. Transaction count
3. Total transaction amount
4. Transaction volume share (%)
5. Monetary value share (%)

### Metric Calculations

Transaction Count = COUNT(*)

Total Transaction Amount = SUM(amount)

Transaction Volume Share (%) =
(Segment Transaction Count / Total Transaction Count) * 100

Monetary Value Share (%) =
(Segment Total Transaction Amount / Overall Transaction Amount) * 100

### SQL Concepts

- GROUP BY
- COUNT
- SUM
- CASE WHEN
- CTEs
- Window functions

### Results and Interpretation

#### Actual Query Results — Top 10 Sender Accounts

| Rank | Sender ID | Transaction Count | Total Transaction Value | Average Transaction Amount |
|---:|---|---:|---:|---:|
| 1 | C545315117 | 3 | 2,485,461.64 | 828,487.21 |
| 2 | C724452879 | 3 | 838,815.30 | 279,605.10 |
| 3 | C1902386530 | 3 | 763,712.79 | 254,570.93 |
| 4 | C1976208114 | 3 | 511,130.35 | 170,376.78 |
| 5 | C1530544995 | 3 | 490,535.09 | 163,511.70 |
| 6 | C1784010646 | 3 | 436,700.25 | 145,566.75 |
| 7 | C2098525306 | 3 | 378,102.22 | 126,034.07 |
| 8 | C1832548028 | 3 | 313,665.83 | 104,555.28 |
| 9 | C1999539787 | 3 | 290,555.01 | 96,851.67 |
| 10 | C1677795071 | 3 | 244,735.38 | 81,578.46 |

#### Sender Activity Distribution

| Metric | Actual Result |
|---|---:|
| Total distinct sender accounts | 6,353,307 |
| Single-transaction sender accounts | 6,344,009 |
| Repeat sender accounts | 9,298 |
| Maximum transactions per sender | 3 |
| Single-transaction sender share | 99.85% |
| Repeat sender account share | 0.15% |

#### Key Findings

1. The dataset contains 6,353,307 distinct
   originating sender accounts.

2. Approximately 99.85% of sender accounts
   appear in only one transaction.

3. Only 9,298 sender accounts perform more
   than one transaction.

4. No sender account performs more than
   three transactions in the dataset.

5. All ten highest-ranked sender accounts
   have exactly three transactions.

6. Since the top ten accounts have identical
   transaction counts, total transaction value
   determines their ranking.

7. Sender C545315117 has the highest total
   transaction value among the top ten accounts,
   contributing 2,485,461.64 across three
   transactions.

#### Validation

| Validation Metric | Actual Result |
|---|---:|
| Sender groups | 6,353,307 |
| Distinct sender accounts | 6,353,307 |
| Reconciled transaction count | 6,362,620 |
| Top-ten result rows | 10 |
| First ranking position | 1 |
| Last ranking position | 10 |
| Maximum transactions per sender | 3 |

All sender groups and transaction records
reconciled successfully.

All three validation checks returned TRUE:
sender group reconciliation, transaction count
reconciliation and top-ten reconciliation.

#### Interpretation

The sender-level analysis reveals that transaction
activity is highly dispersed across originating
accounts.

Almost all sender accounts appear in only one
transaction, while a very small proportion
perform repeat transactions.

The maximum observed transaction frequency
for a sender account is three.

The top-ten results also demonstrate that
transaction frequency and monetary contribution
provide different perspectives on sender activity.

Because all ten leading accounts have identical
transaction counts, monetary contribution
becomes the determining ranking criterion.

These findings describe the structure of
simulated sender-account activity and should
not be interpreted as actual customer engagement,
customer retention or real-world banking behaviour.

#### Limitations

- Sender identifiers represent originating
  accounts in the simulated dataset, not
  independently verified individual customers.
- Transaction frequency does not establish
  customer engagement or relationship quality.
- Monetary contribution represents the sum
  of recorded transaction amounts, not revenue.
- The results are specific to the supplied
  synthetic dataset.



## Q8. Recipient Transaction Concentration

### Business Question

Which recipient identifiers receive the highest
transaction counts and monetary values, and how
does recipient activity differ between customer
and merchant identifiers?

### Objective

Understand transaction concentration across
customer and merchant receiving accounts.

### Data Requirements

- nameDest
- amount
- type
- isFraud

### Analytical Definitions

- Primary dimension: Recipient type
- Recipient identifier: nameDest
- Customer identifier: Starts with C
- Merchant identifier: Starts with M

### Metrics

1. Distinct recipient identifiers
2. Transaction count
3. Total transaction value
4. Average transaction value
5. Share of total transaction value

### Metric Calculations

Transaction Count = COUNT(*)

Total Transaction Value = SUM(amount)

Average Transaction Value = AVG(amount)

Transaction Value Share (%) =
(Segment Transaction Value / Overall Transaction Value) * 100

### SQL Concepts

- CASE WHEN
- GROUP BY
- COUNT
- SUM
- AVG
- CTEs
- Window functions
- Percentage calculations

### Limitations

Recipient identifiers represent simulated account
identifiers, not verified human identities.

Merchant and customer receiving activities
should be analysed separately.

Transaction value does not represent platform
revenue or profit.

Merchant destination balance information is
unavailable in the dataset.

### Results and Interpretation

To be completed after SQL implementation.


## Q9. Transaction Amount Distribution Analysis

### Business Question

How does the distribution of transaction amounts
differ across transaction categories and fraud labels?

### Objective

Understand transaction amount characteristics
and identify differences between transaction
categories and fraud-labelled groups.

### Data Requirements

- type
- amount
- isFraud

### Analytical Definitions

- Primary dimension: Transaction type
- Secondary dimension: Fraud label
- Metric 1: Transaction count
- Metric 2: Average transaction amount
- Metric 3: Median transaction amount
- Metric 4: Minimum transaction amount
- Metric 5: Maximum transaction amount

### Metric Calculations

Transaction Count = COUNT(*)

Average Amount = AVG(amount)

Median Amount = PERCENTILE_CONT(0.5)
WITHIN GROUP (ORDER BY amount)

Minimum Amount = MIN(amount)

Maximum Amount = MAX(amount)

### SQL Concepts

- COUNT
- AVG
- MEDIAN calculation
- MIN
- MAX
- GROUP BY
- CASE WHEN
- Conditional aggregation

### Limitations

The analysis uses simulated mobile-money
transaction amounts.

Average values may be influenced by
extremely large transactions.

Median values provide additional context
about the middle of the transaction distribution.

Existing fraud labels are simulated labels
and not independently verified real-world fraud.

### Results and Interpretation

To be completed after SQL implementation.


## Q10. Balance Movement Analysis

### Business Question

How do sender and recipient balance movements differ
across transaction categories and fraud labels?

### Objective

Investigate transaction-related balance movements
and understand differences across transaction types
and simulated fraud classifications.

### Data Requirements

- type
- amount
- isFraud
- nameDest
- oldbalanceOrg
- newbalanceOrig
- oldbalanceDest
- newbalanceDest

### Analytical Definitions

- Primary dimension: Transaction type
- Secondary dimension: Fraud label
- Sender balance movement:
  newbalanceOrig - oldbalanceOrg
- Recipient balance movement:
  newbalanceDest - oldbalanceDest

### Analytical Comparisons

- Sender balance movement against expected movement.
- Recipient balance movement against expected movement.
- Balance movement differences by transaction type.
- Balance movement differences by fraud label.

### SQL Concepts

- Arithmetic expressions
- CASE WHEN
- CTEs
- GROUP BY
- Conditional aggregation
- Aggregate functions

### Limitations

Different transaction categories may have
different balance movement expectations.

A single universal balance equation must not
be applied to all transaction categories.

Merchant destination balance information is
unavailable and must be excluded from recipient
balance reconciliation.

Balance discrepancies do not automatically
establish data corruption or fraudulent behaviour.

Existing fraud classifications are simulated labels.

### Results and Interpretation

To be completed after SQL implementation.
