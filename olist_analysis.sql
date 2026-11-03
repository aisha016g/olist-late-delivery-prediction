-- ============================================================
-- PROJECT: OLIST E-COMMERCE DATA ANALYSIS
-- FILE: olist_analysis.sql
-- PURPOSE: Explore data and perform SQL analysis
-- ============================================================

USE olist;


-- ============================================================
-- SECTION 1: VERIFY DATABASE
-- ============================================================

SELECT DATABASE();


-- ============================================================
-- SECTION 2: CHECK TABLE COUNTS
-- ============================================================

SELECT 'customers' AS table_name, COUNT(*) AS total_rows
FROM customers

UNION ALL

SELECT 'sellers', COUNT(*) FROM sellers

UNION ALL

SELECT 'products', COUNT(*) FROM products

UNION ALL

SELECT 'orders', COUNT(*) FROM orders

UNION ALL

SELECT 'order_items', COUNT(*) FROM order_items

UNION ALL

SELECT 'order_payments', COUNT(*) FROM order_payments;


-- ============================================================
-- SECTION 3: CHECK ORDER STATUS
-- ============================================================

SELECT
    order_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_status;


-- ADD YOUR ANALYSIS QUERIES BELOW

USE olist;

DROP TABLE IF EXISTS order_base;


-- SECTION 4: TARGET TABLE (is_late = 1 if delivered after the estimated date)


CREATE TABLE order_base AS
SELECT
    order_id,
    customer_id,
    order_purchase_timestamp,
    order_estimated_delivery_date,
    CASE
        WHEN order_delivered_customer_date >
             order_estimated_delivery_date THEN 1
        ELSE 0
    END AS is_late
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;
  
  -- SECTION 5: CHECK TARGET (expect 96,470 orders, 7,826 late, 8.1%)
  
SELECT
    COUNT(*) AS total_delivered_orders,
    SUM(is_late) AS late_orders,
    ROUND(100 * AVG(is_late), 1) AS late_delivery_percentage
FROM order_base;


-- SECTION 6: CHECK ONE ROW PER ORDER (both counts must match)


SELECT
    COUNT(*) AS agg_orders
FROM (
    SELECT order_id
    FROM order_items
    GROUP BY order_id
) AS order_agg;

SELECT
    COUNT(DISTINCT order_id) AS distinct_orders
FROM order_items;

-- SECTION 7: CHECK JOIN (expect 96,470 rows, none lost or duplicated)


SELECT COUNT(*) AS final_joined_rows
FROM order_base AS ob
INNER JOIN (
    SELECT
        order_id,
        COUNT(*) AS n_items,
        SUM(price) AS total_price,
        SUM(freight_value) AS total_freight,
        COUNT(DISTINCT seller_id) AS n_sellers
    FROM order_items
    GROUP BY order_id
) AS oi
    ON ob.order_id = oi.order_id
INNER JOIN customers AS c
    ON ob.customer_id = c.customer_id;
    
USE olist;

DROP TABLE IF EXISTS model_base;

-- SECTION 8: MODEL_BASE (item aggregates and customer state)

CREATE TABLE model_base AS
SELECT
    ob.order_id,
    ob.customer_id,
    ob.order_purchase_timestamp,
    ob.order_estimated_delivery_date,
    ob.is_late,
    oi.n_items,
    oi.total_price,
    oi.total_freight,
    oi.n_sellers,
    c.customer_state
FROM order_base AS ob
INNER JOIN (
    SELECT
        order_id,
        COUNT(*) AS n_items,
        SUM(price) AS total_price,
        SUM(freight_value) AS total_freight,
        COUNT(DISTINCT seller_id) AS n_sellers
    FROM order_items
    GROUP BY order_id
) AS oi
    ON ob.order_id = oi.order_id
INNER JOIN customers AS c
    ON ob.customer_id = c.customer_id;
    
SELECT
    COUNT(*) AS total_orders,
    SUM(is_late) AS late_orders,
    ROUND(100 * AVG(is_late), 1) AS late_percentage
FROM model_base;


-- SECTION 9: DATE FEATURES PREVIEW 


SELECT
    order_id,
    is_late,
    DATEDIFF(
        order_estimated_delivery_date,
        order_purchase_timestamp
    ) AS promised_days,
    MONTH(order_purchase_timestamp) AS purchase_month,
    DAYOFWEEK(order_purchase_timestamp) AS purchase_dow
FROM model_base
LIMIT 10;

SELECT
    is_late,
    ROUND(
        AVG(
            DATEDIFF(
                order_estimated_delivery_date,
                order_purchase_timestamp
            )
        ), 2
    ) AS avg_promised_days
FROM model_base
GROUP BY is_late;

USE olist;

DROP TABLE IF EXISTS model_features;


-- SECTION 10: MODEL_FEATURES (date features and state-average window feature) 


CREATE TABLE model_features AS
WITH base AS (
    SELECT
        m.*,
        DATEDIFF(
            order_estimated_delivery_date,
            order_purchase_timestamp
        ) AS promised_days,
        MONTH(order_purchase_timestamp) AS purchase_month,
        DAYOFWEEK(order_purchase_timestamp) AS purchase_dow
    FROM model_base AS m
),
state_features AS (
    SELECT
        base.*,
        CAST(
            AVG(promised_days) OVER (
                PARTITION BY customer_state
            ) AS DECIMAL(10,2)
        ) AS state_avg_promised
    FROM base
)
SELECT
    state_features.*,
    CAST(
        promised_days - state_avg_promised AS DECIMAL(10,2)
    ) AS promised_vs_state
FROM state_features;

SELECT
    COUNT(*) AS total_orders,
    SUM(is_late) AS late_orders,
    ROUND(100 * AVG(is_late), 1) AS late_percentage
FROM model_features;


SELECT
    order_id,
    customer_state,
    promised_days,
    state_avg_promised,
    promised_vs_state
FROM model_features
LIMIT 10;



-- SECTION 11: FINAL CHECKS


SELECT COUNT(*) AS total_rows
FROM model_features;