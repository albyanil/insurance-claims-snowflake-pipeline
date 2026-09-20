-- =====================================================
-- Insurance Claims Data Warehouse
-- 02A - Load CSV Files into RAW Layer
-- =====================================================

USE WAREHOUSE INSURANCE_WH;
USE DATABASE INSURANCE1_DW;
USE SCHEMA RAW;


-- =====================================================
-- Load Customers
-- =====================================================

COPY INTO INSURANCE1_DW.RAW.CUSTOMERS
FROM @INSURANCE1_DW.RAW.INSURANCE_STAGE
FILE_FORMAT = (
    FORMAT_NAME = 'INSURANCE1_DW.RAW.CSV_FORMAT'
)
PATTERN = '.*customers.*[.]csv';


-- =====================================================
-- Load Policies
-- =====================================================

COPY INTO INSURANCE1_DW.RAW.POLICIES
FROM @INSURANCE1_DW.RAW.INSURANCE_STAGE
FILE_FORMAT = (
    FORMAT_NAME = 'INSURANCE1_DW.RAW.CSV_FORMAT'
)
PATTERN = '.*policies.*[.]csv';


-- =====================================================
-- Load Claims
-- =====================================================

COPY INTO INSURANCE1_DW.RAW.CLAIMS
FROM @INSURANCE1_DW.RAW.INSURANCE_STAGE
FILE_FORMAT = (
    FORMAT_NAME = 'INSURANCE1_DW.RAW.CSV_FORMAT'
)
PATTERN = '.*claims.*[.]csv';


-- =====================================================
-- Load Agents
-- =====================================================

COPY INTO INSURANCE1_DW.RAW.AGENTS
FROM @INSURANCE1_DW.RAW.INSURANCE_STAGE
FILE_FORMAT = (
    FORMAT_NAME = 'INSURANCE1_DW.RAW.CSV_FORMAT'
)
PATTERN = '.*agents.*[.]csv';


-- =====================================================
-- Verify Loaded Data
-- =====================================================

SELECT 'CUSTOMERS' AS table_name, COUNT(*) AS row_count
FROM INSURANCE1_DW.RAW.CUSTOMERS

UNION ALL

SELECT 'POLICIES', COUNT(*)
FROM INSURANCE1_DW.RAW.POLICIES

UNION ALL

SELECT 'CLAIMS', COUNT(*)
FROM INSURANCE1_DW.RAW.CLAIMS

UNION ALL

SELECT 'AGENTS', COUNT(*)
FROM INSURANCE1_DW.RAW.AGENTS;