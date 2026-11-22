
-- PaySim SQL Portfolio
-- Q7: Sender Activity Distribution
--
-- Objective:
-- Identify the most active originating accounts
-- based on transaction frequency and analyse
-- their associated monetary contribution.
--

WITH sender_activity AS (
    SELECT
        sender_id,
        COUNT(*) AS transaction_count,
        SUM(amount) AS total_transaction_value
    FROM public.transactions
    GROUP BY sender_id
),

sender_segments AS (
    SELECT
        sender_id,
        transaction_count,
        total_transaction_value,
        CASE
            WHEN transaction_count = 1 THEN 'ONE_TIME'
            ELSE 'REPEAT'
        END AS sender_segment
    FROM sender_activity
),

overall_totals AS (
    SELECT
        COUNT(*) AS total_transaction_count,
        SUM(amount) AS total_transaction_value
    FROM public.transactions
)

SELECT
    ss.sender_segment,
    COUNT(*) AS distinct_sender_accounts,
    SUM(ss.transaction_count) AS transaction_count,

    ROUND(
        100.0 * SUM(ss.transaction_count)
        / NULLIF(ot.total_transaction_count, 0),
        4
    ) AS transaction_volume_share_percentage,

    ROUND(
        SUM(ss.total_transaction_value),
        2
    ) AS total_transaction_value,

    ROUND(
        100.0 * SUM(ss.total_transaction_value)
        / NULLIF(ot.total_transaction_value, 0),
        4
    ) AS monetary_value_share_percentage

FROM sender_segments ss
CROSS JOIN overall_totals ot

GROUP BY
    ss.sender_segment,
    ot.total_transaction_count,
    ot.total_transaction_value

ORDER BY
    CASE
        WHEN ss.sender_segment = 'ONE_TIME' THEN 1
        ELSE 2
    END;
