-- ============================================================
-- PROJECT: OLIST E-COMMERCE DATA ANALYSIS
-- FILE: olist_database_setup.sql
-- DATABASE: olist
-- TOOL: MySQL Workbench
--
-- PURPOSE:
-- 1. Create the database if it does not exist.
-- 2. Create six tables if they do not exist.
-- 3. Import CSV data into the tables.
-- 4. Verify the imported data.
--
-- IMPORTANT:
-- Run this file for the initial setup.
-- Do not repeatedly execute the LOAD DATA statements.
-- This script does not drop the existing database.
-- ============================================================


-- ============================================================
-- SECTION 1: CREATE AND SELECT DATABASE
-- ============================================================

CREATE DATABASE IF NOT EXISTS olist;

USE olist;


-- ============================================================
-- SECTION 2: CREATE CUSTOMERS TABLE
-- ============================================================

CREATE TABLE IF NOT EXISTS customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state VARCHAR(5)
);


-- ============================================================
-- SECTION 3: CREATE SELLERS TABLE
-- ============================================================

CREATE TABLE IF NOT EXISTS sellers (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city VARCHAR(100),
    seller_state VARCHAR(5)
);


-- ============================================================
-- SECTION 4: CREATE PRODUCTS TABLE
-- ============================================================

CREATE TABLE IF NOT EXISTS products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_lenght DOUBLE,
    product_description_lenght DOUBLE,
    product_photos_qty DOUBLE,
    product_weight_g DOUBLE,
    product_length_cm DOUBLE,
    product_height_cm DOUBLE,
    product_width_cm DOUBLE
);


-- ============================================================
-- SECTION 5: CREATE ORDERS TABLE
-- ============================================================

CREATE TABLE IF NOT EXISTS orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(20),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME
);


-- ============================================================
-- SECTION 6: CREATE ORDER_ITEMS TABLE
-- ============================================================

CREATE TABLE IF NOT EXISTS order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date DATETIME,
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2),

    PRIMARY KEY (order_id, order_item_id)
);


-- ============================================================
-- SECTION 7: CREATE ORDER_PAYMENTS TABLE
-- ============================================================

CREATE TABLE IF NOT EXISTS order_payments (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(30),
    payment_installments INT,
    payment_value DECIMAL(10,2),

    PRIMARY KEY (order_id, payment_sequential)
);


-- ============================================================
-- SECTION 8: IMPORT CUSTOMERS DATA
-- ============================================================

-- Expected rows: approximately 99,441
-- Run this import only when customers is empty.

LOAD DATA LOCAL INFILE
'C:/path/to/olist_csvs/olist_customers_dataset.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- ============================================================
-- SECTION 9: IMPORT SELLERS DATA
-- ============================================================

-- Expected rows: approximately 3,095
-- Run this import only when sellers is empty.

LOAD DATA LOCAL INFILE
'C:/path/to/olist_csvs/olist_sellers_dataset.csv'
INTO TABLE sellers
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- ============================================================
-- SECTION 10: IMPORT PRODUCTS DATA
-- ============================================================

-- Expected rows: approximately 32,951
-- Empty fields are converted to NULL.

LOAD DATA LOCAL INFILE
'C:/path/to/olist_csvs/olist_products_dataset.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    product_id,
    @cat,
    @namelen,
    @desclen,
    @photos,
    @weight,
    @length,
    @height,
    @width
)
SET
    product_category_name = NULLIF(@cat, ''),
    product_name_lenght = NULLIF(@namelen, ''),
    product_description_lenght = NULLIF(@desclen, ''),
    product_photos_qty = NULLIF(@photos, ''),
    product_weight_g = NULLIF(@weight, ''),
    product_length_cm = NULLIF(@length, ''),
    product_height_cm = NULLIF(@height, ''),
    product_width_cm = NULLIF(@width, '');


-- ============================================================
-- SECTION 11: IMPORT ORDERS DATA
-- ============================================================

-- Expected rows: approximately 99,441
-- Empty optional timestamps are converted to NULL.

LOAD DATA LOCAL INFILE
'C:/path/to/olist_csvs/olist_orders_dataset.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    @approved,
    @carrier,
    @delivered,
    order_estimated_delivery_date
)
SET
    order_approved_at = NULLIF(@approved, ''),
    order_delivered_carrier_date = NULLIF(@carrier, ''),
    order_delivered_customer_date = NULLIF(@delivered, '');


-- ============================================================
-- SECTION 12: IMPORT ORDER_ITEMS DATA
-- ============================================================

-- Expected rows: approximately 112,650

LOAD DATA LOCAL INFILE
'C:/path/to/olist_csvs/olist_order_items_dataset.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- ============================================================
-- SECTION 13: IMPORT ORDER_PAYMENTS DATA
-- ============================================================

-- Expected rows: approximately 103,886

LOAD DATA LOCAL INFILE
'C:/path/to/olist_csvs/olist_order_payments_dataset.csv'
INTO TABLE order_payments
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- ============================================================
-- SECTION 14: VERIFY DATABASE AND TABLES
-- ============================================================

SELECT DATABASE();

SHOW TABLES;


-- ============================================================
-- SECTION 15: VERIFY ROW COUNTS
-- ============================================================

SELECT
    'customers' AS table_name,
    COUNT(*) AS total_rows
FROM customers

UNION ALL

SELECT
    'sellers',
    COUNT(*)
FROM sellers

UNION ALL

SELECT
    'products',
    COUNT(*)
FROM products

UNION ALL

SELECT
    'orders',
    COUNT(*)
FROM orders

UNION ALL

SELECT
    'order_items',
    COUNT(*)
FROM order_items

UNION ALL

SELECT
    'order_payments',
    COUNT(*)
FROM order_payments;


-- ============================================================
-- END OF DATABASE SETUP
-- ============================================================

