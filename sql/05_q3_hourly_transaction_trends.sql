-- PaySim SQL Portfolio
-- Q3: Hourly Transaction Trends
-- Objective: Analyze transaction trends on an hourly basis.

SELECT 
     step,
     SUM(amount) AS total_amount,
     COUNT(*) AS transaction_count
FROM public.transactions
GROUP BY step
ORDER BY step;