-- ============================================================
-- QUERY 02: AP Aging Report
-- Author: Masuma Khatun
-- Domain: Accounts Payable / P2P
-- Purpose: Classify unpaid invoices into aging buckets.
--          This is one of the most important reports in AP —
--          used by Finance Controllers and Audit teams to
--          track overdue liabilities and cash flow risk.
-- ============================================================

-- STEP 1: Calculate days overdue for each unpaid invoice
SELECT
    invoice_id,
    vendor_name,
    po_number,
    invoice_date,
    due_date,
    invoice_amount,
    currency,
    status,
    DATEDIFF(DAY, due_date, GETDATE())             AS days_overdue,

    -- Aging bucket classification
    CASE
        WHEN DATEDIFF(DAY, due_date, GETDATE()) <= 0  THEN 'Not Yet Due'
        WHEN DATEDIFF(DAY, due_date, GETDATE()) <= 30 THEN '1-30 Days'
        WHEN DATEDIFF(DAY, due_date, GETDATE()) <= 60 THEN '31-60 Days'
        WHEN DATEDIFF(DAY, due_date, GETDATE()) <= 90 THEN '61-90 Days'
        ELSE '90+ Days (Critical)'
    END                                            AS aging_bucket

FROM invoices
WHERE status IN ('OVERDUE', 'HOLD')   -- unpaid invoices only
  AND payment_date IS NULL

ORDER BY days_overdue DESC;


-- ============================================================
-- STEP 2: Summary — Total amount blocked in each aging bucket
-- This is what Finance Controllers look at every month-end
-- ============================================================
SELECT
    CASE
        WHEN DATEDIFF(DAY, due_date, GETDATE()) <= 0  THEN 'Not Yet Due'
        WHEN DATEDIFF(DAY, due_date, GETDATE()) <= 30 THEN '1-30 Days'
        WHEN DATEDIFF(DAY, due_date, GETDATE()) <= 60 THEN '31-60 Days'
        WHEN DATEDIFF(DAY, due_date, GETDATE()) <= 90 THEN '61-90 Days'
        ELSE '90+ Days (Critical)'
    END                                            AS aging_bucket,

    COUNT(invoice_id)                              AS invoice_count,
    SUM(invoice_amount)                            AS total_amount_blocked,
    currency

FROM invoices
WHERE status IN ('OVERDUE', 'HOLD')
  AND payment_date IS NULL

GROUP BY
    CASE
        WHEN DATEDIFF(DAY, due_date, GETDATE()) <= 0  THEN 'Not Yet Due'
        WHEN DATEDIFF(DAY, due_date, GETDATE()) <= 30 THEN '1-30 Days'
        WHEN DATEDIFF(DAY, due_date, GETDATE()) <= 60 THEN '31-60 Days'
        WHEN DATEDIFF(DAY, due_date, GETDATE()) <= 90 THEN '61-90 Days'
        ELSE '90+ Days (Critical)'
    END,
    currency

ORDER BY total_amount_blocked DESC;

-- ============================================================
-- WHY THIS MATTERS IN INTERVIEWS:
-- "I built aging reports that helped the team prioritise
--  which invoices to clear before month-end close,
--  reducing our 90+ day overdue balance by X%."
-- ============================================================
