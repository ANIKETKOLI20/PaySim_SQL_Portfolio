
-- ============================================================
-- PaySim SQL Portfolio
-- Q10: Balance Movement Analysis
--
-- Objective:
-- Examine sender and recipient balance movements,
-- compare observed movements against expected movements,
-- and identify balance reconciliation exceptions.
--
-- Output Grain:
-- One row per transaction category.
--
-- Metrics:
-- 1. Transaction count
-- 2. Total transaction value
-- 3. Sender balance matches
-- 4. Sender balance mismatches
-- 5. Annulled fraud transactions
-- 6. Absolute sender discrepancy
-- 7. Evaluated recipient balances
-- 8. Untracked merchant balances
-- 9. Recipient balance not applicable
-- 10. Annulled recipient-side fraud transactions
-- 11. Recipient balance matches
-- 12. Recipient balance mismatches
-- 13. Absolute recipient discrepancy
--
-- Data Treatment:
-- Merchant balances (recipient ID beginning with M)
-- are not tracked.
--
-- Recipient reconciliation is applicable only to
-- tracked TRANSFER destination accounts.
--
-- Fraud-labelled transactions are treated separately
-- because fraudulent transactions are annulled in PaySim.
--
-- Important:
-- Discrepancies are reconciliation exceptions.
-- They are not automatically evidence of fraud,
-- data corruption or actual financial loss.
-- ============================================================


-- Step 1: Calculate transaction-level balance movements

WITH transaction_balance_movements AS (

    SELECT

        record_id,
        transaction_type,
        amount,
        is_fraud,

        sender_id,
        recipient_id,

        sender_old_balance,
        sender_new_balance,

        recipient_old_balance,
        recipient_new_balance,


        -- Actual sender balance movement
        sender_new_balance - sender_old_balance
            AS actual_sender_balance_change,


        -- Expected sender balance movement
        CASE

            -- CASH_IN increases the originating account
            WHEN transaction_type = 'CASH_IN'
                THEN amount

            -- Other transaction categories decrease
            -- the originating account
            WHEN transaction_type IN (
                'CASH_OUT',
                'DEBIT',
                'PAYMENT',
                'TRANSFER'
            )
                THEN -amount

            ELSE NULL

        END AS expected_sender_balance_change,


        -- Actual recipient balance movement
        CASE

            WHEN recipient_id LIKE 'M%'
                THEN NULL

            ELSE recipient_new_balance - recipient_old_balance

        END AS actual_recipient_balance_change,


        -- Expected recipient movement
        -- Only TRANSFER represents a tracked
        -- mobile-wallet-to-mobile-wallet credit.
        CASE

            WHEN transaction_type = 'TRANSFER'
             AND recipient_id NOT LIKE 'M%'
                THEN amount

            ELSE NULL

        END AS expected_recipient_balance_change

    FROM public.transactions

),


-- Step 2: Evaluate sender balance consistency

sender_balance_checks AS (

    SELECT

        *,

        CASE

            -- Fraud-labelled transactions are annulled
            WHEN is_fraud = 1
                THEN 'ANNULLED_FRAUD'

            WHEN expected_sender_balance_change IS NULL
                THEN 'NOT_EVALUATED'

            WHEN actual_sender_balance_change =
                 expected_sender_balance_change
                THEN 'MATCH'

            ELSE 'MISMATCH'

        END AS sender_balance_status,


        actual_sender_balance_change
            - expected_sender_balance_change
            AS sender_balance_difference

    FROM transaction_balance_movements

),


-- Step 3: Evaluate recipient balance consistency

transaction_balance_checks AS (

    SELECT

        *,

        CASE

            -- Merchant balance information is unavailable
            WHEN recipient_id LIKE 'M%'
                THEN 'NOT_TRACKED'

            -- Cash-in, cash-out and debit do not represent
            -- a tracked wallet-to-wallet recipient credit.
            WHEN transaction_type <> 'TRANSFER'
                THEN 'NOT_APPLICABLE'

            -- Fraudulent transfers are annulled
            WHEN is_fraud = 1
                THEN 'ANNULLED_FRAUD'

            WHEN actual_recipient_balance_change =
                 expected_recipient_balance_change
                THEN 'MATCH'

            ELSE 'MISMATCH'

        END AS recipient_balance_status,


        actual_recipient_balance_change
            - expected_recipient_balance_change
            AS recipient_balance_difference

    FROM sender_balance_checks

),


-- Step 4: Aggregate results by transaction category

category_balance_summary AS (

    SELECT

        transaction_type,

        COUNT(*) AS transaction_count,

        SUM(amount) AS total_transaction_value,


        -- Sender balance checks

        SUM(
            CASE
                WHEN sender_balance_status = 'MATCH'
                    THEN 1 ELSE 0
            END
        ) AS sender_balance_match_count,


        SUM(
            CASE
                WHEN sender_balance_status = 'MISMATCH'
                    THEN 1 ELSE 0
            END
        ) AS sender_balance_mismatch_count,


        SUM(
            CASE
                WHEN sender_balance_status = 'ANNULLED_FRAUD'
                    THEN 1 ELSE 0
            END
        ) AS sender_annulled_fraud_count,


        ROUND(
            SUM(
                CASE
                    WHEN sender_balance_status = 'MISMATCH'
                        THEN ABS(sender_balance_difference)
                    ELSE 0
                END
            ),
            2
        ) AS total_absolute_sender_discrepancy,


        -- Recipient balance eligibility

        SUM(
            CASE
                WHEN recipient_balance_status IN ('MATCH', 'MISMATCH')
                    THEN 1 ELSE 0
            END
        ) AS recipient_balance_evaluated_count,


        SUM(
            CASE
                WHEN recipient_balance_status = 'NOT_TRACKED'
                    THEN 1 ELSE 0
            END
        ) AS recipient_balance_untracked_count,


        SUM(
            CASE
                WHEN recipient_balance_status = 'NOT_APPLICABLE'
                    THEN 1 ELSE 0
            END
        ) AS recipient_balance_not_applicable_count,


        SUM(
            CASE
                WHEN recipient_balance_status = 'ANNULLED_FRAUD'
                    THEN 1 ELSE 0
            END
        ) AS recipient_annulled_fraud_count,


        -- Recipient reconciliation results

        SUM(
            CASE
                WHEN recipient_balance_status = 'MATCH'
                    THEN 1 ELSE 0
            END
        ) AS recipient_balance_match_count,


        SUM(
            CASE
                WHEN recipient_balance_status = 'MISMATCH'
                    THEN 1 ELSE 0
            END
        ) AS recipient_balance_mismatch_count,


        ROUND(
            SUM(
                CASE
                    WHEN recipient_balance_status = 'MISMATCH'
                        THEN ABS(recipient_balance_difference)
                    ELSE 0
                END
            ),
            2
        ) AS total_absolute_recipient_discrepancy


    FROM transaction_balance_checks

    GROUP BY transaction_type

)


-- Step 5: Final category-level analytical output

SELECT

    transaction_type,

    transaction_count,

    total_transaction_value,

    sender_balance_match_count,

    sender_balance_mismatch_count,

    sender_annulled_fraud_count,

    total_absolute_sender_discrepancy,

    recipient_balance_evaluated_count,

    recipient_balance_untracked_count,

    recipient_balance_not_applicable_count,

    recipient_annulled_fraud_count,

    recipient_balance_match_count,

    recipient_balance_mismatch_count,

    total_absolute_recipient_discrepancy

FROM category_balance_summary

ORDER BY transaction_type ASC;
