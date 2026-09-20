-- =====================================================
-- Insurance Claims Data Warehouse
-- 09 - Data Quality and Rejected Records
-- =====================================================

USE WAREHOUSE INSURANCE_WH;
USE DATABASE INSURANCE1_DW;


-- =====================================================
-- Rejected Claims Table
-- =====================================================

CREATE TABLE IF NOT EXISTS INSURANCE1_DW.STAGING.REJECTED_CLAIMS
(
    claim_id VARCHAR,
    policy_id VARCHAR,
    customer_id VARCHAR,
    claim_date DATE,
    claim_amount NUMBER(12,2),
    claim_type VARCHAR,
    claim_status VARCHAR,
    settlement_date DATE,
    rejection_reason VARCHAR,
    rejected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- =====================================================
-- Duplicate Customer Check
-- =====================================================

SELECT
    customer_id,
    COUNT(*) AS duplicate_count
FROM INSURANCE1_DW.RAW.CUSTOMERS
GROUP BY customer_id
HAVING COUNT(*) > 1;


-- =====================================================
-- Duplicate Claim Check
-- =====================================================

SELECT
    claim_id,
    COUNT(*) AS duplicate_count
FROM INSURANCE1_DW.RAW.CLAIMS
GROUP BY claim_id
HAVING COUNT(*) > 1;


-- =====================================================
-- Invalid Claim Amount Check
-- =====================================================

SELECT *
FROM INSURANCE1_DW.RAW.CLAIMS
WHERE claim_amount IS NULL
   OR claim_amount <= 0;


-- =====================================================
-- Missing Customer Information
-- =====================================================

SELECT *
FROM INSURANCE1_DW.RAW.CUSTOMERS
WHERE customer_id IS NULL
   OR customer_name IS NULL
   OR city IS NULL;


-- =====================================================
-- Review Rejected Claims
-- =====================================================

SELECT
    claim_id,
    customer_id,
    policy_id,
    claim_amount,
    rejection_reason,
    rejected_at
FROM INSURANCE1_DW.STAGING.REJECTED_CLAIMS
ORDER BY rejected_at DESC;