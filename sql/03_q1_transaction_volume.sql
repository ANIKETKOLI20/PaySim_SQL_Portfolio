
-- PaySim SQL Portfolio
-- Q1: Transaction Volume Distribution
-- Objective: Calculate transaction count and
-- percentage contribution by transaction category.

WITH category_counts AS (

    SELECT
        transaction_type,
        COUNT(*) AS transaction_count

    FROM public.transactions

    GROUP BY transaction_type

)

SELECT
    transaction_type,
    transaction_count,

    ROUND(
        100.0 * transaction_count
        / SUM(transaction_count) OVER (),
        2
    ) AS transaction_share_percentage

FROM category_counts

ORDER BY transaction_count DESC;
