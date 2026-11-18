SELECT
    MIN(step) AS first_step,
    MAX(step) AS last_step,
    COUNT(DISTINCT step) AS distinct_steps
FROM public.transactions;

SELECT COUNT(*) AS hourly_rows
FROM (
    SELECT step
    FROM public.transactions
    GROUP BY step
) AS hourly_summary;

WITH hourly_summary AS (
    SELECT
        step,
        COUNT(*) AS transaction_count,
        SUM(amount) AS total_amount
    FROM public.transactions
    GROUP BY step
)

(
    SELECT *
    FROM hourly_summary
    ORDER BY step ASC
    LIMIT 5
)

UNION ALL

(
    SELECT *
    FROM hourly_summary
    ORDER BY step DESC
    LIMIT 5
)

ORDER BY step;