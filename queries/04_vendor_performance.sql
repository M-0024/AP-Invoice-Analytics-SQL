-- ============================================================
-- QUERY 03: Duplicate Invoice Detection
-- Author: Masuma Khatun
-- Domain: Accounts Payable / P2P
-- Purpose: Identify potential duplicate invoices to prevent
--          double payments. A critical AP control used in
--          audits and Sarbanes-Oxley (SOX) compliance checks.
--
-- Logic: A duplicate is flagged when the SAME vendor sends
--        an invoice for the SAME amount on the SAME date.
-- ============================================================

-- STEP 1: Find all duplicate invoice groups
SELECT
    vendor_id,
    vendor_name,
    invoice_amount,
    currency,
    invoice_date,
    COUNT(invoice_id)                              AS duplicate_count,
    STRING_AGG(invoice_id, ', ')                   AS invoice_ids_flagged

FROM invoices

GROUP BY
    vendor_id,
    vendor_name,
    invoice_amount,
    currency,
    invoice_date

HAVING COUNT(invoice_id) > 1     -- only show groups with more than 1 match

ORDER BY duplicate_count DESC, invoice_amount DESC;


-- ============================================================
-- STEP 2: Show full details of the flagged duplicate invoices
-- ============================================================
SELECT
    i.*,
    'POTENTIAL DUPLICATE'                          AS flag

FROM invoices i
INNER JOIN (
    -- Find the business keys that appear more than once
    SELECT
        vendor_id,
        invoice_amount,
        invoice_date
    FROM invoices
    GROUP BY vendor_id, invoice_amount, invoice_date
    HAVING COUNT(invoice_id) > 1
) dupes
    ON  i.vendor_id       = dupes.vendor_id
    AND i.invoice_amount  = dupes.invoice_amount
    AND i.invoice_date    = dupes.invoice_date

ORDER BY i.vendor_name, i.invoice_date;


-- ============================================================
-- WHY THIS MATTERS:
-- Duplicate payments are the #1 AP audit finding.
-- This query is the SQL version of what SAP's duplicate
-- invoice check does — showing you understand BOTH the
-- business control AND how to build it in code.
-- ============================================================
