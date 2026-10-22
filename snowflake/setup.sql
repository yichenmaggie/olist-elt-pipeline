-- One-time setup for the Olist ELT pipeline.
-- Run as a role that can create warehouses and databases (e.g. ACCOUNTADMIN on a fresh trial).

-- Smallest warehouse; suspends after 60 seconds idle to save credits.
CREATE WAREHOUSE IF NOT EXISTS OLIST_WH
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE;

CREATE DATABASE IF NOT EXISTS OLIST;

-- RAW: files loaded as-is. STAGING: cleaned 1:1 models. MARTS: fact and dimension tables.
CREATE SCHEMA IF NOT EXISTS OLIST.RAW;
CREATE SCHEMA IF NOT EXISTS OLIST.STAGING;
CREATE SCHEMA IF NOT EXISTS OLIST.MARTS;
