# PaySim SQL Portfolio

## Project Overview

This project demonstrates practical SQL and analytical skills using the PaySim synthetic mobile-money transaction dataset.

The primary objective is to develop hands-on experience in querying financial transaction data, analysing transaction patterns, performing aggregations, investigating simulated fraud indicators, and validating analytical results.

The project follows a structured analytical workflow, from dataset discovery and data-quality investigation to PostgreSQL-based SQL implementation and business interpretation.

## Project Objectives

- Understand and profile a large financial transaction dataset.
- Investigate missing values, duplicate records, identifiers and data-quality issues.
- Develop meaningful analytical questions based on available data.
- Implement analytical queries using PostgreSQL.
- Apply SQL aggregations, joins where appropriate, CTEs, subqueries and window functions.
- Validate query results and interpret findings.
- Document the analysis in a reproducible GitHub repository.

## Dataset Information

**Dataset:** Synthetic Financial Datasets For Fraud Detection

**Creator:** Edgar Alonso Lopez-Rojas

**Source:** Kaggle  
https://www.kaggle.com/datasets/ealaxi/paysim1

**Original Research Paper:**  
PaySim: A Financial Mobile Money Simulator for Fraud Detection (2016).

**Licence:** CC BY-SA 4.0  
https://creativecommons.org/licenses/by-sa/4.0/

**Original File:** `PS_20174392719_1491204439457_log.csv`

**File Size:** Approximately 470 MB

**Total Records:** 6,362,620

**Total Columns:** 11

**Data Granularity:** One row represents one transaction.

The original CSV is not included in this repository. Obtain it from the original dataset source.

## Dataset Structure

The dataset contains the following columns:

| Column | Description |
|---|---|
| step | Hourly simulation step |
| type | Transaction category |
| amount | Individual transaction amount |
| nameOrig | Sender account identifier |
| oldbalanceOrg | Sender balance before transaction |
| newbalanceOrig | Sender balance after transaction |
| nameDest | Recipient account identifier |
| oldbalanceDest | Recipient balance before transaction |
| newbalanceDest | Recipient balance after transaction |
| isFraud | Simulated fraud label |
| isFlaggedFraud | Rule-based fraud flag |

The five transaction categories are:

- CASH_IN
- CASH_OUT
- DEBIT
- PAYMENT
- TRANSFER

## Project Workflow

### Phase 1 — Dataset Discovery and Selection

**Status: Completed**

- Discovered and evaluated publicly available financial datasets.
- Selected PaySim based on its transaction-level structure and financial relevance.
- Reviewed dataset documentation, source and licence.
- Examined the original research paper.
- Documented dataset characteristics and limitations.

### Phase 2 — Setup and Data Understanding

**Status: Completed**

Used Python and Pandas to inspect and investigate the complete dataset.

Completed investigations:

1. Initial CSV structure and column inspection.
2. Full-dataset missing-value investigation.
3. Exact duplicate record investigation.
4. Sender and recipient identifier frequency analysis.
5. Transaction category validation.
6. Fraud flag value validation.
7. Numeric quality investigation.
8. Zero-amount transaction investigation.
9. Sender and recipient balance consistency investigation.
10. Consolidation of data-quality findings.

#### Key Data Quality Findings

| Investigation | Actual finding |
|---|---|
| Total records | 6,362,620 |
| Total columns | 11 |
| Missing values detected | 0 |
| Exact duplicate records | 0 |
| Unexpected transaction categories | 0 |
| Unexpected fraud flag values | 0 |
| Negative numeric values detected | 0 |
| Zero-amount transactions | 16 |

Additional observations:

- Five expected transaction categories were identified.
- All 16 zero-amount transactions were CASH_OUT records carrying the simulated fraud label.
- Recipient identifiers were repeated more frequently than sender identifiers.
- Balance movements differed across transaction categories and fraud labels.
- Merchant destination balance information is unavailable for reconciliation.

Detailed investigation results and limitations are documented in `research/data_quality_findings.md`.

### Phase 3 — Analytical Question Discovery

**Status: Completed**

Developed and validated ten analytical questions based on the actual dataset structure and available columns.

| No. | Analytical Question | Primary SQL Concepts |
|---|---|---|
| Q1 | Transaction volume distribution | COUNT, GROUP BY, percentage calculations |
| Q2 | Transaction monetary analysis | SUM, AVG, GROUP BY |
| Q3 | Hourly transaction trends | GROUP BY, COUNT, SUM |
| Q4 | Ranking transaction activity | ROW_NUMBER, window functions |
| Q5 | Fraud-labelled transaction analysis | CASE WHEN, conditional aggregation |
| Q6 | Fraud flag versus fraud label analysis | CTEs, conditional aggregation, confusion matrix |
| Q7 | Sender activity distribution | GROUP BY, HAVING, SUM, COUNT |
| Q8 | Recipient transaction concentration | CASE WHEN, aggregation, window functions |
| Q9 | Transaction amount distribution | AVG, median, MIN, MAX |
| Q10 | Balance movement analysis | Arithmetic expressions, CASE WHEN, CTEs |

