-- ============================================================
-- PaySim SQL Portfolio
-- Q10: Balance Movement Diagnostic Investigation
--
-- Objective:
-- Investigate sender and recipient balance movements, compare
-- observed movements with diagnostic expectations, and inspect
-- the patterns behind remaining reconciliation differences.
--
-- This is a DIAGNOSTIC file, not the final independent
-- validation file. It is intended to explain patterns and
-- inspect records before final Q10 interpretation.
--
-- Investigations:
-- 1. Sender strict formula vs zero-floor candidate formula
-- 2. Recipient movement patterns for tracked TRANSFER records
-- 3. CASH_IN balance movement classification
-- 4. Largest CASH_IN balance exceptions
-- 5. Remaining outgoing mismatches by is_flagged_fraud
-- 6. Largest tracked recipient TRANSFER mismatches
-- 7. All positive-amount CASH_IN records with no sender movement
-- 8. Repeated incoming TRANSFER activity per recipient and step
-- 9. Other same-step activity involving sampled mismatch recipients
--
-- Important interpretation notes:
-- * is_fraud and is_flagged_fraud are different fields.
-- * Fraud-labelled transactions are excluded from ordinary
--   movement checks because PaySim models these transactions
--   as annulled.
-- * Merchant destination balances are not suitable for
--   recipient balance reconciliation; recipient IDs beginning
--   with 'M' are excluded from tracked-recipient checks.
-- * The zero-floor formula is tested as a candidate rule. A
--   match is empirical evidence in this dataset, not proof that
--   every remaining mismatch is an error or that the formula
--   explains every simulator behaviour.
-- * A step represents an hour. Grouping by recipient and step
--   identifies same-hour activity but cannot establish the
--   exact order of transactions within that hour.
-- * A discrepancy is an observed difference under the stated
--   rule. It is not automatically fraud, corruption, or loss.
-- ============================================================


-- ============================================================
-- INVESTIGATION 1
-- Sender: strict balance formula vs zero-floor candidate
--
-- CASH_IN expected movement under the simple rule: +amount
-- Outgoing expected movement under the simple rule: -amount
-- Candidate zero-floor rule for outgoing records:
-- GREATEST(sender_old_balance - amount, 0)
-- Fraud-labelled records are excluded.
-- ============================================================

SELECT
    transaction_type,

    COUNT(*) FILTER (
        WHERE is_fraud = 0
    ) AS evaluated_transactions,

    COUNT(*) FILTER (
        WHERE is_fraud = 0
          AND (
              (
                  transaction_type = 'CASH_IN'
                  AND sender_new_balance = sender_old_balance + amount
              )
              OR
              (
                  transaction_type IN ('CASH_OUT', 'DEBIT', 'PAYMENT', 'TRANSFER')
                  AND sender_new_balance = sender_old_balance - amount
              )
          )
    ) AS strict_balance_matches,

    COUNT(*) FILTER (
        WHERE is_fraud = 0
          AND transaction_type IN ('CASH_OUT', 'DEBIT', 'PAYMENT', 'TRANSFER')
          AND sender_new_balance = GREATEST(sender_old_balance - amount, 0)
    ) AS zero_floor_formula_matches,

    COUNT(*) FILTER (
        WHERE is_fraud = 0
          AND transaction_type IN ('CASH_OUT', 'DEBIT', 'PAYMENT', 'TRANSFER')
          AND amount > sender_old_balance
          AND sender_new_balance = 0
    ) AS amount_exceeds_opening_balance_zero_close,

    COUNT(*) FILTER (
        WHERE is_fraud = 0
          AND transaction_type IN ('CASH_OUT', 'DEBIT', 'PAYMENT', 'TRANSFER')
          AND sender_new_balance <> GREATEST(sender_old_balance - amount, 0)
    ) AS remaining_outgoing_mismatches,

    COUNT(*) FILTER (
        WHERE is_fraud = 0
          AND transaction_type = 'CASH_IN'
          AND sender_new_balance < sender_old_balance + amount
    ) AS cash_in_below_expected_balance,

    COUNT(*) FILTER (
        WHERE is_fraud = 0
          AND transaction_type = 'CASH_IN'
          AND sender_new_balance > sender_old_balance + amount
    ) AS cash_in_above_expected_balance

FROM public.transactions
GROUP BY transaction_type
ORDER BY transaction_type;


-- ============================================================
-- INVESTIGATION 2
-- Recipient movement patterns for tracked TRANSFER records
--
-- Only non-fraudulent TRANSFER records with non-merchant
-- destination IDs are evaluated.
-- ============================================================

