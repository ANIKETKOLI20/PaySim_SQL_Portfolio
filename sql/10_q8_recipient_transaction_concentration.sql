
-- PaySim SQL Portfolio
-- Q8: Recipient Transaction Concentration
--
-- Objective:
-- Identify recipient accounts receiving the highest
-- transaction frequency and analyse their monetary contribution
-- and share of overall transaction activity.

-- Step 1: Calculate recipient-level metrics

WITH recipient_metrics AS (

    SELECT
        recipient_id,

        COUNT(*) AS transaction_count,

        SUM(amount) AS total_received_value,

        ROUND(AVG(amount), 2) AS average_received_amount

    FROM public.transactions

    GROUP BY recipient_id

),

-- Step 2: Calculate overall totals using window functions

recipient_shares AS (

    SELECT
        recipient_id,
        transaction_count,
        total_received_value,
        average_received_amount,

        SUM(transaction_count) OVER ()
            AS overall_transaction_count,

        SUM(total_received_value) OVER ()
            AS overall_transaction_value

    FROM recipient_metrics

)

-- Step 3: Calculate recipient-level percentages

SELECT
    recipient_id,

    transaction_count,

    total_received_value,

    average_received_amount,

    -- Metric 4: Share of all transaction records

    ROUND(
        100.0 * transaction_count
        / NULLIF(overall_transaction_count, 0),
        5
    ) AS transaction_share_percentage,

    -- Metric 5: Share of overall recorded monetary value

    ROUND(
        100.0 * total_received_value
        / NULLIF(overall_transaction_value, 0),
        5
    ) AS monetary_value_share_percentage

FROM recipient_shares

-- Rank recipients by transaction frequency first

ORDER BY
    transaction_count DESC,
    total_received_value DESC,
    recipient_id ASC

LIMIT 10;
