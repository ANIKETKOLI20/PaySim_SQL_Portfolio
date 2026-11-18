
# PaySim SQL Portfolio — Analytical Questions Overview

## Overview

This document summarises the ten analytical questions
developed for the PaySim SQL Portfolio.

The questions were designed to demonstrate practical
SQL skills through financial transaction analysis,
aggregation, segmentation, ranking, fraud-label analysis
and balance movement investigation.

Each question is based on the available dataset columns
and documented analytical limitations.

## Analytical Question Summary

| No. | Business Question | Analytical Focus |
|---|---|---|
| Q1 | Which transaction category has the highest transaction count, and what percentage of all transactions does each category represent? | Transaction volume distribution and category contribution. |
| Q2 | Which transaction category has the highest total and average transaction amount? | Monetary value comparison and average transaction size. |
| Q3 | How do transaction counts and total transaction values change across simulation steps? | Hourly simulated transaction trends and activity patterns. |
| Q4 | Which simulation steps rank highest by transaction count, using total transaction value as a tie-breaker? | Ranking transaction activity using multiple metrics. |
| Q5 | Which transaction categories contain the highest number and percentage of fraud-labelled transactions? | Fraud-label distribution, category-level rate and fraud-label concentration. |
| Q6 | How closely do the existing rule-based flags correspond to the simulated fraud labels? | Confusion matrix, precision, recall and flagging limitations. |
| Q7 | How is transaction activity distributed between one-time and repeat-originator accounts, and what proportion of transaction volume and monetary value comes from each group? | Sender activity segmentation and monetary contribution. |
| Q8 | Which recipient identifiers receive the highest transaction counts and monetary values, and how does recipient activity differ between customer and merchant identifiers? | Recipient concentration and customer-versus-merchant analysis. |
| Q9 | How does the distribution of transaction amounts differ across transaction categories and fraud labels? | Average, median, minimum, maximum and transaction amount distribution. |
| Q10 | How do sender and recipient balance movements differ across transaction categories and fraud labels? | Balance reconciliation, transaction behaviour and anomaly investigation. |

## SQL Skills Covered

The analytical questions collectively demonstrate:

- Filtering and sorting
- Aggregate functions
- GROUP BY and HAVING
- Conditional aggregation using CASE WHEN
- Subqueries and Common Table Expressions
- Window functions and ranking
- Percentage calculations
- Statistical measures
- Arithmetic expressions
- Analytical validation and interpretation

## Dataset Limitations

- The dataset contains synthetic mobile-money transactions.
- It primarily provides a single transaction table.
- The step column represents hourly simulation steps, not actual calendar timestamps.
- Merchant destination balance information is unavailable.
- Fraud labels are simulated classifications.
- Transaction value does not represent platform revenue or profit.

All analytical questions are designed around the fields
and limitations actually available in the dataset.

## Detailed Specifications

For detailed business objectives, metric definitions,
data requirements, SQL concepts and analytical limitations,
refer to:

`analytical_questions.md`

## Implementation Status

All ten analytical questions have been developed
and reviewed.

PostgreSQL implementation and result validation
are the next stages of the project.

**Note:** Analytical results will be added after
queries have been implemented and executed.
