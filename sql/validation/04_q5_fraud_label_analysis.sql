
-- PaySim SQL Portfolio
-- Q5: Fraud-Label Analysis Validation
-- Objective:
-- Validate category-level fraud-label counts,
-- transaction reconciliation and concentration percentages.

WITH category_counts AS (

    SELECT
        transaction_type,
        COUNT(*) AS total_transactions,

        SUM(
            CASE
                WHEN is_fraud = 1 THEN 1
                ELSE 0
            END
        ) AS fraud_labelled_count

    FROM public.transactions
    GROUP BY transaction_type

),

category_metrics AS (

    SELECT
        transaction_type,
        total_transactions,
        fraud_labelled_count,

        ROUND(
            100.0 * fraud_labelled_count
            / NULLIF(total_transactions, 0),
            2
        ) AS category_fraud_label_rate,

        ROUND(
            100.0 * fraud_labelled_count
            / NULLIF(
                SUM(fraud_labelled_count) OVER (),
                0
            ),
            2
        ) AS fraud_label_concentration

    FROM category_counts

)

SELECT
    COUNT(*) AS category_count,

    SUM(total_transactions) AS total_transactions,

    SUM(fraud_labelled_count) AS total_fraud_labelled,

    SUM(
        CASE WHEN fraud_labelled_count > 0 THEN 1 ELSE 0 END
    ) AS categories_with_fraud_labels,

    SUM(fraud_label_concentration) AS concentration_total

FROM category_metrics;
