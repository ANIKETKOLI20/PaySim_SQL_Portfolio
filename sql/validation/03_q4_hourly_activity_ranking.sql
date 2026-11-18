WITH hourly_ranking AS (
    SELECT
        step,
        COUNT(*) AS transaction_count,
        SUM(amount) AS total_amount,
        ROW_NUMBER() OVER (
            ORDER BY
                COUNT(*) DESC,
                SUM(amount) DESC,
                step ASC
        ) AS activity_rank
    FROM public.transactions
    GROUP BY step
)

SELECT
    COUNT(*) AS total_ranked_steps,
    COUNT(DISTINCT activity_rank) AS unique_ranks,
    MIN(activity_rank) AS first_rank,
    MAX(activity_rank) AS last_rank
FROM hourly_ranking;