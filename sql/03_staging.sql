-- =====================================================
-- Insurance Claims Data Warehouse
-- 03 - STAGING Layer
-- =====================================================

USE WAREHOUSE INSURANCE_WH;
USE DATABASE INSURANCE1_DW;
USE SCHEMA STAGING;


-- =====================================================
-- CUSTOMERS
-- Deduplicate customers and handle missing city values
-- =====================================================

CREATE OR REPLACE TABLE CUSTOMERS AS
SELECT
    customer_id,
    customer_name,
    date_of_birth,
    gender,
    COALESCE(city, 'UNKNOWN') AS city,
    state,
    registration_date
FROM
(
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY registration_date
        ) AS rn
    FROM INSURANCE1_DW.RAW.CUSTOMERS
)
WHERE rn = 1;


-- =====================================================
-- POLICIES
-- Standardize categorical values
-- =====================================================

CREATE OR REPLACE TABLE POLICIES AS
SELECT
    policy_id,
    customer_id,
    agent_id,
    UPPER(TRIM(policy_type)) AS policy_type,
    policy_start_date,
    policy_end_date,
    premium_amount,
    sum_insured,
    UPPER(TRIM(policy_status)) AS policy_status
FROM INSURANCE1_DW.RAW.POLICIES;


-- =====================================================
-- CLAIMS
-- Remove duplicates and invalid claim amounts
-- =====================================================

CREATE OR REPLACE TABLE CLAIMS AS
SELECT
    claim_id,
    policy_id,
    customer_id,
    claim_date,
    claim_amount,
    claim_type,
    claim_status,
    settlement_date
FROM
(
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY claim_id
            ORDER BY claim_date
        ) AS rn
    FROM INSURANCE1_DW.RAW.CLAIMS
    WHERE claim_amount > 0
)
WHERE rn = 1;


-- =====================================================
-- AGENTS
-- Standardize agent data
-- =====================================================

CREATE OR REPLACE TABLE AGENTS AS
SELECT
    agent_id,
    TRIM(agent_name) AS agent_name,
    UPPER(TRIM(region)) AS region,
    joining_date
FROM INSURANCE1_DW.RAW.AGENTS;