
-- ============================================================
-- PaySim SQL Portfolio
-- Q9: Transaction Amount Distribution Validation
--
-- Objective:
-- Validate category-level transaction amount statistics,
-- transaction-count reconciliation, monetary reconciliation,
-- zero-amount records and distribution boundaries.
--
-- Validation Scope:
-- 1. Transaction count reconciliation
-- 2. Monetary value reconciliation
-- 3. Transaction category count
-- 4. Zero-amount transaction count
-- 5. Minimum and maximum amount
-- 6. Average and median boundary checks
-- ============================================================


-- Step 1: Calculate independent category-level metrics

WITH category_metrics AS (

    SELECT
        transaction_type,
        COUNT(*) AS transaction_count,
        SUM(amount) AS total_transaction_value,
        AVG(amount) AS average_transaction_amount,
        ROUND(
    (
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY amount)
    )::numeric,
    2
) AS median_transaction_amount,,
        MIN(amount) AS minimum_transaction_amount,
        MAX(amount) AS maximum_transaction_amount,
        SUM(
            CASE
                WHEN amount = 0 THEN 1
                ELSE 0
            END
        ) AS zero_amount_transactions

    FROM public.transactions
    GROUP BY transaction_type

),


-- Step 2: Calculate overall dataset metrics

global_metrics AS (

    SELECT
        COUNT(*) AS total_transactions,
        SUM(amount) AS total_transaction_value,
        COUNT(DISTINCT transaction_type)
            AS distinct_transaction_categories,
        SUM(
            CASE
                WHEN amount = 0 THEN 1
                ELSE 0
            END
        ) AS total_zero_amount_transactions,
        MIN(amount) AS overall_minimum_amount,
        MAX(amount) AS overall_maximum_amount

    FROM public.transactions

),


-- Step 3: Reconcile category-level totals

category_reconciliation AS (

    SELECT
        COUNT(*) AS category_groups,

        SUM(transaction_count)
            AS reconciled_transaction_count,

        SUM(total_transaction_value)
            AS reconciled_transaction_value,

        SUM(zero_amount_transactions)
            AS reconciled_zero_amount_count,

        SUM(
            CASE
                WHEN average_transaction_amount < minimum_transaction_amount
                  OR average_transaction_amount > maximum_transaction_amount
                THEN 1
                ELSE 0
            END
        ) AS average_boundary_violations,

        SUM(
            CASE
                WHEN median_transaction_amount < minimum_transaction_amount
                  OR median_transaction_amount > maximum_transaction_amount
                THEN 1
                ELSE 0
            END
        ) AS median_boundary_violations

    FROM category_metrics

)


-- Step 4: Produce the final validation report

SELECT

    g.total_transactions,
    c.reconciled_transaction_count,
    g.total_transaction_value,
    c.reconciled_transaction_value,
    g.distinct_transaction_categories,
    c.category_groups,
    g.total_zero_amount_transactions,
    c.reconciled_zero_amount_count,
    g.overall_minimum_amount,
    g.overall_maximum_amount,
    c.average_boundary_violations,
    c.median_boundary_violations,

    -- Validation 1: Transaction count reconciliation

    (
        g.total_transactions = c.reconciled_transaction_count
    ) AS transaction_count_reconciles,


    -- Validation 2: Monetary value reconciliation

    (
        ROUND(g.total_transaction_value, 2)
        = ROUND(c.reconciled_transaction_value, 2)
    ) AS monetary_value_reconciles,


    -- Validation 3: Expected five transaction categories

    (
        g.distinct_transaction_categories = 5
        AND c.category_groups = 5
    ) AS category_count_reconciles,


    -- Validation 4: Zero-amount transaction reconciliation

    (
        g.total_zero_amount_transactions = c.reconciled_zero_amount_count
    ) AS zero_amount_reconciles,


    -- Validation 5: Average amount boundaries

    (
        c.average_boundary_violations = 0
    ) AS average_boundaries_valid,


    -- Validation 6: Median amount boundaries

    (
        c.median_boundary_violations = 0
    ) AS median_boundaries_valid,


    -- Validation 7: Zero-amount audit expectation

    (
        g.total_zero_amount_transactions = 16
    ) AS zero_amount_audit_matches

FROM global_metrics g
CROSS JOIN category_reconciliation c;