SELECT
    COUNT(*) AS evaluated_transfer_transactions,

    COUNT(*) FILTER (
        WHERE recipient_new_balance = recipient_old_balance + amount
    ) AS full_credit_matches,

    COUNT(*) FILTER (
        WHERE recipient_new_balance = recipient_old_balance
    ) AS unchanged_recipient_balances,

    COUNT(*) FILTER (
        WHERE recipient_new_balance > recipient_old_balance
          AND recipient_new_balance < recipient_old_balance + amount
    ) AS partial_balance_increases,

    COUNT(*) FILTER (
        WHERE recipient_new_balance < recipient_old_balance
    ) AS recipient_balance_decreases,

    COUNT(*) FILTER (
        WHERE recipient_new_balance > recipient_old_balance + amount
    ) AS increases_above_expected_amount,

    ROUND(
        SUM(
            CASE
                WHEN recipient_new_balance <> recipient_old_balance + amount
                THEN ABS(
                    recipient_new_balance - recipient_old_balance - amount
                )
                ELSE 0
            END
        ),
        2
    ) AS total_absolute_difference

FROM public.transactions
WHERE transaction_type = 'TRANSFER'
  AND is_fraud = 0
  AND recipient_id IS NOT NULL
  AND recipient_id NOT LIKE 'M%';


-- ============================================================
-- INVESTIGATION 3
-- CASH_IN sender balance movement classification
--
-- Differences are retained exactly. A 0.01 difference is
-- reported as a one-cent variance; this query does not assume
-- its cause is floating-point error or rounding behaviour.
-- ============================================================

WITH cash_in_profile AS (
    SELECT
        record_id,
        amount,
        sender_old_balance,
        sender_new_balance,
        sender_new_balance - sender_old_balance AS actual_balance_change,
        (sender_new_balance - sender_old_balance) - amount AS balance_difference,

        CASE
            WHEN sender_new_balance - sender_old_balance = amount
                THEN 'EXACT_CREDIT'
            WHEN sender_new_balance = sender_old_balance
                THEN 'NO_BALANCE_CHANGE'
            WHEN sender_new_balance > sender_old_balance
             AND sender_new_balance - sender_old_balance < amount
                THEN 'PARTIAL_CREDIT'
            WHEN sender_new_balance - sender_old_balance > amount
                THEN 'CREDIT_ABOVE_AMOUNT'
            WHEN sender_new_balance < sender_old_balance
                THEN 'BALANCE_DECREASE'
            ELSE 'OTHER'
        END AS movement_pattern

    FROM public.transactions
    WHERE transaction_type = 'CASH_IN'
      AND is_fraud = 0
)
SELECT
    movement_pattern,
    COUNT(*) AS transaction_count,
    ROUND(AVG(ABS(balance_difference)), 2) AS average_absolute_difference,
    MIN(balance_difference) AS minimum_difference,
    MAX(balance_difference) AS maximum_difference
FROM cash_in_profile
GROUP BY movement_pattern
ORDER BY transaction_count DESC, movement_pattern;


-- ============================================================
-- INVESTIGATION 4
-- Largest CASH_IN sender balance exceptions
--
-- Returns up to 20 non-fraudulent CASH_IN records whose
-- observed sender movement differs from the transaction amount.
-- ============================================================

SELECT
    record_id,
    step,
    sender_id,
    amount,
    sender_old_balance,
    sender_new_balance,
    sender_new_balance - sender_old_balance AS actual_balance_change,
    sender_new_balance - sender_old_balance - amount AS balance_difference,
    is_flagged_fraud
FROM public.transactions
WHERE transaction_type = 'CASH_IN'
  AND is_fraud = 0
  AND sender_new_balance - sender_old_balance <> amount
ORDER BY ABS(sender_new_balance - sender_old_balance - amount) DESC,
         record_id
LIMIT 20;


-- ============================================================
-- INVESTIGATION 5
-- Remaining outgoing sender mismatches by is_flagged_fraud
--
-- Uses the zero-floor candidate formula. is_flagged_fraud is
-- grouped separately from is_fraud; it is not treated as ground
-- truth for whether a transaction is fraudulent.
-- ============================================================

SELECT
    transaction_type,
    is_flagged_fraud,
    COUNT(*) AS remaining_mismatch_count,
    ROUND(
        SUM(
            ABS(
                sender_new_balance
                - GREATEST(sender_old_balance - amount, 0)
            )
        ),
        2
    ) AS total_absolute_difference