Detailed question specifications are maintained in `research/analytical_questions.md`.

### Phase 4 — PostgreSQL Setup and SQL Implementation

**Status: In Progress**

- Installed PostgreSQL 18.7.
- Verified PostgreSQL server service.
- Established a successful local database connection.
- Preparing the project database and transaction table.
- Preparing to import and validate the PaySim dataset.
- SQL implementation of Q1–Q10 is pending.

PostgreSQL is the primary database platform for the analytical queries.

### Phase 5 — Validation and Interpretation

**Status: Planned**

- Validate SQL query results.
- Reconcile record counts and monetary totals.
- Check join behaviour where applicable.
- Review metric definitions and denominators.
- Interpret results using documented assumptions and limitations.

### Phase 6 — Portfolio Publication

**Status: In Progress**

- Maintain executable scripts and documentation on GitHub.
- Publish analytical results and validation evidence.
- Prepare a LinkedIn project showcase.

### Phase 7 — Interview Readiness

**Status: Planned**

- Explain query logic and SQL concepts.
- Justify analytical decisions and metric definitions.
- Discuss data-quality findings and limitations.
- Solve variations of the analytical questions independently.

## Technology Stack

| Technology | Purpose |
|---|---|
| PostgreSQL 18.7 | Database management and SQL analysis |
| SQL | Analytical query implementation |
| Python 3.13.13 | Data inspection and profiling |
| Pandas 3.1.1 | Data manipulation and initial auditing |
| SQLite | Temporary disk-based audit operations |
| Git | Version control |
| GitHub | Project documentation and publication |

## Repository Structure

```text
PaySim_SQL_Portfolio/
│
├── data/
│   └── original/
│       └── Original CSV (local only)
│
├── research/
│   ├── dataset_source_notes.md
│   ├── data_quality_findings.md
│   ├── analytical_questions.md
│   ├── missing_value_audit.csv
│   ├── exact_duplicate_audit.csv
│   ├── identifier_frequency_summary.csv
│   ├── transaction_category_counts.csv
│   ├── fraud_flag_value_counts.csv
│   ├── numeric_quality_summary.csv
│   ├── zero_amount_summary.csv
│   ├── zero_amount_transactions.csv
│   ├── sender_balance_movement.csv
│   ├── recipient_balance_movement.csv
│   ├── top_10_senders.csv
│   └── top_10_recipients.csv
│
├── scripts/
│   ├── 01_initial_csv_inspection.py
│   ├── 02_missing_value_audit.py
│   ├── 03_exact_duplicate_audit.py
│   ├── 04_identifier_frequency_audit.py
│   ├── 05_category_flag_validation.py
│   ├── 06_zero_amount_audit.py
│   └── 07_balance_consistency_audit.py
│
├── sql/
│   └── PostgreSQL analytical queries (in progress)
│
├── .gitignore
└── README.md
```

## Important Dataset Limitations

- PaySim contains synthetic financial transactions rather than actual production payment records.
- The dataset primarily provides a single transaction table with limited natural opportunities for relational joins.
- It does not contain a dedicated transaction ID.
- The step column represents hourly simulation steps, not actual calendar timestamps.
- Merchant destination balance information is unavailable.
- Existing fraud labels are simulated classifications.
- The rule-based fraud flag is separate from the simulated fraud label.
- Repeated account identifiers do not automatically indicate suspicious activity.
- Transaction value cannot be interpreted as platform revenue or profit.

Findings should not be generalised directly to real-world UPI or mobile-money platforms.

## Research Reference

Lopez-Rojas, E.A., Elmir, A., and Axelsson, S. (2016).

*PaySim: A Financial Mobile Money Simulator for Fraud Detection.*

28th European Modeling and Simulation Symposium (EMSS 2016).

## Current Project Status

**Phase 3 Completed — Analytical Question Discovery**

**Phase 4 In Progress — PostgreSQL Setup and SQL Implementation**

The next milestone is to create the project database, design the transaction table, import the dataset and begin implementing the ten analytical questions using PostgreSQL.

---

*This is an ongoing practical SQL portfolio project. Analytical results will be added as queries are implemented, executed and validated.*