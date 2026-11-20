
-- ============================================================
-- PaySim SQL Portfolio
-- Q9: Transaction Amount Distribution
--
-- Objective:
-- Analyse transaction amount distributions across transaction
-- categories by comparing average and median amounts.
-- Investigate differences between typical transaction values
-- and overall average values.

-- Statistical Method:
-- PERCENTILE_CONT(0.5) calculates the 50th percentile
-- (median) of transaction amounts within each category.

-- Step 1: Calculate category-level transaction metrics

SELECT

    transaction_type,
    COUNT(*) AS transaction_count,
    SUM(amount) AS total_transaction_value,
    ROUND(
        AVG(amount),
        2
    ) AS average_transaction_amount,

    PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY amount)
        AS median_transaction_amount,
    MIN(amount) AS minimum_transaction_amount,
    MAX(amount) AS maximum_transaction_amount

FROM public.transactions

GROUP BY transaction_type
ORDER BY
    transaction_count DESC,
    transaction_type ASC
LIMIT 10;
