-- =====================================================
-- Insurance Claims Data Warehouse
-- 08 - Automated Incremental Processing
-- =====================================================

USE WAREHOUSE INSURANCE_WH;
USE DATABASE INSURANCE1_DW;


-- =====================================================
-- ROOT TASK
-- Triggered when CLAIMS_STREAM contains new changes
-- =====================================================

CREATE OR REPLACE TASK INSURANCE1_DW.ANALYTICS.LOAD_CLAIMS_TASK
    WAREHOUSE = INSURANCE_WH
    WHEN SYSTEM$STREAM_HAS_DATA(
        'INSURANCE1_DW.RAW.CLAIMS_STREAM'
    )
AS
INSERT INTO INSURANCE1_DW.STAGING.CLAIMS_INCREMENTAL
(
    claim_id,
    policy_id,
    customer_id,
    claim_date,
    claim_amount,
    claim_type,
    claim_status,
    settlement_date
)
SELECT
    claim_id,
    policy_id,
    customer_id,
    claim_date,
    claim_amount,
    claim_type,
    claim_status,
    settlement_date
FROM INSURANCE1_DW.RAW.CLAIMS_STREAM
WHERE METADATA$ACTION = 'INSERT';



-- =====================================================
-- Reject Invalid Claims
-- =====================================================

CREATE OR REPLACE TASK INSURANCE1_DW.ANALYTICS.REJECT_INVALID_CLAIMS_TASK
    WAREHOUSE = INSURANCE_WH
    AFTER INSURANCE1_DW.ANALYTICS.LOAD_CLAIMS_TASK
AS
INSERT INTO INSURANCE1_DW.STAGING.REJECTED_CLAIMS
(
    claim_id,
    policy_id,
    customer_id,
    claim_date,
    claim_amount,
    claim_type,
    claim_status,
    settlement_date,
    rejection_reason
)
SELECT
    c.claim_id,
    c.policy_id,
    c.customer_id,
    c.claim_date,
    c.claim_amount,
    c.claim_type,
    c.claim_status,
    c.settlement_date,

    CASE
        WHEN c.claim_id IS NULL
            THEN 'Missing claim_id'

        WHEN c.claim_amount IS NULL
            THEN 'Missing claim amount'

        WHEN c.claim_amount <= 0
            THEN 'Invalid claim amount'

        WHEN dc.customer_key IS NULL
            THEN 'Unknown customer'

        WHEN dp.policy_key IS NULL
            THEN 'Unknown policy'

        ELSE 'Unknown validation error'
    END AS rejection_reason

FROM INSURANCE1_DW.STAGING.CLAIMS_INCREMENTAL c

LEFT JOIN INSURANCE1_DW.ANALYTICS.DIM_CUSTOMER dc
    ON c.customer_id = dc.customer_id

LEFT JOIN INSURANCE1_DW.ANALYTICS.DIM_POLICY dp
    ON c.policy_id = dp.policy_id

WHERE c.processed = FALSE

AND
(
    c.claim_id IS NULL
    OR c.claim_amount IS NULL
    OR c.claim_amount <= 0
    OR dc.customer_key IS NULL
    OR dp.policy_key IS NULL
);


-- =====================================================
-- Load Valid Claims into FACT_CLAIM
-- =====================================================

CREATE OR REPLACE TASK INSURANCE1_DW.ANALYTICS.LOAD_VALID_CLAIMS_TASK
    WAREHOUSE = INSURANCE_WH
    AFTER INSURANCE1_DW.ANALYTICS.REJECT_INVALID_CLAIMS_TASK
AS
INSERT INTO INSURANCE1_DW.ANALYTICS.FACT_CLAIM
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

FROM INSURANCE1_DW.STAGING.CLAIMS_INCREMENTAL c

JOIN INSURANCE1_DW.ANALYTICS.DIM_CUSTOMER dc
    ON c.customer_id = dc.customer_id

JOIN INSURANCE1_DW.ANALYTICS.DIM_POLICY dp
    ON c.policy_id = dp.policy_id

JOIN INSURANCE1_DW.ANALYTICS.DIM_AGENT da
    ON dp.agent_id = da.agent_id

JOIN INSURANCE1_DW.ANALYTICS.DIM_DATE dd
    ON c.claim_date = dd.full_date

WHERE c.processed = FALSE
  AND c.claim_id IS NOT NULL
  AND c.claim_amount IS NOT NULL
  AND c.claim_amount > 0;



-- =====================================================
-- Mark Incremental Records as Processed
-- =====================================================

CREATE OR REPLACE TASK INSURANCE1_DW.ANALYTICS.MARK_PROCESSED_TASK
    WAREHOUSE = INSURANCE_WH
    AFTER INSURANCE1_DW.ANALYTICS.LOAD_VALID_CLAIMS_TASK
AS
UPDATE INSURANCE1_DW.STAGING.CLAIMS_INCREMENTAL
SET processed = TRUE
WHERE processed = FALSE;



-- =====================================================
-- Enable Task Graph
-- Child tasks first, root task last
-- =====================================================

ALTER TASK INSURANCE1_DW.ANALYTICS.MARK_PROCESSED_TASK RESUME;

ALTER TASK INSURANCE1_DW.ANALYTICS.LOAD_VALID_CLAIMS_TASK RESUME;

ALTER TASK INSURANCE1_DW.ANALYTICS.REJECT_INVALID_CLAIMS_TASK RESUME;

ALTER TASK INSURANCE1_DW.ANALYTICS.LOAD_CLAIMS_TASK RESUME;*