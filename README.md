-- ============================================================
-- QUERY 05: 3-Way Match Validation (PO → GR → Invoice)
-- Author: Masuma Khatun
-- Domain: Accounts Payable / P2P / SAP
-- Purpose: Validate that every invoice has a matching
--          Purchase Order AND a Goods Receipt posted in SAP.
--          This is the core control in any P2P process.
--
-- 3-Way Match means:
--   ✅ Purchase Order (PO) exists
--   ✅ Goods Receipt (GR) is posted in SAP
--   ✅ Invoice amount matches PO amount (within tolerance)
-- ============================================================
 
-- STEP 1: Check match status for every invoice
SELECT
    i.invoice_id,
    i.vendor_name,
    i.po_number,
    i.invoice_amount,
    i.currency,
    i.gr_posted,
    i.status,
 
    -- 3-Way Match Result
    CASE
        WHEN i.po_number IS NULL OR i.po_number = ''
            THEN '❌ FAIL — No PO Found'
        WHEN i.gr_posted = 'NO' OR i.gr_posted IS NULL
            THEN '⚠️ FAIL — GR Not Posted'
        WHEN i.status = 'HOLD' AND i.hold_code = 'PRICE_VARIANCE'
            THEN '⚠️ FAIL — Price Variance vs PO'
        WHEN i.status = 'HOLD' AND i.hold_code = 'QTY_MISMATCH'
            THEN '⚠️ FAIL — Quantity Mismatch vs GR'
        ELSE '✅ PASS — 3-Way Match Successful'
    END                                    AS three_way_match_result,
 
    i.hold_code
 
FROM invoices i
ORDER BY
    CASE
        WHEN i.po_number IS NULL OR i.po_number = '' THEN 1
        WHEN i.gr_posted = 'NO' OR i.gr_posted IS NULL THEN 2
        WHEN i.hold_code IN ('PRICE_VARIANCE','QTY_MISMATCH') THEN 3
        ELSE 4
    END;
 
 
-- ============================================================
-- STEP 2: Summary — How many invoices pass vs fail match?
-- ============================================================
SELECT
    CASE
        WHEN po_number IS NULL OR po_number = ''          THEN 'No PO Found'
        WHEN gr_posted = 'NO' OR gr_posted IS NULL        THEN 'GR Not Posted'
        WHEN hold_code IN ('PRICE_VARIANCE','QTY_MISMATCH') THEN 'Amount/Qty Mismatch'
        ELSE '3-Way Match Passed'
    END                                    AS match_category,
 
    COUNT(invoice_id)                      AS invoice_count,
    SUM(invoice_amount)                    AS total_amount,
    currency
 
FROM invoices
 
GROUP BY
    CASE
        WHEN po_number IS NULL OR po_number = ''          THEN 'No PO Found'
        WHEN gr_posted = 'NO' OR gr_posted IS NULL        THEN 'GR Not Posted'
        WHEN hold_code IN ('PRICE_VARIANCE','QTY_MISMATCH') THEN 'Amount/Qty Mismatch'
        ELSE '3-Way Match Passed'
    END,
    currency
 
ORDER BY invoice_count DESC;
 
-- ============================================================
-- WHY THIS IS POWERFUL IN INTERVIEWS:
-- This shows you understand the ENTIRE P2P cycle end-to-end —
-- from Purchase Order creation to payment — and can translate
-- that business process knowledge into SQL audit logic.
-- Big Four firms LOVE this combination.
-- ============================================================
 
