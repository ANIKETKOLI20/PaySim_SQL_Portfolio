-- PaySim SQL Portfolio
-- Task 4D: Import original CSV into PostgreSQL
-- Target: public.transactions
--
-- Prerequisites:
-- 1. Connect to the paysim_analytics database.
-- 2. Create public.transactions before running this script.
-- 3. Start psql from the PaySim_SQL_Portfolio project root so the
--    relative CSV path below resolves correctly.
-- 4. Import into an empty table. Running this script again appends
--    another copy of the CSV rows; it does not clear the table.

\copy public.transactions(step, transaction_type, amount, sender_id, sender_old_balance, sender_new_balance, recipient_id, recipient_old_balance, recipient_new_balance, is_fraud, is_flagged_fraud) FROM 'data/original/PS_20174392719_1491204439457_log.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
