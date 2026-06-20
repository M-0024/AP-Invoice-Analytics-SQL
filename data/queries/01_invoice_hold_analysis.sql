-- ============================================================
-- QUERY 01: Invoice Hold Root Cause Analysis
-- Author: Masuma Khatun
-- Domain: Accounts Payable / P2P
-- Purpose: Break down invoice holds by hold code category
--          to identify the top reasons for processing delays.
--          This supports AP KPI reporting and process improvement.
-- ============================================================

-- STEP 1: Count of invoices on hold, grouped by hold reason
SELECT
    hold_code                                      AS hold_reason,
    COUNT(invoice_id)                              AS total_invoices_on_hold,
    SUM(invoice_amount)                            AS total_amount_blocked,
    currency,
    ROUND(
        COUNT(invoice_id) * 100.0 / 
        (SELECT COUNT(*) FROM invoices WHERE status = 'HOLD'), 
    2)                                             AS percentage_of_total_holds

FROM invoices
WHERE status = 'HOLD'
  AND hold_code IS NOT NULL

GROUP BY hold_code, currency
ORDER BY total_invoices_on_hold DESC;


-- ============================================================
-- WHAT THIS QUERY TELLS YOU:
-- ============================================================
-- PRICE_VARIANCE  → Invoice price doesn't match PO price
-- MISSING_GR      → Goods Receipt not yet posted in SAP
-- DUPLICATE       → Same vendor + amount + date already exists
-- PO_NOT_FOUND    → Invoice received but no Purchase Order exists
-- QTY_MISMATCH    → Invoice quantity doesn't match GR quantity
--
-- In Big Four / GCC interviews, this is called:
-- "Root Cause Analysis of AP Exception Backlog"
-- ============================================================


-- STEP 2: Trend — How many new holds appeared each month?
SELECT
    FORMAT(invoice_date, 'yyyy-MM')    AS invoice_month,
    hold_code                          AS hold_reason,
    COUNT(invoice_id)                  AS holds_raised

FROM invoices
WHERE status = 'HOLD'

GROUP BY FORMAT(invoice_date, 'yyyy-MM'), hold_code
ORDER BY invoice_month ASC, holds_raised DESC;
