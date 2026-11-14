/*
    Project : SQL Advanced Analytics
    Script  : 05 - Magnitude Analysis
    Purpose : Compare the scale of sales and customer/product measures
              across useful business dimensions.
*/

USE [Datawarehouse Analytics];
GO

-- 1. Revenue by product category.
SELECT
    COALESCE(p.category, 'Unclassified') AS category,
    SUM(f.sales_amount) AS total_revenue,
    SUM(f.quantity) AS total_units_sold,
    COUNT(DISTINCT f.order_number) AS distinct_orders
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
    ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY total_revenue DESC;
GO

-- 2. Customer count by country.
SELECT
    COALESCE(country, 'Unknown') AS country,
    COUNT(*) AS customer_count
FROM gold.dim_customers
GROUP BY country
ORDER BY customer_count DESC;
GO

-- 3. Customer count by gender.
SELECT
    COALESCE(gender, 'Unknown') AS gender,
    COUNT(*) AS customer_count
FROM gold.dim_customers
GROUP BY gender
ORDER BY customer_count DESC;
GO

-- 4. Product count by category.
SELECT
    COALESCE(category, 'Unclassified') AS category,
    COUNT(*) AS product_count
FROM gold.dim_products
GROUP BY category
ORDER BY product_count DESC;
GO

-- 5. Average product cost by category.
SELECT
    COALESCE(category, 'Unclassified') AS category,
    AVG(CONVERT(decimal(18, 2), cost)) AS average_product_cost,
    COUNT(*) AS product_count
FROM gold.dim_products
GROUP BY category
ORDER BY average_product_cost DESC;
GO

-- 6. Total spend by customer (highest spend first).
SELECT TOP (20)
    c.customer_key,
    c.customer_number,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    SUM(f.sales_amount) AS total_spend,
    COUNT(DISTINCT f.order_number) AS distinct_orders
FROM gold.fact_sales AS f
INNER JOIN gold.dim_customers AS c
    ON f.customer_key = c.customer_key
GROUP BY
    c.customer_key,
    c.customer_number,
    c.first_name,
    c.last_name
ORDER BY total_spend DESC, c.customer_key;
GO

-- 7. Total quantity sold by customer country.
SELECT
    COALESCE(c.country, 'Unknown') AS country,
    SUM(f.quantity) AS total_quantity_sold,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
    ON f.customer_key = c.customer_key
GROUP BY c.country
ORDER BY total_quantity_sold DESC;
GO

-- 8. Revenue by customer gender.
SELECT
    COALESCE(c.gender, 'Unknown') AS gender,
    SUM(f.sales_amount) AS total_revenue,
    COUNT(DISTINCT f.customer_key) AS distinct_customers
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
    ON f.customer_key = c.customer_key
GROUP BY c.gender
ORDER BY total_revenue DESC;
GO
