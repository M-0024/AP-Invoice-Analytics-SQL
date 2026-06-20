# AP Invoice Analytics — SQL Portfolio

**Domain:** Accounts Payable | P2P (Procure-to-Pay) | Finance Operations  
**Author:** Masuma Khatun | AP & Finance Transformation Specialist  
**Tools:** SQL (T-SQL / SSMS), SAP HANA, SAP Concur

---

## About This Project

This repository contains SQL queries built from real-world AP operations experience.  
It covers the most critical analytics use cases in any P2P environment — from invoice hold root cause analysis to 3-way match validation.

---

## Queries Included

| File | Business Use Case |
|------|-------------------|
| `01_invoice_hold_analysis.sql` | Root cause breakdown of invoice holds by category |
| `02_aging_report.sql` | AP aging buckets — 0-30, 31-60, 61-90, 90+ days |
| `03_duplicate_detection.sql` | Flag duplicate invoices by vendor + amount + date |
| `04_vendor_performance.sql` | Vendor-level exception rate and on-time payment % |
| `05_three_way_match.sql` | GR/IR 3-way match: PO → Goods Receipt → Invoice |

---

## Key AP Concepts Demonstrated

- **GR/IR Reconciliation** — matching goods receipts to invoices in SAP
- **Invoice Hold Codes** — price variance, quantity mismatch, PO not found, missing GR
- **Aging Analysis** — identifying overdue liabilities by time bucket
- **Duplicate Controls** — preventing double payments using business key logic
- **Vendor Scorecarding** — exception rate, dispute %, on-time payment rate

---

## Connect With Me

[LinkedIn](https://www.linkedin.com/in/masuma-khatun) | [GitHub](https://github.com/M-0024)
