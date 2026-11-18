
# PostgreSQL Import Validation Report

## 1. Import Overview

**Database:** paysim_analytics

**Schema:** public

**Table:** transactions

**Source:** PaySim original CSV

**Import Method:** PostgreSQL \copy

**Total Imported Records:** 6,362,620

**Import Status:** Successful

## 2. Record Count Validation

| Metric | Result |
|---|---:|
| Expected CSV Records | 6,362,620 |
| Imported PostgreSQL Records | 6,362,620 |
| Distinct Generated Record IDs | 6,362,620 |

Result: Record counts reconciled successfully.

Note: record_id is a database-generated
identifier, not an original PaySim transaction ID.

## 3. Transaction Category Validation

| Transaction Type | Transaction Count |
|---|---:|
| CASH_OUT | 2,237,500 |
| PAYMENT | 2,151,495 |
| CASH_IN | 1,399,284 |
| TRANSFER | 532,909 |
| DEBIT | 41,432 |
| **Total** | **6,362,620** |

Result: All five category counts match the
previous Python investigation.

## 4. Fraud Indicator Validation

### is_fraud

| Value | Records |
|---|---:|
| 0 | 6,354,407 |
| 1 | 8,213 |

### is_flagged_fraud

| Value | Records |
|---|---:|
| 0 | 6,362,604 |
| 1 | 16 |

Result: Both distributions match the
previous Python investigation.

## 5. Monetary Total Reconciliation

| Source | Total Transaction Value |
|---|---:|
| Original CSV (Python Decimal) | 1,144,392,944,759.77 |
| PostgreSQL (NUMERIC) | 1,144,392,944,759.77 |
| Difference | 0.00 |

Result: Exact monetary total reconciliation.

## 6. Final Conclusion

The PaySim dataset was successfully imported
into PostgreSQL.

The imported record count, transaction category
distribution, fraud indicator distributions and
total monetary value were reconciled against
the original dataset investigations.

The PostgreSQL transaction table is ready
for analytical SQL implementation.

All original CSV records remain unchanged.
