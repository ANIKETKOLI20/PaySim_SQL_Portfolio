
-- ============================================================
-- PaySim SQL Portfolio
-- Q10: Balance Movement Analysis
--
-- Business Question:
-- How do observed sender balance movements vary across
-- transaction categories and fraud labels, and how closely
-- do non-fraudulent sender movements reconcile with
-- category-specific expected balance changes?
--
-- For recipients, how do recorded balance movements compare
-- with transaction amounts for non-fraudulent TRANSFER
-- transactions involving tracked recipient accounts?
--
-- Objective:
-- Investigate sender balance movements across transaction
-- categories and fraud labels, evaluate non-fraudulent sender
-- balance reconciliation, and examine recipient-side
-- differences within the eligible TRANSFER population.
--
-- Sender Scope:
-- Actual sender movements are summarized by transaction
-- category and fraud label.
-- Expected movement and reconciliation classifications
-- apply to non-fraudulent transactions.
--
-- Recipient Scope:
-- Restricted to non-fraudulent TRANSFER transactions
-- involving tracked recipient accounts with available
-- opening and closing balances.
--
-- Recipient differences are observed balance snapshot
-- differences, not confirmed failed credits.
--
-- Variance Classification:
-- Exact Match          = difference is 0
-- Minor Variance       = absolute difference > 0 and <= 0.01
-- Material Difference  = absolute difference > 0.01
-- ============================================================

WITH transaction_movements AS (
    SELECT
        transaction_type,
        is_fraud,
        recipient_id,

        sender_new_balance - sender_old_balance
            AS actual_sender_movement,

        CASE
            WHEN is_fraud = 0 AND transaction_type = 'CASH_IN'
                THEN amount
            WHEN is_fraud = 0
             AND transaction_type IN ('CASH_OUT', 'DEBIT', 'PAYMENT', 'TRANSFER')
                THEN GREATEST(sender_old_balance - amount, 0) - sender_old_balance
            ELSE NULL
        END AS expected_sender_movement,

               CASE
            WHEN transaction_type = 'TRANSFER'
             AND is_fraud = 0
             AND recipient_id IS NOT NULL
             AND recipient_id NOT LIKE 'M%'
             AND recipient_old_balance IS NOT NULL
             AND recipient_new_balance IS NOT NULL
                THEN recipient_new_balance - recipient_old_balance
            ELSE NULL
        END AS actual_recipient_movement,

        CASE
            WHEN transaction_type = 'TRANSFER'
             AND is_fraud = 0
             AND recipient_id IS NOT NULL
             AND recipient_id NOT LIKE 'M%'
             AND recipient_old_balance IS NOT NULL
             AND recipient_new_balance IS NOT NULL
                THEN amount
            ELSE NULL
        END AS expected_recipient_movement,

        CASE
            WHEN transaction_type = 'TRANSFER' AND is_fraud = 1
                THEN 'FRAUD_LABELLED_NOT_EVALUATED'
            WHEN recipient_id LIKE 'M%'
                THEN 'NOT_TRACKED'
            WHEN transaction_type <> 'TRANSFER'
                THEN 'NOT_APPLICABLE'
            WHEN recipient_id IS NULL
              OR recipient_old_balance IS NULL
              OR recipient_new_balance IS NULL
                THEN 'NOT_EVALUATED'
            ELSE 'EVALUATED'
        END AS recipient_scope

    FROM public.transactions
),

movement_differences AS (
    SELECT
        *,
        actual_sender_movement - expected_sender_movement
            AS sender_difference,
        actual_recipient_movement - expected_recipient_movement
            AS recipient_difference
    FROM transaction_movements
)

SELECT
    transaction_type,
    is_fraud,
    COUNT(*) AS transaction_count,

    -- Sender balance movement
    ROUND(AVG(actual_sender_movement), 2)
        AS average_actual_sender_movement,
    ROUND(AVG(expected_sender_movement), 2)
        AS average_expected_sender_movement,

    SUM(CASE
        WHEN is_fraud = 0 AND sender_difference = 0 THEN 1
        ELSE 0
    END) AS sender_exact_match_count,

    SUM(CASE
        WHEN is_fraud = 0
         AND ABS(sender_difference) > 0
         AND ABS(sender_difference) <= 0.01 THEN 1
        ELSE 0
    END) AS sender_minor_variance_count,

    SUM(CASE
        WHEN is_fraud = 0
         AND ABS(sender_difference) > 0.01 THEN 1
        ELSE 0
    END) AS sender_material_difference_count,

    SUM(CASE
        WHEN is_fraud = 1 THEN 1
        ELSE 0
    END) AS sender_fraud_label_count,

    ROUND(SUM(CASE
        WHEN is_fraud = 0 AND sender_difference IS NOT NULL
            THEN ABS(sender_difference)
        ELSE 0
    END), 2) AS total_absolute_sender_difference,

    -- Recipient balance movement
    SUM(CASE WHEN recipient_scope = 'EVALUATED' THEN 1 ELSE 0 END)
        AS recipient_evaluated_count,

    ROUND(AVG(actual_recipient_movement), 2)
        AS average_actual_recipient_movement,
    ROUND(AVG(expected_recipient_movement), 2)
        AS average_expected_recipient_movement,

    SUM(CASE
        WHEN recipient_scope = 'EVALUATED'
         AND recipient_difference = 0 THEN 1
        ELSE 0
    END) AS recipient_exact_match_count,

    SUM(CASE
        WHEN recipient_scope = 'EVALUATED'
         AND ABS(recipient_difference) > 0
         AND ABS(recipient_difference) <= 0.01 THEN 1
        ELSE 0
    END) AS recipient_minor_variance_count,

    SUM(CASE
        WHEN recipient_scope = 'EVALUATED'
         AND ABS(recipient_difference) > 0.01 THEN 1
        ELSE 0
    END) AS recipient_material_difference_count,

    SUM(CASE
        WHEN recipient_scope = 'EVALUATED'
         AND ABS(recipient_difference) > 0 THEN 1
        ELSE 0
    END) AS recipient_total_difference_count,

    SUM(CASE WHEN recipient_scope = 'NOT_TRACKED' THEN 1 ELSE 0 END)
        AS recipient_not_tracked_count,

    SUM(CASE WHEN recipient_scope = 'NOT_APPLICABLE' THEN 1 ELSE 0 END)
        AS recipient_not_applicable_count,

    SUM(CASE WHEN recipient_scope = 'FRAUD_LABELLED_NOT_EVALUATED' THEN 1 ELSE 0 END)
        AS recipient_fraud_label_count,

    SUM(CASE WHEN recipient_scope = 'NOT_EVALUATED' THEN 1 ELSE 0 END)
        AS recipient_not_evaluated_count,

    ROUND(SUM(CASE
        WHEN recipient_scope = 'EVALUATED'
            THEN ABS(recipient_difference)
        ELSE 0
    END), 2) AS total_absolute_recipient_difference

FROM movement_differences
GROUP BY transaction_type, is_fraud
ORDER BY transaction_type, is_fraud;
