
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

### Expected Output

| Transaction Type | Transaction Count | Transaction Share (%) |
|---|---:|---:|
| CASH_OUT | To be calculated | To be calculated |
| PAYMENT | To be calculated | To be calculated |
| CASH_IN | To be calculated | To be calculated |
| TRANSFER | To be calculated | To be calculated |
| DEBIT | To be calculated | To be calculated |

### Limitations

The analysis describes simulated mobile-money
transaction activity, not actual UPI transaction
volume or real-world market demand.

### Results and Interpretation

To be completed after SQL implementation.


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

### Limitations

Transaction value represents simulated monetary
activity, not platform revenue or profit.

The dataset contains synthetic mobile-money
transactions, not actual UPI payment records.

### Results and Interpretation

To be completed after SQL implementation.


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

### Limitations

The step column represents an hourly simulation
index rather than an actual calendar timestamp.

The analysis cannot reliably establish calendar
dates, weekdays or real-world time-of-day patterns.

The results describe simulated transaction
activity rather than actual payment-platform activity.

### Results and Interpretation

To be completed after SQL implementation.


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

### Limitations

The step column represents an hourly simulation
index rather than an actual calendar timestamp.

The ranking describes simulated transaction
activity and should not be interpreted as
real-world payment demand.

### Results and Interpretation

To be completed after SQL implementation.


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

### Limitations

The isFraud column contains existing simulated
fraud labels, not independently verified real-world fraud.

The analysis describes simulated fraud-label patterns
and should not be interpreted as actual UPI fraud rates.

### Results and Interpretation

To be completed after SQL implementation.


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

### Limitations

The isFraud column represents existing simulated
fraud labels, not independently verified real-world fraud.

The isFlaggedFraud column represents a specific
rule-based flagging mechanism.

The analysis evaluates agreement with simulated labels,
not the performance of a production fraud detection system.

### Results and Interpretation

To be completed after SQL implementation.


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
- HAVING
- CASE WHEN
- CTEs
- Window functions
- Percentage calculations

### Limitations

Sender identifiers represent simulated account
identifiers and should not automatically be interpreted
as unique human customers.

High transaction frequency or monetary value
does not independently establish suspicious
or fraudulent behaviour.

### Results and Interpretation

To be completed after SQL implementation.


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
