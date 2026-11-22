-- ============================================================
-- PaySim SQL Portfolio
-- Q9: Transaction Amount Distribution Validation
--
-- Objective:
-- Independently validate transaction amount statistics by
-- transaction_type and is_fraud.
--
-- Checks:
-- 1. Overall transaction count and monetary value
-- 2. Five transaction categories and seven type/fraud groups
-- 3. Fraud-label population counts
-- 4. Each group's count, value, average, median, minimum and maximum
-- 5. Zero-amount reconciliation
-- 6. Average and median distribution boundaries
-- ============================================================

WITH actual_group_metrics AS (
    SELECT
        transaction_type,
        is_fraud,
        COUNT(*) AS transaction_count,
        SUM(amount) AS total_transaction_value,
        ROUND(AVG(amount), 2) AS average_transaction_amount,
        ROUND(
            PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY amount)::numeric,
            2
        ) AS median_transaction_amount,
        MIN(amount) AS minimum_transaction_amount,
        MAX(amount) AS maximum_transaction_amount,
        COUNT(*) FILTER (WHERE amount = 0) AS zero_amount_transactions
    FROM public.transactions
    GROUP BY transaction_type, is_fraud
),

expected_group_metrics AS (
    SELECT *
    FROM (VALUES
        ('CASH_OUT'::text, 0::integer, 2233384::bigint, 388423792980.66::numeric, 173917.16::numeric, 146946.56::numeric, 0.01::numeric, 2847566.62::numeric),
        ('PAYMENT'::text, 0::integer, 2151495::bigint, 28093371138.37::numeric, 13057.60::numeric, 9482.19::numeric, 0.02::numeric, 238637.98::numeric),
        ('CASH_IN'::text, 0::integer, 1399284::bigint, 236367391912.46::numeric, 168920.24::numeric, 143427.71::numeric, 0.04::numeric, 1915267.90::numeric),
        ('TRANSFER'::text, 0::integer, 528812::bigint, 479224774079.16::numeric, 906229.01::numeric, 486521.91::numeric, 2.60::numeric, 92445516.64::numeric),
        ('DEBIT'::text, 0::integer, 41432::bigint, 227199221.28::numeric, 5483.67::numeric, 3048.99::numeric, 0.55::numeric, 569077.51::numeric),
        ('CASH_OUT'::text, 1::integer, 4116::bigint, 5989202243.83::numeric, 1455102.59::numeric, 435516.91::numeric, 0.00::numeric, 10000000.00::numeric),
        ('TRANSFER'::text, 1::integer, 4097::bigint, 6067213184.01::numeric, 1480891.67::numeric, 445705.76::numeric, 63.80::numeric, 10000000.00::numeric)
    ) AS v(
        transaction_type,
        is_fraud,
        transaction_count,
        total_transaction_value,
        average_transaction_amount,
        median_transaction_amount,
        minimum_transaction_amount,
        maximum_transaction_amount
    )
),

group_comparison AS (
    SELECT
        COUNT(*) FILTER (
            WHERE e.transaction_type IS NOT NULL
              AND a.transaction_type IS NOT NULL
        ) AS matched_group_count,
        COUNT(*) FILTER (
            WHERE e.transaction_type IS NULL
               OR a.transaction_type IS NULL
        ) AS missing_or_unexpected_group_count,
        COUNT(*) FILTER (
            WHERE e.transaction_type IS NOT NULL
              AND a.transaction_type IS NOT NULL
              AND (
                    a.transaction_count <> e.transaction_count
                 OR ROUND(a.total_transaction_value, 2) <> e.total_transaction_value
              )
        ) AS count_or_value_mismatches,
        COUNT(*) FILTER (
            WHERE e.transaction_type IS NOT NULL
              AND a.transaction_type IS NOT NULL
              AND (
                    a.average_transaction_amount <> e.average_transaction_amount
                 OR a.median_transaction_amount <> e.median_transaction_amount
              )
        ) AS average_or_median_mismatches,
        COUNT(*) FILTER (
            WHERE e.transaction_type IS NOT NULL
              AND a.transaction_type IS NOT NULL
              AND (
                    a.minimum_transaction_amount <> e.minimum_transaction_amount
                 OR a.maximum_transaction_amount <> e.maximum_transaction_amount
              )
        ) AS minimum_or_maximum_mismatches
    FROM expected_group_metrics e
    FULL OUTER JOIN actual_group_metrics a
        ON a.transaction_type = e.transaction_type
       AND a.is_fraud = e.is_fraud
),

