# PaySim SQL Portfolio — Evidence Index

This folder contains execution evidence supporting the analytical queries and independent validation work in the PaySim SQL Portfolio.

The screenshots were captured from PostgreSQL query outputs and are organised by analytical question.

## Evidence Structure

```text
evidence/
├── README.md
└── screenshots/
    ├── q5_fraud_label_analysis.png
    ├── q5_fraud_label_validation.png
    ├── q6_fraud_flag_evaluation.png
    ├── q6_fraud_flag_validation.png
    ├── q7_sender_activity_summary.png
    ├── q7_sender_validation_1.png
    ├── q7_sender_validation_2.png
    ├── q8_recipient_segment_summary.png
    ├── q8_recipient_validation_1.png
    ├── q8_recipient_validation_2.png
    ├── q9_amount_distribution_1.png
    ├── q9_amount_distribution_2.png
    ├── q9_amount_distribution_3.png
    ├── q9_amount_validation.png
    ├── q10_balance_movement_summary_1.png
    ├── q10_balance_movement_summary_2.png
    ├── q10_balance_movement_summary_3.png
    ├── q10_balance_movement_summary_4.png
    ├── q10_balance_movement_summary_5.png
    ├── q10_balance_movement_summary_6.png
    ├── q10_balance_movement_summary_7.png
    ├── q10_balance_movement_validation_1.png
    ├── q10_balance_movement_validation_2.png
    ├── q10_balance_movement_validation_3.png
    ├── q10_balance_movement_validation_4.png
    ├── q10_balance_movement_validation_5.png
    ├── q10_balance_movement_validation_6.png
    └── q10_balance_movement_validation_7.png
```

## Q5. Fraud Label Analysis

**Analytical evidence**

| Screenshot | Evidence description |
|---|---|
| `q5_fraud_label_analysis.png` | Transaction counts, fraud-labelled counts, category fraud-label rates and fraud-label concentration by transaction category. |

**Validation evidence**

| Screenshot | Evidence description |
|---|---|
| `q5_fraud_label_validation.png` | Validation summary covering transaction categories, total transactions, fraud-labelled transactions and fraud-label concentration. |

**Key result:** The dataset contains 8,213 fraud-labelled transactions. CASH_OUT and TRANSFER account for all fraud-labelled records.

**Validation note:** The captured validation output is a summary of validation metrics. It does not display explicit PASS statuses for individual checks.

## Q6. Fraud Flag Evaluation

**Analytical evidence**

| Screenshot | Evidence description |
|---|---|
| `q6_fraud_flag_evaluation.png` | Confusion-matrix counts, precision and recall calculated by comparing `isFlaggedFraud` with the dataset's `isFraud` labels. |

**Validation evidence**

| Screenshot | Evidence description |
|---|---|
| `q6_fraud_flag_validation.png` | Validation summary showing total and classified transactions, confusion-matrix counts, precision, recall and classification reconciliation. |

**Key result:** The analysis identifies 16 true positives, zero false positives and 8,197 false negatives. Precision is 100.00%, while recall is 0.19%.

**Validation note:** The captured validation output contains one explicit Boolean reconciliation check, `classification_reconciles`, which returned TRUE. It should not be represented as multiple independent PASS checks.

## Q7. Sender Activity Distribution Analysis

**Analytical evidence**

| Screenshot | Evidence description |
|---|---|
| `q7_sender_activity_summary.png` | Sender activity segmentation, including one-time and repeat sender account counts, transaction counts, transaction volume shares, transaction values and monetary value shares. |

**Validation evidence**

| Screenshot | Evidence description |
|---|---|
| `q7_sender_validation_1.png` | Sender population, transaction and monetary summary metrics, including segment reconciliation figures. |
| `q7_sender_validation_2.png` | Boolean reconciliation checks covering sender groups, transaction counts, Top-10 results, segment account counts, segment transaction counts, segment values and volume and monetary shares. |

**Key result:** One-time senders account for 99.7075% of transaction volume and 99.7021% of monetary value. Repeat senders account for 0.2925% of transaction volume and 0.2979% of monetary value.

**Validation result:** All 8 Boolean validation checks returned TRUE.

## Q8. Recipient Transaction Concentration

**Analytical evidence**

| Screenshot | Evidence description |
|---|---|
| `q8_recipient_segment_summary.png` | Comparison of customer-coded and merchant-coded recipients by distinct identifiers, transaction counts, volume shares, transaction values, average amounts and monetary value shares. |

