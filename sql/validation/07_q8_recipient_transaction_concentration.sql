
-- PaySim SQL Portfolio
-- Q8: Recipient Transaction Concentration Validation
--
-- Objective:
-- Validate recipient-level aggregation,
-- transaction reconciliation, monetary reconciliation,
-- concentration percentages and top-10 ranking.

WITH recipient_metrics AS (

    -- Step 1: Independently calculate recipient metrics

    SELECT
        recipient_id,
        COUNT(*) AS transaction_count,
        SUM(amount) AS total_received_value

    FROM public.transactions
    GROUP BY recipient_id

),

recipient_shares AS (

    -- Step 2: Calculate overall denominators

    SELECT
        recipient_id,
        transaction_count,
        total_received_value,

        SUM(transaction_count) OVER ()
            AS overall_transaction_count,

        SUM(total_received_value) OVER ()
            AS overall_transaction_value

    FROM recipient_metrics

),

ranked_recipients AS (

    -- Step 3: Reproduce the ranking and inspect ordering

    SELECT
        recipient_id,
        transaction_count,
        total_received_value,

        ROW_NUMBER() OVER (
            ORDER BY
                transaction_count DESC,
                total_received_value DESC,
                recipient_id ASC
        ) AS recipient_rank,

        LAG(transaction_count) OVER (
            ORDER BY
                transaction_count DESC,
                total_received_value DESC,
                recipient_id ASC
        ) AS previous_transaction_count,

        LAG(total_received_value) OVER (
            ORDER BY
                transaction_count DESC,
                total_received_value DESC,
                recipient_id ASC
        ) AS previous_received_value,

        LAG(recipient_id) OVER (
            ORDER BY
                transaction_count DESC,
                total_received_value DESC,
                recipient_id ASC
        ) AS previous_recipient_id

    FROM recipient_shares

),

recipient_reconciliation AS (

    -- Step 4: Reconcile all recipient groups

    SELECT
        COUNT(*) AS recipient_groups,

        COUNT(DISTINCT recipient_id)
            AS distinct_recipient_ids,

        SUM(transaction_count)
            AS reconciled_transaction_count,

        SUM(total_received_value)
            AS reconciled_monetary_value

    FROM recipient_shares

),

concentration_validation AS (

    -- Step 5: Validate percentages using unrounded shares

    SELECT
        ROUND(
            SUM(
                100.0 * transaction_count
                / NULLIF(overall_transaction_count, 0)
            ),
            5
        ) AS total_transaction_share_percentage,

        ROUND(
            SUM(
                100.0 * total_received_value
                / NULLIF(overall_transaction_value, 0)
            ),
            5
        ) AS total_monetary_value_share_percentage

    FROM recipient_shares

),

top_ten_validation AS (

    -- Step 6: Validate top-10 results

    SELECT
        COUNT(*) AS top_ten_rows,

        MIN(recipient_rank) AS first_rank,

        MAX(recipient_rank) AS last_rank,

        MIN(transaction_count)
            AS minimum_top_ten_transaction_count,

        MAX(transaction_count)
            AS maximum_top_ten_transaction_count

    FROM ranked_recipients
    WHERE recipient_rank <= 10

),

ranking_validation AS (

    -- Step 7: Check whether ranking order has violations

    SELECT
        SUM(
            CASE
                WHEN previous_transaction_count IS NOT NULL
                 AND (
                     transaction_count > previous_transaction_count

                     OR (
                         transaction_count = previous_transaction_count
                         AND total_received_value > previous_received_value
                     )

                     OR (
                         transaction_count = previous_transaction_count
                         AND total_received_value = previous_received_value
                         AND recipient_id < previous_recipient_id
                     )
                 )
                THEN 1
                ELSE 0
            END
        ) AS ranking_order_violations

    FROM ranked_recipients

)

-- Step 8: Final validation report

SELECT
    r.recipient_groups,
    r.distinct_recipient_ids,

    r.reconciled_transaction_count,
    r.reconciled_monetary_value,

    c.total_transaction_share_percentage,
    c.total_monetary_value_share_percentage,

    t.top_ten_rows,
    t.first_rank,
    t.last_rank,

    t.minimum_top_ten_transaction_count,
    t.maximum_top_ten_transaction_count,

    v.ranking_order_violations,

    (
        r.recipient_groups = r.distinct_recipient_ids
    ) AS recipient_groups_reconcile,

    (
        r.reconciled_transaction_count = 6362620
    ) AS transaction_count_reconciles,

    (
        ROUND(r.reconciled_monetary_value, 2)
        = 1144392944759.77
    ) AS monetary_value_reconciles,

    (
        c.total_transaction_share_percentage = 100.00000
    ) AS transaction_share_reconciles,

    (
        c.total_monetary_value_share_percentage = 100.00000
    ) AS monetary_share_reconciles,

    (
        t.top_ten_rows = 10
        AND t.first_rank = 1
        AND t.last_rank = 10
    ) AS top_ten_reconciles,

    (
        v.ranking_order_violations = 0
    ) AS ranking_order_reconciles

FROM recipient_reconciliation r
CROSS JOIN concentration_validation c
CROSS JOIN top_ten_validation t
CROSS JOIN ranking_validation v;
