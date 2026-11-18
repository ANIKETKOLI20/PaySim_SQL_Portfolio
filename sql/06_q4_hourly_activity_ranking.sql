-- PaySim SQL Portfolio
-- Q4: Hourly Activity Ranking
-- Objective: Rank hours based on transaction activity.

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
ORDER BY activity_rank;
