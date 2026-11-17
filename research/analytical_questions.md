
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
