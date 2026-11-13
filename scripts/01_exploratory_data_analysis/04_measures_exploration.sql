/*
    Project : SQL Advanced Analytics
    Script  : 04 - Measures Exploration
    Purpose : Establish baseline business measures before segmentation
              or trend analysis.
*/

USE DataWarehouse;
GO

-- 1. Core sales measures.
SELECT
    COUNT_BIG(*) AS sales_line_count,
    COUNT(DISTINCT order_number) AS distinct_order_count,
    COUNT(DISTINCT customer_key) AS distinct_customer_count,
    COUNT(DISTINCT product_key) AS distinct_product_count,
    SUM(quantity) AS total_quantity,
    SUM(sales_amount) AS total_sales,
    AVG(CONVERT(decimal(18, 2), price)) AS average_line_price,
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date
FROM gold.fact_sales;
GO

-- 2. Weighted average selling price per unit.
-- This is total sales divided by total units, not an unweighted average
-- of individual row-level sales/quantity ratios.
SELECT
    SUM(CONVERT(decimal(19, 4), sales_amount)) AS total_sales,
    SUM(CONVERT(decimal(19, 4), quantity)) AS total_quantity,
    SUM(CONVERT(decimal(19, 4), sales_amount))
        / NULLIF(SUM(CONVERT(decimal(19, 4), quantity)), 0) AS weighted_average_sales_per_unit
FROM gold.fact_sales
WHERE quantity IS NOT NULL
  AND sales_amount IS NOT NULL;
GO

-- 3. Dimension counts.
SELECT
    (SELECT COUNT_BIG(*) FROM gold.dim_customers) AS customer_dimension_rows,
    (SELECT COUNT_BIG(*) FROM gold.dim_products) AS product_dimension_rows;
GO

-- 4. Distinct buyers and distinct orders with valid order dates.
SELECT
    COUNT(DISTINCT customer_key) AS customers_with_valid_dated_sales,
    COUNT(DISTINCT order_number) AS orders_with_valid_order_dates
FROM gold.fact_sales
WHERE order_date IS NOT NULL;
GO

-- 5. Business metrics displayed as a labelled result set.
SELECT 'Total Sales' AS metric_name, CONVERT(decimal(19, 2), SUM(sales_amount)) AS metric_value
FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity', CONVERT(decimal(19, 2), SUM(quantity))
FROM gold.fact_sales
UNION ALL
SELECT 'Distinct Orders', CONVERT(decimal(19, 2), COUNT(DISTINCT order_number))
FROM gold.fact_sales
UNION ALL
SELECT 'Distinct Customers', CONVERT(decimal(19, 2), COUNT(DISTINCT customer_key))
FROM gold.fact_sales;
GO
