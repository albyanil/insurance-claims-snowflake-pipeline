-- =====================================================
-- Insurance Claims Data Warehouse
-- 05 - Claims Fact Table
-- =====================================================

USE WAREHOUSE INSURANCE_WH;
USE DATABASE INSURANCE1_DW;
USE SCHEMA ANALYTICS;


-- =====================================================
-- FACT_CLAIM
-- Grain: One row per insurance claim
-- =====================================================

CREATE OR REPLACE TABLE FACT_CLAIM
(
    claim_key INTEGER AUTOINCREMENT,
    claim_id VARCHAR,
    customer_key INTEGER,
    policy_key INTEGER,
    agent_key INTEGER,
    date_key INTEGER,
    claim_amount NUMBER(12,2),
    claim_type VARCHAR,
    claim_status VARCHAR,
    settlement_date DATE
);


-- =====================================================
-- Load FACT_CLAIM
-- Convert business keys into warehouse surrogate keys
-- =====================================================

INSERT INTO FACT_CLAIM
(
    claim_id,
    customer_key,
    policy_key,
    agent_key,
    date_key,
    claim_amount,
    claim_type,
    claim_status,
    settlement_date
)
SELECT
    c.claim_id,
    dc.customer_key,
    dp.policy_key,
    da.agent_key,
    dd.date_key,
    c.claim_amount,
    c.claim_type,
    c.claim_status,
    c.settlement_date
FROM INSURANCE1_DW.STAGING.CLAIMS c

JOIN DIM_CUSTOMER dc
    ON c.customer_id = dc.customer_id

JOIN DIM_POLICY dp
    ON c.policy_id = dp.policy_id

JOIN DIM_AGENT da
    ON dp.agent_id = da.agent_id

JOIN DIM_DATE dd
    ON c.claim_date = dd.full_date;