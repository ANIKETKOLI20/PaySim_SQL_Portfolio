
-- PaySim SQL Portfolio
-- Task 4D: Import original CSV into PostgreSQL
-- Target: public.transactions

\copy public.transactions(step, transaction_type, amount, sender_id, sender_old_balance, sender_new_balance, recipient_id, recipient_old_balance, recipient_new_balance, is_fraud, is_flagged_fraud) FROM 'D:/Data Analyst/Projects/PaySim_SQL_Portfolio/data/original/PS_20174392719_1491204439457_log.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
