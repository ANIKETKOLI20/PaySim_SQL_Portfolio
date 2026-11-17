
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
