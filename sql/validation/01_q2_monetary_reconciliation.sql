SELECT
    SUM(category_total) AS grand_total
FROM (
    SELECT
        transaction_type,
        SUM(amount) AS category_total
    FROM public.transactions
    GROUP BY transaction_type
) AS category_summary;