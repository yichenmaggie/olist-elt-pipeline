-- Load the four Olist CSVs into OLIST.RAW.
-- Workflow: run Section 1, upload the CSVs to the stage, then run Section 2.

USE WAREHOUSE OLIST_WH;
USE DATABASE OLIST;
USE SCHEMA RAW;

-- ===== Section 1: file format, stage, tables =====

CREATE FILE FORMAT IF NOT EXISTS olist_csv_format
  TYPE = 'CSV'
  SKIP_HEADER = 1
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  EMPTY_FIELD_AS_NULL = TRUE;

CREATE STAGE IF NOT EXISTS olist_stage
  FILE_FORMAT = olist_csv_format;

-- RAW keeps source values as-is: timestamps stay STRING and are cast in dbt staging.
CREATE TABLE IF NOT EXISTS raw_customers (
  customer_id STRING,
  customer_unique_id STRING,
  customer_zip_code_prefix STRING,  -- STRING to keep leading zeros
  customer_city STRING,
  customer_state STRING
);

CREATE TABLE IF NOT EXISTS raw_orders (
  order_id STRING,
  customer_id STRING,
  order_status STRING,
  order_purchase_timestamp STRING,
  order_approved_at STRING,
  order_delivered_carrier_date STRING,
  order_delivered_customer_date STRING,
  order_estimated_delivery_date STRING
);

CREATE TABLE IF NOT EXISTS raw_order_items (
  order_id STRING,
  order_item_id NUMBER,
  product_id STRING,
  seller_id STRING,
  shipping_limit_date STRING,
  price NUMBER(12, 2),
  freight_value NUMBER(12, 2)
);

CREATE TABLE IF NOT EXISTS raw_order_payments (
  order_id STRING,
  payment_sequential NUMBER,
  payment_type STRING,
  payment_installments NUMBER,
  payment_value NUMBER(12, 2)
);

-- ===== Section 2: load (run after the files are uploaded) =====

-- Confirm the four files are in the stage.
LIST @olist_stage;

-- PATTERN matches the file name whether or not Snowflake compressed it to .gz on upload.
-- Already-loaded files are skipped on re-run. To reload, TRUNCATE the table
-- and add FORCE = TRUE to the COPY statement.
COPY INTO raw_customers
  FROM @olist_stage
  PATTERN = '.*olist_customers_dataset[.]csv.*'
  ON_ERROR = ABORT_STATEMENT;

COPY INTO raw_orders
  FROM @olist_stage
  PATTERN = '.*olist_orders_dataset[.]csv.*'
  ON_ERROR = ABORT_STATEMENT;

COPY INTO raw_order_items
  FROM @olist_stage
  PATTERN = '.*olist_order_items_dataset[.]csv.*'
  ON_ERROR = ABORT_STATEMENT;

COPY INTO raw_order_payments
  FROM @olist_stage
  PATTERN = '.*olist_order_payments_dataset[.]csv.*'
  ON_ERROR = ABORT_STATEMENT;

-- ===== Section 3: sanity checks =====

SELECT 'raw_customers' AS table_name, COUNT(*) AS row_count FROM raw_customers
UNION ALL SELECT 'raw_orders', COUNT(*) FROM raw_orders
UNION ALL SELECT 'raw_order_items', COUNT(*) FROM raw_order_items
UNION ALL SELECT 'raw_order_payments', COUNT(*) FROM raw_order_payments;

-- Undelivered orders should have NULL delivery dates, not empty strings.
SELECT COUNT(*) AS null_delivery_dates
FROM raw_orders
WHERE order_delivered_customer_date IS NULL;
