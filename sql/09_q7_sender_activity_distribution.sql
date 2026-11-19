
-- PaySim SQL Portfolio
-- Q7: Sender Activity Distribution
--
-- Objective:
-- Identify the most active originating accounts
-- based on transaction frequency and analyse
-- their associated monetary contribution.
--

SELECT
    sender_id,
    COUNT(*) AS transaction_count,
    SUM(amount) AS total_transaction_value,
    ROUND(AVG(amount), 2) AS average_transaction_amount

FROM public.transactions
GROUP BY sender_id
ORDER BY
    transaction_count DESC,
    total_transaction_value DESC,
    sender_id ASC
LIMIT 10;
