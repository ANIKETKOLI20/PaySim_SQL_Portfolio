
-- PaySim SQL Portfolio
-- Task 4C: Create transaction table
-- Database: paysim_analytics
-- Table: public.transactions

CREATE TABLE public.transactions (

    -- Database-generated row identifier
    record_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    -- Original PaySim transaction attributes
    step SMALLINT NOT NULL
        CHECK (step BETWEEN 1 AND 744),

    transaction_type TEXT NOT NULL
        CHECK (
            transaction_type IN (
                'CASH_IN',
                'CASH_OUT',
                'DEBIT',
                'PAYMENT',
                'TRANSFER'
            )
        ),

    amount NUMERIC(18,2) NOT NULL
        CHECK (amount >= 0),

    sender_id TEXT NOT NULL,

    sender_old_balance NUMERIC(18,2) NOT NULL
        CHECK (sender_old_balance >= 0),

    sender_new_balance NUMERIC(18,2) NOT NULL
        CHECK (sender_new_balance >= 0),

    recipient_id TEXT NOT NULL,

    recipient_old_balance NUMERIC(18,2) NOT NULL
        CHECK (recipient_old_balance >= 0),

    recipient_new_balance NUMERIC(18,2) NOT NULL
        CHECK (recipient_new_balance >= 0),

    is_fraud SMALLINT NOT NULL
        CHECK (is_fraud IN (0, 1)),

    is_flagged_fraud SMALLINT NOT NULL
        CHECK (is_flagged_fraud IN (0, 1))
);

-- Document the generated identifier
COMMENT ON COLUMN public.transactions.record_id IS
'Database-generated row identifier; not an original PaySim transaction ID.';
