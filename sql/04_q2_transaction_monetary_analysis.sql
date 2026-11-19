-- PaySim SQL Portfolio
-- Q2: Transaction Monetary Analysis
-- Objective: Calculate highest total and average transaction amounts by transaction category.

WITH aggegrate_counts AS (
    SELECT 
        COUNT(*) AS total_count,
        transaction_type,
        SUM(amount) AS total_amount,
        ROUND(AVG(amount), 2) AS average_amount
        
    FROM public.transactions
    GROUP BY transaction_type
)

SELECT
    transaction_type,
    total_count,
    total_amount,
    average_amount
FROM aggegrate_counts
ORDER BY total_amount DESC, average_amount DESC;

