
-- PaySim SQL Portfolio
-- Q6: Fraud Flag Evaluation Validation
-- Objective:
-- Validate confusion matrix counts,
-- classification reconciliation, precision and recall.

WITH confusion_matrix AS (

    SELECT
        COUNT(*) AS total_transactions,

        SUM(
            CASE
                WHEN is_fraud = 1
                 AND is_flagged_fraud = 1 THEN 1
                ELSE 0
            END
        ) AS true_positives,

        SUM(
            CASE
                WHEN is_fraud = 0
                 AND is_flagged_fraud = 1 THEN 1
                ELSE 0
            END
        ) AS false_positives,

        SUM(
            CASE
                WHEN is_fraud = 1
                 AND is_flagged_fraud = 0 THEN 1
                ELSE 0
            END
        ) AS false_negatives,

        SUM(
            CASE
                WHEN is_fraud = 0
                 AND is_flagged_fraud = 0 THEN 1
                ELSE 0
            END
        ) AS true_negatives

    FROM public.transactions

),

validation_summary AS (

    SELECT
        *,
        (
            true_positives
            + false_positives
            + false_negatives
            + true_negatives
        ) AS classified_transactions

    FROM confusion_matrix

)

SELECT
    total_transactions,

    true_positives,
    false_positives,
    false_negatives,
    true_negatives,

    classified_transactions,

    (
        total_transactions = classified_transactions
    ) AS classification_reconciles,

    ROUND(
        100.0 * true_positives
        / NULLIF(true_positives + false_positives, 0),
        2
    ) AS precision_percentage,

    ROUND(
        100.0 * true_positives
        / NULLIF(true_positives + false_negatives, 0),
        2
    ) AS recall_percentage

FROM validation_summary;
