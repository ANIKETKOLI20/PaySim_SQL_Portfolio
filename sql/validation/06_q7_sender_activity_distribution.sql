-- PaySim SQL Portfolio
-- Q7: Sender Activity Distribution Validation
-- Validates sender population, one-time/repeat segments and top-10 ranking.

WITH sender_metrics AS (
    SELECT
        sender_id,
        COUNT(*) AS transaction_count,
        SUM(amount) AS total_transaction_value
    FROM public.transactions
    GROUP BY sender_id
),

overall_totals AS (
    SELECT
        COUNT(*) AS total_transaction_count,
        ROUND(SUM(amount), 2) AS total_transaction_value
    FROM public.transactions
),

sender_summary AS (
    SELECT
        COUNT(*) AS sender_groups,
        COUNT(DISTINCT sender_id) AS distinct_sender_accounts,
        SUM(transaction_count) AS reconciled_transaction_count,
        MAX(transaction_count) AS max_transactions_per_sender,
        SUM(CASE WHEN transaction_count = 1 THEN 1 ELSE 0 END)
            AS single_transaction_senders,
        SUM(CASE WHEN transaction_count > 1 THEN 1 ELSE 0 END)
            AS repeat_sender_accounts
    FROM sender_metrics
),

sender_segments AS (
    SELECT
        CASE WHEN transaction_count = 1 THEN 'ONE_TIME' ELSE 'REPEAT' END
            AS sender_segment,
        COUNT(*) AS distinct_sender_accounts,
        SUM(transaction_count) AS transaction_count,
        ROUND(SUM(total_transaction_value), 2) AS total_transaction_value
    FROM sender_metrics
    GROUP BY CASE WHEN transaction_count = 1 THEN 'ONE_TIME' ELSE 'REPEAT' END
),

segment_summary AS (
    SELECT
        MAX(CASE WHEN sender_segment = 'ONE_TIME'
            THEN distinct_sender_accounts END) AS one_time_sender_accounts,
        MAX(CASE WHEN sender_segment = 'REPEAT'
            THEN distinct_sender_accounts END) AS repeat_sender_accounts,
        MAX(CASE WHEN sender_segment = 'ONE_TIME'
            THEN transaction_count END) AS one_time_transaction_count,
        MAX(CASE WHEN sender_segment = 'REPEAT'
            THEN transaction_count END) AS repeat_transaction_count,
        MAX(CASE WHEN sender_segment = 'ONE_TIME'
            THEN total_transaction_value END) AS one_time_transaction_value,
        MAX(CASE WHEN sender_segment = 'REPEAT'
            THEN total_transaction_value END) AS repeat_transaction_value
    FROM sender_segments
),

segment_shares AS (
    SELECT
        ROUND(100.0 * ss.one_time_transaction_count
            / NULLIF(ot.total_transaction_count, 0), 4)
            AS one_time_transaction_volume_share,
        ROUND(100.0 * ss.repeat_transaction_count
            / NULLIF(ot.total_transaction_count, 0), 4)
            AS repeat_transaction_volume_share,
        ROUND(100.0 * ss.one_time_transaction_value
            / NULLIF(ot.total_transaction_value, 0), 4)
            AS one_time_monetary_value_share,
        ROUND(100.0 * ss.repeat_transaction_value
            / NULLIF(ot.total_transaction_value, 0), 4)
            AS repeat_monetary_value_share
    FROM segment_summary ss
    CROSS JOIN overall_totals ot
),

ranked_senders AS (
    SELECT
        sender_id,
        transaction_count,
        total_transaction_value,
        ROW_NUMBER() OVER (
            ORDER BY transaction_count DESC,
                     total_transaction_value DESC,
                     sender_id ASC
        ) AS activity_rank
    FROM sender_metrics
),

top_ten_summary AS (
    SELECT
        COUNT(*) AS top_ten_rows,
        MIN(activity_rank) AS first_rank,
        MAX(activity_rank) AS last_rank,
        MIN(transaction_count) AS minimum_top_ten_transaction_count,
        MAX(transaction_count) AS maximum_top_ten_transaction_count
    FROM ranked_senders
    WHERE activity_rank <= 10
)

SELECT
    -- Existing sender population controls
    s.sender_groups,
    s.distinct_sender_accounts,
    s.reconciled_transaction_count,
    s.max_transactions_per_sender,
    s.single_transaction_senders,
    s.repeat_sender_accounts,

    -- Segment-level results
    ss.one_time_sender_accounts,
    ss.repeat_sender_accounts AS segment_repeat_sender_accounts,
    ss.one_time_transaction_count,
    ss.repeat_transaction_count,
    ss.one_time_transaction_value,
    ss.repeat_transaction_value,
    sh.one_time_transaction_volume_share,
    sh.repeat_transaction_volume_share,
    sh.one_time_monetary_value_share,
    sh.repeat_monetary_value_share,

    -- Dataset-level controls
    ot.total_transaction_count,
    ot.total_transaction_value,

    -- Existing top-10 controls
    t.top_ten_rows,
    t.first_rank,
    t.last_rank,
    t.minimum_top_ten_transaction_count,
    t.maximum_top_ten_transaction_count,

    -- Existing validation checks
    (s.sender_groups = s.distinct_sender_accounts)
        AS sender_group_reconciles,
    (s.reconciled_transaction_count = 6362620
        AND s.reconciled_transaction_count = ot.total_transaction_count)
        AS transaction_count_reconciles,
    (t.top_ten_rows = 10 AND t.first_rank = 1 AND t.last_rank = 10)
        AS top_ten_reconciles,

    -- New one-time/repeat segment validation checks
    (ss.one_time_sender_accounts = 6344009
        AND ss.repeat_sender_accounts = 9298
        AND ss.one_time_sender_accounts + ss.repeat_sender_accounts = s.sender_groups)
        AS sender_segment_account_counts_reconcile,
    (ss.one_time_transaction_count = 6344009
        AND ss.repeat_transaction_count = 18611
        AND ss.one_time_transaction_count + ss.repeat_transaction_count
            = ot.total_transaction_count)
        AS sender_segment_transaction_counts_reconcile,
    (ss.one_time_transaction_value = 1140984061038.01
        AND ss.repeat_transaction_value = 3408883721.76
        AND ss.one_time_transaction_value + ss.repeat_transaction_value
            = ot.total_transaction_value
        AND ot.total_transaction_value = 1144392944759.77)
        AS sender_segment_transaction_values_reconcile,
    (sh.one_time_transaction_volume_share = 99.7075
        AND sh.repeat_transaction_volume_share = 0.2925
        AND sh.one_time_transaction_volume_share
            + sh.repeat_transaction_volume_share = 100.0000)
        AS transaction_volume_shares_reconcile,
    (sh.one_time_monetary_value_share = 99.7021
        AND sh.repeat_monetary_value_share = 0.2979
        AND sh.one_time_monetary_value_share
            + sh.repeat_monetary_value_share = 100.0000)
        AS monetary_value_shares_reconcile

FROM sender_summary s
CROSS JOIN segment_summary ss
CROSS JOIN segment_shares sh
CROSS JOIN overall_totals ot
CROSS JOIN top_ten_summary t;
