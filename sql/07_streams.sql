-- =====================================================
-- Insurance Claims Data Warehouse
-- 07 - Change Data Capture using Snowflake Streams
-- =====================================================

USE WAREHOUSE INSURANCE_WH;
USE DATABASE INSURANCE1_DW;


-- =====================================================
-- Stream on RAW.CLAIMS
-- Tracks INSERT / UPDATE / DELETE changes
-- =====================================================

CREATE OR REPLACE STREAM INSURANCE1_DW.RAW.CLAIMS_STREAM
ON TABLE INSURANCE1_DW.RAW.CLAIMS;


-- =====================================================
-- Incremental Processing Table
-- Stores newly captured claim records before validation
-- =====================================================

CREATE TABLE IF NOT EXISTS INSURANCE1_DW.STAGING.CLAIMS_INCREMENTAL
(
    claim_id VARCHAR,
    policy_id VARCHAR,
    customer_id VARCHAR,
    claim_date DATE,
    claim_amount NUMBER(12,2),
    claim_type VARCHAR,
    claim_status VARCHAR,
    settlement_date DATE,
    processed BOOLEAN DEFAULT FALSE
);


-- =====================================================
-- Inspect pending CDC records
-- =====================================================

SELECT
    claim_id,
    policy_id,
    customer_id,
    claim_date,
    claim_amount,
    METADATA$ACTION AS change_type,
    METADATA$ISUPDATE AS is_update
FROM INSURANCE1_DW.RAW.CLAIMS_STREAM;