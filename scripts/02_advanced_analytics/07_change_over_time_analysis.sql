/*
    Project : SQL Advanced Analytics
    Script  : 07 - Change-over-Time Analysis
    Purpose : Analyse monthly and yearly movement in revenue, units,
              orders, and active customers.
*/

USE DataWarehouse;
GO

-- 1. Monthly sales trend.
-- DATEFROMPARTS returns a date value that sorts chronologically.
-- Only periods with fact rows appear; zero-activity months are not generated.
SELECT
    DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1) AS month_start,
    SUM(sales_amount) AS monthly_sales,
    SUM(quantity) AS monthly_quantity,
    COUNT(DISTINCT order_number) AS distinct_orders,
    COUNT(DISTINCT customer_key) AS active_customers
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1)
ORDER BY month_start;
GO

-- 2. Yearly sales trend.
SELECT
    YEAR(order_date) AS order_year,
    SUM(sales_amount) AS annual_sales,
    SUM(quantity) AS annual_quantity,
    COUNT(DISTINCT order_number) AS distinct_orders,
    COUNT(DISTINCT customer_key) AS active_customers
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY order_year;
GO

-- 3. Monthly revenue by product category.
SELECT
    DATEFROMPARTS(YEAR(f.order_date), MONTH(f.order_date), 1) AS month_start,
    COALESCE(p.category, 'Unclassified') AS category,
    SUM(f.sales_amount) AS monthly_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
    ON f.product_key = p.product_key
WHERE f.order_date IS NOT NULL
GROUP BY
    DATEFROMPARTS(YEAR(f.order_date), MONTH(f.order_date), 1),
    p.category
ORDER BY month_start, monthly_revenue DESC;
GO
