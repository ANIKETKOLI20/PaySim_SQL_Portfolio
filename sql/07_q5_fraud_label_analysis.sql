
-- PaySim SQL Portfolio
-- Q5: Fraud-Labelled Transaction Analysis
-- Objective: Analyse fraud-label distribution
-- across transaction categories.

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

)

-- Step 2: Calculate both percentage metrics

SELECT
    transaction_type,

    total_transactions,

    fraud_labelled_count,

    -- Metric A: Category fraud-label rate
    ROUND(
        100.0 * fraud_labelled_count
        / NULLIF(total_transactions, 0),
        2
    ) AS category_fraud_label_rate,

    -- Metric B: Fraud-label concentration
    ROUND(
        100.0 * fraud_labelled_count
        / NULLIF(
            SUM(fraud_labelled_count) OVER (),
            0
        ),
        2
    ) AS fraud_label_concentration

FROM category_counts

ORDER BY fraud_labelled_count DESC,
         transaction_type ASC;
