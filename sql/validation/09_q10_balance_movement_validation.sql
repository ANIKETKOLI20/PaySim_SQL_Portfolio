
-- ============================================================
-- PaySim SQL Portfolio
-- Q10: Balance Movement Analysis - Separate SQL Validation Results
--
-- Validates transaction counts, sender classifications,
-- recipient classifications and overall dataset controls.
-- Recipient differences are observed balance differences,
-- not confirmed failed credits.
-- ============================================================
WITH expected AS (
    SELECT * FROM (VALUES
        ('CASH_IN',  0, 1399284, 1186107, 213144, 33, 0),
        ('CASH_OUT', 0, 2233384, 2216411, 16969, 4, 0),
        ('CASH_OUT', 1, 4116, 0, 0, 0, 4116),
        ('DEBIT',    0, 41432, 40323, 1109, 0, 0),
        ('PAYMENT',  0, 2151495, 2046967, 104528, 0, 0),
        ('TRANSFER', 0, 528812, 526712, 2099, 1, 0),
        ('TRANSFER', 1, 4097, 0, 0, 0, 4097)
    ) AS e(type, fraud, txn_count, sender_exact, sender_minor,
           sender_material, sender_fraud)
),
source_rows AS (
    SELECT
        transaction_type AS type,
        is_fraud AS fraud,
        amount,
        CASE
            WHEN is_fraud = 1 THEN NULL
            WHEN transaction_type = 'CASH_IN'
                THEN sender_new_balance - sender_old_balance - amount
            WHEN transaction_type IN ('CASH_OUT', 'DEBIT', 'PAYMENT', 'TRANSFER')
                THEN sender_new_balance - GREATEST(sender_old_balance - amount, 0)
        END AS sender_diff,
        CASE
            WHEN transaction_type = 'TRANSFER' AND is_fraud = 1
                THEN 'FRAUD'
            WHEN recipient_id LIKE 'M%' THEN 'NOT_TRACKED'
            WHEN transaction_type <> 'TRANSFER' THEN 'NOT_APPLICABLE'
            WHEN recipient_id IS NULL
              OR recipient_old_balance IS NULL
              OR recipient_new_balance IS NULL THEN 'NOT_EVALUATED'
            ELSE 'EVALUATED'
        END AS recipient_scope,
        CASE
            WHEN transaction_type = 'TRANSFER' AND is_fraud = 0
             AND recipient_id IS NOT NULL AND recipient_id NOT LIKE 'M%'
                THEN recipient_new_balance - recipient_old_balance - amount
        END AS recipient_diff
    FROM public.transactions
),
classified AS (
    SELECT *,
        CASE
            WHEN fraud = 1 THEN 'FRAUD'
            WHEN sender_diff IS NULL THEN 'NOT_EVALUATED'
            WHEN sender_diff = 0 THEN 'EXACT'
            WHEN ABS(sender_diff) <= 0.01 THEN 'MINOR'
            ELSE 'MATERIAL'
        END AS sender_status,
        CASE
            WHEN recipient_scope <> 'EVALUATED' THEN recipient_scope
            WHEN recipient_diff = 0 THEN 'EXACT'
            WHEN ABS(recipient_diff) <= 0.01 THEN 'MINOR'
            ELSE 'MATERIAL'
        END AS recipient_status
    FROM source_rows
),
actual AS (
    SELECT
        type, fraud, COUNT(*) AS txn_count,
        COUNT(*) FILTER (WHERE sender_status = 'EXACT') AS sender_exact,
        COUNT(*) FILTER (WHERE sender_status = 'MINOR') AS sender_minor,
        COUNT(*) FILTER (WHERE sender_status = 'MATERIAL') AS sender_material,
        COUNT(*) FILTER (WHERE sender_status = 'FRAUD') AS sender_fraud,
        COUNT(*) FILTER (WHERE sender_status = 'NOT_EVALUATED') AS sender_not_evaluated,
        COUNT(*) FILTER (WHERE recipient_status IN ('EXACT','MINOR','MATERIAL')) AS recipient_evaluated,
        COUNT(*) FILTER (WHERE recipient_status = 'EXACT') AS recipient_exact,
        COUNT(*) FILTER (WHERE recipient_status = 'MINOR') AS recipient_minor,
        COUNT(*) FILTER (WHERE recipient_status = 'MATERIAL') AS recipient_material,
        COUNT(*) FILTER (WHERE recipient_status = 'NOT_TRACKED') AS recipient_not_tracked,
        COUNT(*) FILTER (WHERE recipient_status = 'NOT_APPLICABLE') AS recipient_not_applicable,
        COUNT(*) FILTER (WHERE recipient_status = 'FRAUD') AS recipient_fraud,
        COUNT(*) FILTER (WHERE recipient_status = 'NOT_EVALUATED') AS recipient_not_evaluated
    FROM classified
    GROUP BY type, fraud
),
groups AS (
    SELECT
        COALESCE(a.type, e.type) AS type,
        COALESCE(a.fraud, e.fraud) AS fraud,
        a.txn_count, e.txn_count AS expected_txn_count,
        a.sender_exact, a.sender_minor, a.sender_material, a.sender_fraud,
        a.sender_not_evaluated,
        a.recipient_evaluated, a.recipient_exact, a.recipient_minor,
        a.recipient_material, a.recipient_not_tracked,
        a.recipient_not_applicable, a.recipient_fraud,
        a.recipient_not_evaluated AS recipient_not_evaluated,
        e.sender_exact AS exp_sender_exact,
        e.sender_minor AS exp_sender_minor,
        e.sender_material AS exp_sender_material,
        e.sender_fraud AS exp_sender_fraud
    FROM actual a
    FULL JOIN expected e ON a.type = e.type AND a.fraud = e.fraud
),
overall AS (
    SELECT
        COUNT(*) AS txn_count,
        ROUND(SUM(amount), 2) AS txn_value,
        COUNT(*) FILTER (WHERE is_fraud = 1) AS fraud_count,
        COUNT(DISTINCT transaction_type) AS category_count,
        COUNT(DISTINCT (transaction_type, is_fraud)) AS group_count
    FROM public.transactions
),
checks AS (
    SELECT 'TRANSACTION_COUNT' AS check_name, type, fraud,
        COALESCE(txn_count, 0)::text AS actual_result,
        COALESCE(expected_txn_count, 0)::text AS expected_result,
        CASE WHEN txn_count = expected_txn_count THEN 'PASS' ELSE 'FAIL' END AS status
    FROM groups
    UNION ALL
    SELECT 'SENDER_CLASSIFICATION', type, fraud,
        CONCAT_WS('|', sender_exact, sender_minor, sender_material,
                  sender_fraud, sender_not_evaluated),
        CONCAT_WS('|', exp_sender_exact, exp_sender_minor,
                  exp_sender_material, exp_sender_fraud, 0),
        CASE WHEN ROW(sender_exact, sender_minor, sender_material,
                      sender_fraud, sender_not_evaluated)
                  IS NOT DISTINCT FROM
                  ROW(exp_sender_exact::bigint, exp_sender_minor::bigint,
                      exp_sender_material::bigint, exp_sender_fraud::bigint, 0::bigint)
             THEN 'PASS' ELSE 'FAIL' END
    FROM groups
    UNION ALL
    SELECT 'RECIPIENT_CLASSIFICATION', type, fraud,
        CONCAT_WS('|', recipient_evaluated, recipient_exact, recipient_minor,
                  recipient_material, recipient_not_tracked,
                  recipient_not_applicable, recipient_fraud,
                  recipient_not_evaluated),
        CASE WHEN type = 'TRANSFER' AND fraud = 0
             THEN '528812|370964|103879|53969|0|0|0|0'
             WHEN type = 'TRANSFER' AND fraud = 1
             THEN '0|0|0|0|0|0|4097|0'
             ELSE 'RECIPIENT_STATUSES_SUM_TO_TRANSACTION_COUNT' END,
        CASE
            WHEN COALESCE(recipient_evaluated, 0)
               + COALESCE(recipient_not_tracked, 0)
               + COALESCE(recipient_not_applicable, 0)
               + COALESCE(recipient_fraud, 0)
               + COALESCE(recipient_not_evaluated, 0)
                 <> COALESCE(txn_count, 0) THEN 'FAIL'
            WHEN type = 'TRANSFER' AND fraud = 0
             AND ROW(recipient_evaluated, recipient_exact, recipient_minor,
                     recipient_material, recipient_not_tracked,
                     recipient_not_applicable, recipient_fraud,
                     recipient_not_evaluated)
                 IS DISTINCT FROM ROW(528812::bigint, 370964::bigint, 103879::bigint, 53969::bigint,
                     0::bigint, 0::bigint, 0::bigint, 0::bigint)
                THEN 'FAIL'
            WHEN type = 'TRANSFER' AND fraud = 1
             AND ROW(recipient_evaluated, recipient_exact, recipient_minor,
                     recipient_material, recipient_not_tracked,
                     recipient_not_applicable, recipient_fraud,
                     recipient_not_evaluated)
                 IS DISTINCT FROM ROW(0::bigint, 0::bigint, 0::bigint, 0::bigint,
                     0::bigint, 0::bigint, 4097::bigint, 0::bigint)
                THEN 'FAIL'
            ELSE 'PASS'
        END
    FROM groups
    UNION ALL
    SELECT 'OVERALL_TRANSACTION_COUNT', 'ALL', NULL,
        txn_count::text, '6362620',
        CASE WHEN txn_count = 6362620 THEN 'PASS' ELSE 'FAIL' END
    FROM overall
    UNION ALL
    SELECT 'OVERALL_TRANSACTION_VALUE', 'ALL', NULL,
        txn_value::text, '1144392944759.77',
        CASE WHEN txn_value = 1144392944759.77 THEN 'PASS' ELSE 'FAIL' END
    FROM overall
    UNION ALL
    SELECT 'FRAUD_LABELLED_TRANSACTIONS', 'ALL', NULL,
        fraud_count::text, '8213',
        CASE WHEN fraud_count = 8213 THEN 'PASS' ELSE 'FAIL' END
    FROM overall
    UNION ALL
    SELECT 'TRANSACTION_CATEGORIES', 'ALL', NULL,
        category_count::text, '5',
        CASE WHEN category_count = 5 THEN 'PASS' ELSE 'FAIL' END
    FROM overall
    UNION ALL
    SELECT 'CATEGORY_FRAUD_GROUPS', 'ALL', NULL,
        group_count::text, '7',
        CASE WHEN group_count = 7 THEN 'PASS' ELSE 'FAIL' END
    FROM overall
)
SELECT check_name, type AS transaction_type, fraud AS is_fraud, actual_result, expected_result, status AS validation_status
FROM checks
ORDER BY check_name, transaction_type, is_fraud;
