-- =====================================================
-- Insurance Claims Data Warehouse
-- 06 - Analytics and Reporting
-- =====================================================

USE WAREHOUSE INSURANCE_WH;
USE DATABASE INSURANCE1_DW;
USE SCHEMA ANALYTICS;


-- =====================================================
-- Reporting View
-- =====================================================

CREATE OR REPLACE VIEW VW_CLAIM_DETAILS AS
SELECT
    fc.claim_id,
    dc.customer_name,
    dc.city,
    dc.state,

    dp.policy_id,
    dp.policy_type,
    dp.policy_status,

    da.agent_name,
    da.region,

    dd.full_date AS claim_date,
    dd.year AS claim_year,
    dd.month AS claim_month,
    dd.month_name,

    fc.claim_amount,
    fc.claim_type,
    fc.claim_status,
    fc.settlement_date

FROM FACT_CLAIM fc

JOIN DIM_CUSTOMER dc
    ON fc.customer_key = dc.customer_key

JOIN DIM_POLICY dp
    ON fc.policy_key = dp.policy_key

JOIN DIM_AGENT da
    ON fc.agent_key = da.agent_key

JOIN DIM_DATE dd
    ON fc.date_key = dd.date_key;




-- =====================================================
-- Monthly Claims Analysis
-- =====================================================

SELECT
    dd.year,
    dd.month,
    dd.month_name,
    COUNT(*) AS total_claims,
    SUM(fc.claim_amount) AS total_claim_amount,
    AVG(fc.claim_amount) AS avg_claim_amount
FROM FACT_CLAIM fc

JOIN DIM_DATE dd
    ON fc.date_key = dd.date_key

GROUP BY
    dd.year,
    dd.month,
    dd.month_name

ORDER BY
    dd.year,
    dd.month;



-- =====================================================
-- Claims by Policy Type
-- =====================================================

SELECT
    dp.policy_type,
    COUNT(*) AS total_claims,
    SUM(fc.claim_amount) AS total_claim_amount,
    AVG(fc.claim_amount) AS avg_claim_amount
FROM FACT_CLAIM fc

JOIN DIM_POLICY dp
    ON fc.policy_key = dp.policy_key

GROUP BY dp.policy_type

ORDER BY total_claim_amount DESC;


-- =====================================================
-- Claims by Status
-- =====================================================

SELECT
    claim_status,
    COUNT(*) AS total_claims,
    SUM(claim_amount) AS total_claim_amount
FROM FACT_CLAIM

GROUP BY claim_status

ORDER BY total_claims DESC;


-- =====================================================
-- Claims by Agent
-- =====================================================

SELECT
    da.agent_name,
    COUNT(*) AS total_claims,
    SUM(fc.claim_amount) AS total_claim_amount
FROM FACT_CLAIM fc

JOIN DIM_AGENT da
    ON fc.agent_key = da.agent_key

GROUP BY da.agent_name

ORDER BY total_claims DESC;