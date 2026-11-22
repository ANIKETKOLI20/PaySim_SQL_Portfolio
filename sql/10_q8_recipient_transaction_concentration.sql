-- PaySim SQL Portfolio
-- Q8: Recipient Transaction Concentration
--
-- Objective:
-- Identify recipient accounts receiving the highest
-- transaction frequency and analyse their monetary contribution
-- and share of overall transaction activity.
--
-- This file contains two analyses:
-- 1. Top 10 recipient identifiers by transaction frequency.
-- 2. Recipient-type comparison using identifier prefixes.
--
-- Recipient classifications are based on the supplied dataset's
-- identifier format. They do not independently verify real-world
-- customer or merchant identities.


-- ============================================================
-- ANALYSIS 1: TOP 10 RECIPIENT IDENTIFIERS
-- ============================================================

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

    -- Share of all transaction records

    ROUND(
        100.0 * transaction_count
        / NULLIF(overall_transaction_count, 0),
        5
    ) AS transaction_share_percentage,

    -- Share of overall recorded monetary value

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


-- ============================================================
-- ANALYSIS 2: RECIPIENT-TYPE SEGMENT SUMMARY
-- ============================================================

-- Classify every transaction's recipient identifier.
-- NULL and unexpected prefixes are retained as separate groups
-- so all transaction records remain accounted for.

WITH recipient_classification AS (

    SELECT
        recipient_id,
        amount,

        CASE
            WHEN recipient_id IS NULL THEN 'NULL_IDENTIFIER'
            WHEN recipient_id LIKE 'C%' THEN 'CUSTOMER_CODED'
            WHEN recipient_id LIKE 'M%' THEN 'MERCHANT_CODED'
            ELSE 'OTHER_UNCLASSIFIED'
        END AS recipient_type

    FROM public.transactions

),

-- Calculate dataset-wide denominators independently
-- from the classified recipient records.

overall_totals AS (

    SELECT
        COUNT(*) AS total_transaction_count,
        SUM(amount) AS total_transaction_value

    FROM public.transactions

)

SELECT
    rc.recipient_type,

    COUNT(DISTINCT rc.recipient_id)
        AS distinct_recipient_identifiers,

    COUNT(*)
        AS transaction_count,

    ROUND(
        100.0 * COUNT(*)
        / NULLIF(ot.total_transaction_count, 0),
        4
    ) AS transaction_volume_share_percentage,

    ROUND(
        SUM(rc.amount),
        2
    ) AS total_transaction_value,

    ROUND(
        AVG(rc.amount),
        2
    ) AS average_transaction_amount,

    ROUND(
        100.0 * SUM(rc.amount)
        / NULLIF(ot.total_transaction_value, 0),
        4
    ) AS monetary_value_share_percentage

FROM recipient_classification rc

CROSS JOIN overall_totals ot

GROUP BY
    rc.recipient_type,
    ot.total_transaction_count,
    ot.total_transaction_value

ORDER BY
    CASE rc.recipient_type
        WHEN 'CUSTOMER_CODED' THEN 1
        WHEN 'MERCHANT_CODED' THEN 2
        WHEN 'OTHER_UNCLASSIFIED' THEN 3
        WHEN 'NULL_IDENTIFIER' THEN 4
    END;
