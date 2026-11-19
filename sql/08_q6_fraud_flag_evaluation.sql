
-- PaySim SQL Portfolio
-- Q6: Rule-Based Fraud Flag Evaluation
-- Objective:
-- Evaluate the existing rule-based fraud flag against
-- simulated fraud labels using a confusion matrix,
-- precision and recall.

WITH confusion_matrix AS (

    -- Step 1: Calculate the four classification outcomes

    SELECT
        COUNT(*) AS total_transactions,

        -- True Positives
        SUM(
            CASE
                WHEN is_fraud = 1 AND is_flagged_fraud = 1 THEN 1
                ELSE 0
            END
        ) AS true_positives,

        -- False Positives
        SUM(
            CASE
                WHEN is_fraud = 0 AND is_flagged_fraud = 1 THEN 1
                ELSE 0
            END
        ) AS false_positives,

        -- False Negatives
        SUM(
            CASE
                WHEN is_fraud = 1 AND is_flagged_fraud = 0 THEN 1
                ELSE 0
            END
        ) AS false_negatives,

        -- True Negatives
        SUM(
            CASE
                WHEN is_fraud = 0 AND is_flagged_fraud = 0 THEN 1
                ELSE 0
            END
        ) AS true_negatives

    FROM public.transactions

)

-- Step 2: Calculate precision and recall

SELECT
    total_transactions,
    true_positives,
    false_positives,
    false_negatives,
    true_negatives,

    -- Precision: Of all flagged transactions,
    -- what percentage carries the fraud label?
    ROUND(
        100.0 * true_positives
        / NULLIF(true_positives + false_positives, 0),
        2
    ) AS precision_percentage,

    -- Recall: Of all fraud-labelled transactions,
    -- what percentage was flagged?
    ROUND(
        100.0 * true_positives
        / NULLIF(true_positives + false_negatives, 0),
        2
    ) AS recall_percentage

FROM confusion_matrix;
