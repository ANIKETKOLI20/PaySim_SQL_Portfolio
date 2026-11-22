-- PaySim SQL Portfolio | Q8 Recipient Transaction Concentration Validation
-- Reconciles the existing recipient analysis and the customer/merchant segments.

WITH recipient_metrics AS (
    SELECT recipient_id, COUNT(*) AS transaction_count,
           SUM(amount) AS total_received_value
    FROM public.transactions
    GROUP BY recipient_id
),
recipient_ranked AS (
    SELECT *,
        ROW_NUMBER() OVER (ORDER BY transaction_count DESC,
            total_received_value DESC, recipient_id ASC) AS recipient_rank,
        LAG(transaction_count) OVER (ORDER BY transaction_count DESC,
            total_received_value DESC, recipient_id ASC) AS previous_count,
        LAG(total_received_value) OVER (ORDER BY transaction_count DESC,
            total_received_value DESC, recipient_id ASC) AS previous_value,
        LAG(recipient_id) OVER (ORDER BY transaction_count DESC,
            total_received_value DESC, recipient_id ASC) AS previous_id
    FROM recipient_metrics
),
recipient_totals AS (
    SELECT COUNT(*) AS recipient_groups,
        COUNT(DISTINCT recipient_id) AS distinct_recipient_ids,
        SUM(transaction_count) AS transaction_count,
        SUM(total_received_value) AS transaction_value
    FROM recipient_metrics
),
recipient_share_totals AS (
    SELECT
        ROUND(SUM(100.0 * transaction_count /
            NULLIF(overall_transaction_count, 0)), 5) AS transaction_share,
        ROUND(SUM(100.0 * total_received_value /
            NULLIF(overall_transaction_value, 0)), 5) AS monetary_share
    FROM (
        SELECT transaction_count, total_received_value,
            SUM(transaction_count) OVER () AS overall_transaction_count,
            SUM(total_received_value) OVER () AS overall_transaction_value
        FROM recipient_metrics
    ) x
),
top_ten AS (
    SELECT COUNT(*) AS rows_returned, MIN(recipient_rank) AS first_rank,
        MAX(recipient_rank) AS last_rank,
        MIN(transaction_count) AS min_count,
        MAX(transaction_count) AS max_count
    FROM recipient_ranked
    WHERE recipient_rank <= 10
),
ranking_check AS (
    SELECT COALESCE(SUM(CASE WHEN previous_count IS NOT NULL AND (
        transaction_count > previous_count
        OR (transaction_count = previous_count AND total_received_value > previous_value)
        OR (transaction_count = previous_count AND total_received_value = previous_value
            AND recipient_id < previous_id)
    ) THEN 1 ELSE 0 END), 0) AS ranking_violations
    FROM recipient_ranked
),
recipient_segments AS (
    SELECT
        CASE WHEN recipient_id IS NULL THEN 'NULL_IDENTIFIER'
             WHEN recipient_id LIKE 'C%' THEN 'CUSTOMER_CODED'
             WHEN recipient_id LIKE 'M%' THEN 'MERCHANT_CODED'
             ELSE 'OTHER_UNCLASSIFIED' END AS recipient_type,
        COUNT(DISTINCT recipient_id) AS distinct_ids,
        COUNT(*) AS transaction_count,
        SUM(amount) AS transaction_value,
        ROUND(AVG(amount), 2) AS average_amount
    FROM public.transactions
    GROUP BY 1
),
segment_shares AS (
    SELECT *,
        ROUND(100.0 * transaction_count /
            NULLIF(SUM(transaction_count) OVER (), 0), 4) AS volume_share,
        ROUND(100.0 * transaction_value /
            NULLIF(SUM(transaction_value) OVER (), 0), 4) AS value_share
    FROM recipient_segments
),
segment_totals AS (
    SELECT COUNT(*) AS segment_rows,
        SUM(distinct_ids) AS distinct_id_total,
        SUM(transaction_count) AS transaction_count_total,
        SUM(transaction_value) AS transaction_value_total,
        SUM(volume_share) AS volume_share_total,
        SUM(value_share) AS value_share_total,
        MAX(distinct_ids) FILTER (WHERE recipient_type = 'CUSTOMER_CODED') AS customer_ids,
        MAX(distinct_ids) FILTER (WHERE recipient_type = 'MERCHANT_CODED') AS merchant_ids,
        MAX(transaction_count) FILTER (WHERE recipient_type = 'CUSTOMER_CODED') AS customer_count,
        MAX(transaction_count) FILTER (WHERE recipient_type = 'MERCHANT_CODED') AS merchant_count,
        MAX(transaction_value) FILTER (WHERE recipient_type = 'CUSTOMER_CODED') AS customer_value,
        MAX(transaction_value) FILTER (WHERE recipient_type = 'MERCHANT_CODED') AS merchant_value,
        MAX(average_amount) FILTER (WHERE recipient_type = 'CUSTOMER_CODED') AS customer_average,
        MAX(average_amount) FILTER (WHERE recipient_type = 'MERCHANT_CODED') AS merchant_average,
        MAX(volume_share) FILTER (WHERE recipient_type = 'CUSTOMER_CODED') AS customer_volume_share,
        MAX(volume_share) FILTER (WHERE recipient_type = 'MERCHANT_CODED') AS merchant_volume_share,
        MAX(value_share) FILTER (WHERE recipient_type = 'CUSTOMER_CODED') AS customer_value_share,
        MAX(value_share) FILTER (WHERE recipient_type = 'MERCHANT_CODED') AS merchant_value_share,
        COALESCE(SUM(transaction_count) FILTER
            (WHERE recipient_type = 'OTHER_UNCLASSIFIED'), 0) AS other_count,
        COALESCE(SUM(transaction_count) FILTER
            (WHERE recipient_type = 'NULL_IDENTIFIER'), 0) AS null_count
    FROM segment_shares
)
SELECT
    -- Reconciliation values for review
    r.recipient_groups, r.distinct_recipient_ids,
    r.transaction_count AS reconciled_transaction_count,
    ROUND(r.transaction_value, 2) AS reconciled_transaction_value,
    st.transaction_share AS total_transaction_share_percentage,
    st.monetary_share AS total_monetary_value_share_percentage,
    t.rows_returned AS top_ten_rows, t.first_rank, t.last_rank,
    t.min_count AS minimum_top_ten_transaction_count,
    t.max_count AS maximum_top_ten_transaction_count,
    rc.ranking_violations AS ranking_order_violations,
    s.segment_rows, s.distinct_id_total, s.transaction_count_total,
    ROUND(s.transaction_value_total, 2) AS segment_transaction_value_total,
    s.volume_share_total, s.value_share_total,
    s.customer_ids, s.merchant_ids, s.customer_count, s.merchant_count,
    ROUND(s.customer_value, 2) AS customer_transaction_value,
    ROUND(s.merchant_value, 2) AS merchant_transaction_value,
    s.customer_average, s.merchant_average,
    s.customer_volume_share, s.merchant_volume_share,
    s.customer_value_share, s.merchant_value_share,
    s.other_count, s.null_count,

    -- Original seven checks
    (r.recipient_groups = r.distinct_recipient_ids) AS recipient_groups_reconcile,
    (r.transaction_count = 6362620) AS transaction_count_reconciles,
    (ROUND(r.transaction_value, 2) = 1144392944759.77) AS monetary_value_reconciles,
    (st.transaction_share = 100.00000) AS transaction_share_reconciles,
    (st.monetary_share = 100.00000) AS monetary_share_reconciles,
    (t.rows_returned = 10 AND t.first_rank = 1 AND t.last_rank = 10) AS top_ten_reconciles,
    (rc.ranking_violations = 0) AS ranking_order_reconciles,

    -- Nine recipient-segment checks
    (s.segment_rows = 2) AS recipient_segment_rows_reconcile,
    (s.distinct_id_total = 2722362 AND s.customer_ids = 571961
        AND s.merchant_ids = 2150401) AS segment_identifier_counts_reconcile,
    (s.transaction_count_total = 6362620 AND s.customer_count = 4211125
        AND s.merchant_count = 2151495) AS segment_transaction_counts_reconcile,
    (ROUND(s.transaction_value_total, 2) = 1144392944759.77
        AND ROUND(s.customer_value, 2) = 1116299573621.40
        AND ROUND(s.merchant_value, 2) = 28093371138.37)
        AS segment_transaction_values_reconcile,
    (s.customer_average = 265083.46 AND s.merchant_average = 13057.60)
        AS segment_average_amounts_reconcile,
    (s.customer_volume_share = 66.1854 AND s.merchant_volume_share = 33.8146
        AND s.volume_share_total = 100.0000)
        AS segment_transaction_shares_reconcile,
    (s.customer_value_share = 97.5451 AND s.merchant_value_share = 2.4549
        AND s.value_share_total = 100.0000)
        AS segment_monetary_shares_reconcile,
    (s.other_count = 0) AS no_other_unclassified_recipients,
    (s.null_count = 0) AS no_null_recipient_identifiers
FROM recipient_totals r
CROSS JOIN recipient_share_totals st
CROSS JOIN top_ten t
CROSS JOIN ranking_check rc
CROSS JOIN segment_totals s;