FROM public.transactions
WHERE transaction_type IN ('CASH_OUT', 'DEBIT', 'PAYMENT', 'TRANSFER')
  AND is_fraud = 0
  AND sender_new_balance <> GREATEST(sender_old_balance - amount, 0)
GROUP BY transaction_type, is_flagged_fraud
ORDER BY transaction_type, is_flagged_fraud;


-- ============================================================
-- INVESTIGATION 6
-- Largest tracked recipient TRANSFER balance mismatches
--
-- Returns up to 20 non-fraudulent TRANSFER records to tracked
-- (non-merchant) destination accounts where the recorded
-- recipient increase differs from the transaction amount.
-- ============================================================

SELECT
    record_id,
    step,
    sender_id,
    recipient_id,
    amount,
    recipient_old_balance,
    recipient_new_balance,
    recipient_new_balance - recipient_old_balance AS actual_balance_change,
    recipient_new_balance - recipient_old_balance - amount AS balance_difference,
    is_flagged_fraud
FROM public.transactions
WHERE transaction_type = 'TRANSFER'
  AND is_fraud = 0
  AND recipient_id IS NOT NULL
  AND recipient_id NOT LIKE 'M%'
  AND recipient_new_balance - recipient_old_balance <> amount
ORDER BY ABS(recipient_new_balance - recipient_old_balance - amount) DESC,
         record_id
LIMIT 20;


-- ============================================================
-- INVESTIGATION 7
-- All positive-amount CASH_IN records with no sender movement
--
-- This is the complete set of unchanged-balance CASH_IN
-- exceptions identified in the earlier classification, not
-- just a sample. The previously observed count was 33; this
-- query lets the database reproduce and inspect that count.
-- ============================================================

SELECT
    record_id,
    step,
    sender_id,
    amount,
    sender_old_balance,
    sender_new_balance,
    sender_new_balance - sender_old_balance AS actual_balance_change,
    sender_new_balance - sender_old_balance - amount AS balance_difference,
    is_flagged_fraud
FROM public.transactions
WHERE transaction_type = 'CASH_IN'
  AND is_fraud = 0
  AND amount > 0
  AND sender_new_balance = sender_old_balance
ORDER BY amount DESC, record_id;


-- ============================================================
-- INVESTIGATION 8
-- Repeated incoming TRANSFER activity per recipient and step
--
-- Groups incoming non-fraudulent TRANSFER records by recipient
-- and simulation step (one hour). Retains groups that have
-- multiple incoming transfers and at least one recipient
-- balance movement that differs from the transfer amount.
--
-- This tests whether same-hour repeated incoming activity is
-- present among mismatch groups. It does not establish the
-- precise order of transfers within the hour or prove causation.
-- Returns up to 50 groups for inspection.
-- ============================================================

WITH recipient_step_activity AS (
    SELECT
        recipient_id,
        step,
        COUNT(*) AS incoming_transfer_count,
        SUM(amount) AS total_incoming_transfer_amount,
        COUNT(*) FILTER (
            WHERE recipient_new_balance - recipient_old_balance <> amount
        ) AS recipient_mismatch_count,
        MIN(recipient_old_balance) AS minimum_recorded_old_balance,
        MAX(recipient_old_balance) AS maximum_recorded_old_balance,
        MIN(recipient_new_balance) AS minimum_recorded_new_balance,
        MAX(recipient_new_balance) AS maximum_recorded_new_balance,
        COUNT(DISTINCT recipient_old_balance) AS distinct_old_balance_values,
        COUNT(DISTINCT recipient_new_balance) AS distinct_new_balance_values
    FROM public.transactions
    WHERE transaction_type = 'TRANSFER'
      AND is_fraud = 0
      AND recipient_id IS NOT NULL
      AND recipient_id NOT LIKE 'M%'
    GROUP BY recipient_id, step
    HAVING COUNT(*) > 1
       AND COUNT(*) FILTER (
           WHERE recipient_new_balance - recipient_old_balance <> amount
       ) > 0
)
SELECT
    recipient_id,
    step,
    incoming_transfer_count,
    recipient_mismatch_count,
    total_incoming_transfer_amount,
    minimum_recorded_old_balance,
    maximum_recorded_old_balance,
    minimum_recorded_new_balance,
    maximum_recorded_new_balance,
    distinct_old_balance_values,
    distinct_new_balance_values
FROM recipient_step_activity
ORDER BY recipient_mismatch_count DESC,
         incoming_transfer_count DESC,
         total_incoming_transfer_amount DESC,
         recipient_id,
         step
LIMIT 50;

