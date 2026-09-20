-- =====================================================
-- Insurance Claims Data Warehouse
-- 04 - Dimension Tables
-- =====================================================

USE WAREHOUSE INSURANCE_WH;
USE DATABASE INSURANCE1_DW;
USE SCHEMA ANALYTICS;


-- =====================================================
-- CUSTOMER DIMENSION
-- =====================================================

CREATE OR REPLACE TABLE DIM_CUSTOMER
(
    customer_key INTEGER AUTOINCREMENT,
    customer_id VARCHAR,
    customer_name VARCHAR,
    date_of_birth DATE,
    gender VARCHAR,
    city VARCHAR,
    state VARCHAR,
    registration_date DATE
);

INSERT INTO DIM_CUSTOMER
(
    customer_id,
    customer_name,
    date_of_birth,
    gender,
    city,
    state,
    registration_date
)
SELECT
    customer_id,
    customer_name,
    date_of_birth,
    gender,
    city,
    state,
    registration_date
FROM INSURANCE1_DW.STAGING.CUSTOMERS;


-- =====================================================
-- AGENT DIMENSION
-- =====================================================

CREATE OR REPLACE TABLE DIM_AGENT
(
    agent_key INTEGER AUTOINCREMENT,
    agent_id VARCHAR,
    agent_name VARCHAR,
    region VARCHAR,
    joining_date DATE
);

INSERT INTO DIM_AGENT
(
    agent_id,
    agent_name,
    region,
    joining_date
)
SELECT
    agent_id,
    agent_name,
    region,
    joining_date
FROM INSURANCE1_DW.STAGING.AGENTS;


-- =====================================================
-- POLICY DIMENSION
-- =====================================================

CREATE OR REPLACE TABLE DIM_POLICY
(
    policy_key INTEGER AUTOINCREMENT,
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

INSERT INTO DIM_POLICY
(
    policy_id,
    customer_id,
    agent_id,
    policy_type,
    policy_start_date,
    policy_end_date,
    premium_amount,
    sum_insured,
    policy_status
)
SELECT
    policy_id,
    customer_id,
    agent_id,
    policy_type,
    policy_start_date,
    policy_end_date,
    premium_amount,
    sum_insured,
    policy_status
FROM INSURANCE1_DW.STAGING.POLICIES;


-- =====================================================
-- DATE DIMENSION
-- =====================================================

CREATE OR REPLACE TABLE DIM_DATE
(
    date_key INTEGER,
    full_date DATE,
    year INTEGER,
    quarter INTEGER,
    month INTEGER,
    month_name VARCHAR,
    day INTEGER,
    day_of_week VARCHAR
);

INSERT INTO DIM_DATE
SELECT
    TO_NUMBER(TO_CHAR(date_value, 'YYYYMMDD')) AS date_key,
    date_value AS full_date,
    YEAR(date_value) AS year,
    QUARTER(date_value) AS quarter,
    MONTH(date_value) AS month,
    MONTHNAME(date_value) AS month_name,
    DAY(date_value) AS day,
    DAYNAME(date_value) AS day_of_week
FROM
(
    SELECT
        DATEADD(day, SEQ4(), '2023-01-01'::DATE) AS date_value
    FROM TABLE(GENERATOR(ROWCOUNT => 1500))
);