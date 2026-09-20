-- =====================================================
-- 02 - RAW Layer
-- =====================================================

USE DATABASE INSURANCE1_DW;
USE SCHEMA RAW;

-- Customer source data
CREATE TABLE IF NOT EXISTS CUSTOMERS
(
    customer_id VARCHAR,
    customer_name VARCHAR,
    date_of_birth DATE,
    gender VARCHAR,
    city VARCHAR,
    state VARCHAR,
    registration_date DATE
);

-- Policy source data
CREATE TABLE IF NOT EXISTS POLICIES
(
    policy_id VARCHAR,
    customer_id VARCHAR,
    agent_id VARCHAR,
    policy_type VARCHAR,
    policy_start_date DATE,
    policy_end_date DATE,
    premium_amount NUMBER(12,2),
    sum_insured NUMBER(15,2),
    policy_status VARCHAR
);

-- Claims source data
CREATE TABLE IF NOT EXISTS CLAIMS
(
    claim_id VARCHAR,
    policy_id VARCHAR,
    customer_id VARCHAR,
    claim_date DATE,
    claim_amount NUMBER(12,2),
    claim_type VARCHAR,
    claim_status VARCHAR,
    settlement_date DATE
);

-- Agent source data
CREATE TABLE IF NOT EXISTS AGENTS
(
    agent_id VARCHAR,
    agent_name VARCHAR,
    region VARCHAR,
    joining_date DATE
);



-- Internal stage used for CSV ingestion
CREATE STAGE IF NOT EXISTS INSURANCE_STAGE;

-- CSV file format
CREATE FILE FORMAT IF NOT EXISTS CSV_FORMAT
TYPE = 'CSV'
FIELD_DELIMITER = ','
SKIP_HEADER = 1;