/*
    Project : SQL Advanced Analytics
    Script  : 11 - Data Segmentation
    Purpose : Group products by cost and customers by purchasing behaviour.

    The thresholds are illustrative assumptions for this exercise and
    should be confirmed with a business owner before operational use.

    The customer span is the inclusive first-to-last order month range,
    not the number of months in which purchases actually occurred.
    The 'New' label is the residual segment, not proof of recent acquisition.
*/

USE DataWarehouse;
GO

-- 1. Product segmentation by cost.
-- Continuous ranges avoid the gap between 500 and 501.
WITH product_cost_bands AS
(
    SELECT
        product_key,
        product_name,
        cost,
        CASE
            WHEN cost IS NULL THEN 'Unknown Cost'
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost >= 100 AND cost < 500 THEN '100 to under 500'
            WHEN cost >= 500 AND cost <= 1000 THEN '500 to 1000'
            ELSE 'Above 1000'
        END AS cost_segment
    FROM gold.dim_products
)
SELECT
    cost_segment,
    COUNT(*) AS product_count,
    MIN(cost) AS minimum_cost,
    MAX(cost) AS maximum_cost
FROM product_cost_bands
GROUP BY cost_segment
ORDER BY
    CASE cost_segment
        WHEN 'Below 100' THEN 1
        WHEN '100 to under 500' THEN 2
        WHEN '500 to 1000' THEN 3
        WHEN 'Above 1000' THEN 4
        ELSE 5
    END;
GO

-- 2. Customer segmentation by sales value and sales activity month span.
-- Only customers with at least one dated sales record are included.
WITH customer_purchase_summary AS
(
    SELECT
        c.customer_key,
        c.customer_number,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        MIN(f.order_date) AS first_order_date,
        MAX(f.order_date) AS last_order_date,
        COUNT(DISTINCT f.order_number) AS total_orders,
        SUM(f.sales_amount) AS total_sales,
        SUM(f.quantity) AS total_quantity,
        DATEDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) + 1 AS sales_activity_month_span
    FROM gold.fact_sales AS f
    INNER JOIN gold.dim_customers AS c
        ON f.customer_key = c.customer_key
    WHERE f.order_date IS NOT NULL
    GROUP BY
        c.customer_key,
        c.customer_number,
        c.first_name,
        c.last_name
),
segmented_customers AS
(
    SELECT
        *,
        CASE
            WHEN total_sales >= 5000 AND sales_activity_month_span >= 12 THEN 'VIP'
            WHEN total_sales >= 1000 AND sales_activity_month_span >= 12 THEN 'Regular'
            ELSE 'New'
        END AS customer_segment
    FROM customer_purchase_summary
)
SELECT
    customer_segment,
    COUNT(*) AS customer_count,
    SUM(total_sales) AS segment_sales,
    AVG(CONVERT(decimal(19, 4), total_sales)) AS average_customer_sales,
    AVG(CONVERT(decimal(18, 2), total_orders)) AS average_orders
FROM segmented_customers
GROUP BY customer_segment
ORDER BY
    CASE customer_segment
        WHEN 'VIP' THEN 1
        WHEN 'Regular' THEN 2
        ELSE 3
    END;
GO

-- 3. Inspect the customer-level assignments.
WITH customer_purchase_summary AS
(
    SELECT
        c.customer_key,
        c.customer_number,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        MIN(f.order_date) AS first_order_date,
        MAX(f.order_date) AS last_order_date,
        COUNT(DISTINCT f.order_number) AS total_orders,
        SUM(f.sales_amount) AS total_sales,
        DATEDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) + 1 AS sales_activity_month_span
    FROM gold.fact_sales AS f
    INNER JOIN gold.dim_customers AS c
        ON f.customer_key = c.customer_key
    WHERE f.order_date IS NOT NULL
    GROUP BY
        c.customer_key,
        c.customer_number,
        c.first_name,
        c.last_name
)
SELECT
    *,
    CASE
        WHEN total_sales >= 5000 AND sales_activity_month_span >= 12 THEN 'VIP'
        WHEN total_sales >= 1000 AND sales_activity_month_span >= 12 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment
FROM customer_purchase_summary
ORDER BY total_sales DESC, customer_key;
GO