global_metrics AS (
    SELECT
        COUNT(*) AS total_transactions,
        SUM(amount) AS total_transaction_value,
        COUNT(DISTINCT transaction_type) AS distinct_transaction_categories,
        COUNT(DISTINCT is_fraud) AS distinct_fraud_labels,
        COUNT(*) FILTER (WHERE is_fraud = 0) AS non_fraud_label_count,
        COUNT(*) FILTER (WHERE is_fraud = 1) AS fraud_label_count,
        COUNT(*) FILTER (WHERE amount = 0) AS total_zero_amount_transactions,
        MIN(amount) AS overall_minimum_amount,
        MAX(amount) AS overall_maximum_amount
    FROM public.transactions
),

boundary_metrics AS (
    SELECT
        COUNT(*) FILTER (
            WHERE average_transaction_amount < minimum_transaction_amount
               OR average_transaction_amount > maximum_transaction_amount
        ) AS average_boundary_violations,
        COUNT(*) FILTER (
            WHERE median_transaction_amount < minimum_transaction_amount
               OR median_transaction_amount > maximum_transaction_amount
        ) AS median_boundary_violations,
        SUM(zero_amount_transactions) AS grouped_zero_amount_transactions,
        COUNT(*) AS actual_group_count
    FROM actual_group_metrics
)

SELECT
    -- Overall controls
    g.total_transactions,
    ROUND(g.total_transaction_value, 2) AS total_transaction_value,
    g.distinct_transaction_categories,
    g.distinct_fraud_labels,
    g.non_fraud_label_count,
    g.fraud_label_count,
    g.total_zero_amount_transactions,
    g.overall_minimum_amount,
    g.overall_maximum_amount,

    -- Group and segment comparison controls
    b.actual_group_count,
    gc.matched_group_count,
    gc.missing_or_unexpected_group_count,
    gc.count_or_value_mismatches,
    gc.average_or_median_mismatches,
    gc.minimum_or_maximum_mismatches,
    b.grouped_zero_amount_transactions,
    b.average_boundary_violations,
    b.median_boundary_violations,

    -- Independent validation checks
    (g.total_transactions = 6362620) AS transaction_count_reconciles,
    (ROUND(g.total_transaction_value, 2) = 1144392944759.77) AS monetary_value_reconciles,
    (g.distinct_transaction_categories = 5 AND b.actual_group_count = 7) AS category_and_group_counts_reconcile,
    (g.distinct_fraud_labels = 2 AND g.non_fraud_label_count = 6354407 AND g.fraud_label_count = 8213) AS fraud_label_population_reconciles,
    (gc.matched_group_count = 7 AND gc.missing_or_unexpected_group_count = 0) AS seven_expected_groups_reconcile,
    (gc.count_or_value_mismatches = 0) AS group_counts_and_values_reconcile,
    (gc.average_or_median_mismatches = 0) AS group_averages_and_medians_reconcile,
    (gc.minimum_or_maximum_mismatches = 0) AS group_minimums_and_maximums_reconcile,
    (g.total_zero_amount_transactions = 16 AND b.grouped_zero_amount_transactions = 16) AS zero_amount_reconciles,
    (b.average_boundary_violations = 0 AND b.median_boundary_violations = 0) AS distribution_boundaries_valid

FROM global_metrics g
CROSS JOIN group_comparison gc
CROSS JOIN boundary_metrics b;
