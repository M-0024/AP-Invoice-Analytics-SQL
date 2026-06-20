-- ============================================================
-- QUERY 04: Vendor Performance Scorecard
-- Author: Masuma Khatun
-- Domain: Accounts Payable / P2P
-- Purpose: Score each vendor on invoice quality metrics.
--          Used in vendor reviews, procurement decisions,
--          and AP process improvement initiatives.
-- ============================================================

SELECT
    vendor_id,
    vendor_name,

    -- Volume metrics
    COUNT(invoice_id)                                      AS total_invoices,
    SUM(invoice_amount)                                    AS total_invoice_value,
    currency,

    -- Exception rate (how often does this vendor cause holds?)
    SUM(CASE WHEN status = 'HOLD' THEN 1 ELSE 0 END)      AS invoices_on_hold,
    ROUND(
        SUM(CASE WHEN status = 'HOLD' THEN 1 ELSE 0 END) * 100.0
        / COUNT(invoice_id),
    2)                                                     AS exception_rate_pct,

    -- On-time payment rate (for paid invoices, were they paid before due date?)
    SUM(CASE 
            WHEN status = 'PAID' 
             AND payment_date <= due_date 
            THEN 1 ELSE 0 
        END)                                               AS paid_on_time,
    ROUND(
        SUM(CASE 
                WHEN status = 'PAID' 
                 AND payment_date <= due_date 
                THEN 1 ELSE 0 
            END) * 100.0
        / NULLIF(SUM(CASE WHEN status = 'PAID' THEN 1 ELSE 0 END), 0),
    2)                                                     AS on_time_payment_pct,

    -- Overdue invoices
    SUM(CASE WHEN status = 'OVERDUE' THEN 1 ELSE 0 END)   AS invoices_overdue,

    -- Vendor risk rating (derived from exception rate)
    CASE
        WHEN ROUND(
            SUM(CASE WHEN status = 'HOLD' THEN 1 ELSE 0 END) * 100.0
            / COUNT(invoice_id), 2) >= 30  THEN 'HIGH RISK'
        WHEN ROUND(
            SUM(CASE WHEN status = 'HOLD' THEN 1 ELSE 0 END) * 100.0
            / COUNT(invoice_id), 2) >= 15  THEN 'MEDIUM RISK'
        ELSE 'LOW RISK'
    END                                                    AS vendor_risk_rating

FROM invoices

GROUP BY vendor_id, vendor_name, currency
ORDER BY exception_rate_pct DESC;

-- ============================================================
-- HOW TO USE THIS IN AN INTERVIEW:
-- "I built vendor scorecards that identified high-exception
--  vendors, enabling our team to engage procurement for
--  root cause resolution — reducing overall hold rate by X%."
-- ============================================================
