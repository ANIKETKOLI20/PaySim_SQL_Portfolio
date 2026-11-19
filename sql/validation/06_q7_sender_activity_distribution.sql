
-- PaySim SQL Portfolio
-- Q7: Sender Activity Distribution Validation
--
-- Objective:
-- Validate sender-level aggregation, transaction
-- reconciliation, sender frequency and top-10 ranking.

WITH sender_metrics AS (

    -- Step 1: Build independent sender-level metrics

    SELECT
        sender_id,
        COUNT(*) AS transaction_count,
        SUM(amount) AS total_transaction_value,
        ROUND(AVG(amount), 2) AS average_transaction_amount

    FROM public.transactions
    GROUP BY sender_id

),

sender_summary AS (

    -- Step 2: Validate sender population and counts

    SELECT
        COUNT(*) AS sender_groups,

        COUNT(DISTINCT sender_id)
            AS distinct_sender_accounts,

        SUM(transaction_count)
            AS reconciled_transaction_count,

        MAX(transaction_count)
            AS max_transactions_per_sender,

        SUM(
            CASE
                WHEN transaction_count = 1 THEN 1
                ELSE 0
            END
        ) AS single_transaction_senders,

        SUM(
            CASE
                WHEN transaction_count > 1 THEN 1
                ELSE 0
            END
        ) AS repeat_sender_accounts

    FROM sender_metrics

),

ranked_senders AS (

    -- Step 3: Independently reproduce the ranking

    SELECT
        sender_id,
        transaction_count,
        total_transaction_value,

        ROW_NUMBER() OVER (
            ORDER BY
                transaction_count DESC,
                total_transaction_value DESC,
                sender_id ASC
        ) AS activity_rank

    FROM sender_metrics

),

top_ten_summary AS (

    -- Step 4: Validate top-10 output

    SELECT
        COUNT(*) AS top_ten_rows,

        MIN(activity_rank) AS first_rank,

        MAX(activity_rank) AS last_rank,

        MIN(transaction_count)
            AS minimum_top_ten_transaction_count,

        MAX(transaction_count)
            AS maximum_top_ten_transaction_count

    FROM ranked_senders
    WHERE activity_rank <= 10

)

-- Step 5: Final validation report

SELECT
    s.sender_groups,
    s.distinct_sender_accounts,
    s.reconciled_transaction_count,
    s.max_transactions_per_sender,
    s.single_transaction_senders,
    s.repeat_sender_accounts,

    t.top_ten_rows,
    t.first_rank,
    t.last_rank,
    t.minimum_top_ten_transaction_count,
    t.maximum_top_ten_transaction_count,

    (
        s.sender_groups = s.distinct_sender_accounts
    ) AS sender_group_reconciles,

    (
        s.reconciled_transaction_count = 6362620
    ) AS transaction_count_reconciles,

    (
        t.top_ten_rows = 10
        AND t.first_rank = 1
        AND t.last_rank = 10
    ) AS top_ten_reconciles

FROM sender_summary s
CROSS JOIN top_ten_summary t;