**Validation evidence**

| Screenshot | Evidence description |
|---|---|
| `q8_recipient_validation_1.png` | Recipient population, identifier, transaction, monetary value, Top-10 ranking and segment reconciliation metrics. |
| `q8_recipient_validation_2.png` | Boolean checks covering recipient groups, transaction counts and values, shares, rankings, segment metrics, and unclassified or NULL recipient identifiers. |

**Key result:** Customer-coded recipients account for 66.1854% of transaction volume and 97.5451% of monetary value. Merchant-coded recipients account for 33.8146% of transaction volume and 2.4549% of monetary value.

**Validation result:** All 16 Boolean validation checks returned TRUE.

## Q9. Transaction Amount Distribution Analysis

**Analytical evidence**

| Screenshot | Evidence description |
|---|---|
| `q9_amount_distribution_1.png` | Transaction amount distribution results covering the first transaction/fraud-label groups. |
| `q9_amount_distribution_2.png` | Transaction amount distribution results covering the middle transaction/fraud-label groups. |
| `q9_amount_distribution_3.png` | Transaction amount distribution results covering the remaining transaction/fraud-label groups. |

The analytical output includes transaction count, total transaction value, average amount, median amount, minimum amount and maximum amount, grouped by transaction type and fraud label.

**Validation evidence**

| Screenshot | Evidence description |
|---|---|
| `q9_amount_validation.png` | Overall dataset controls, expected group counts, transaction and monetary reconciliation, zero-amount checks and distribution-boundary checks. |

**Key result:** TRANSFER has the highest average transaction amount (910,647.01), median transaction amount (486,308.39) and maximum recorded amount (92,445,516.64).

**Validation result:** All 10 Boolean validation checks returned TRUE.

## Q10. Balance Movement Analysis

**Analytical evidence**

| Screenshot | Evidence description |
|---|---|
| `q10_balance_movement_summary_1.png` | Transaction-group balance movement output. |
| `q10_balance_movement_summary_2.png` | Transaction-group balance movement output. |
| `q10_balance_movement_summary_3.png` | Transaction-group balance movement output. |
| `q10_balance_movement_summary_4.png` | Transaction-group balance movement output. |
| `q10_balance_movement_summary_5.png` | Transaction-group balance movement output. |
| `q10_balance_movement_summary_6.png` | Transaction-group balance movement output. |
| `q10_balance_movement_summary_7.png` | Transaction-group balance movement output. |

The analytical results cover seven transaction-type and fraud-label groups. They include sender movement classifications, recipient movement classifications, evaluation counts and absolute observed differences.

**Validation evidence**

| Screenshot | Evidence description |
|---|---|
| `q10_balance_movement_validation_1.png` | Independent validation records. |
| `q10_balance_movement_validation_2.png` | Independent validation records. |
| `q10_balance_movement_validation_3.png` | Independent validation records. |
| `q10_balance_movement_validation_4.png` | Independent validation records. |
| `q10_balance_movement_validation_5.png` | Independent validation records. |
| `q10_balance_movement_validation_6.png` | Independent validation records. |
| `q10_balance_movement_validation_7.png` | Independent validation records. |

The validation output checks expected and actual transaction counts, sender classifications and recipient classifications for the seven groups.

**Validation result:** All 26 validation records returned `PASS`.

**Interpretation note:** Recipient-side balance differences are observed discrepancies within the synthetic dataset. They should not automatically be interpreted as failed credits, financial losses or fraud.

## Evidence and Interpretation Limitations

- PaySim is a synthetic mobile-money transaction dataset.
- Fraud labels are supplied simulation labels, not independently confirmed real-world fraud outcomes.
- Validation results establish consistency with the analytical definitions and expected dataset controls used in this project; they do not establish production-system correctness.
- Screenshots provide supporting execution evidence. The SQL files and validation scripts remain the reproducible analytical source.
- Percentage differences, monetary discrepancies and classifications must be interpreted within each question's documented definitions and scope.

## Scope of This Evidence Index

This index documents the Q5–Q10 evidence reviewed for the portfolio publication process. Evidence for Q1–Q4 should be added when its corresponding screenshots have been collected and reviewed.

---

**Project:** PaySim SQL Portfolio  
**Database:** PostgreSQL  
**Primary table:** `public.transactions`  
**Dataset records:** 6,362,620