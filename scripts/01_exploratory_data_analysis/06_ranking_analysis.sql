/*
    Project : SQL Advanced Analytics
    Script  : 06 - Ranking Analysis
    Purpose : Identify top- and bottom-performing products, subcategories,
              and customers.
*/

USE [Datawarehouse Analytics];
GO

-- 1. Top five products by revenue.
SELECT TOP (5)
    p.product_key,
    p.product_name,
    p.category,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
INNER JOIN gold.dim_products AS p
    ON f.product_key = p.product_key
GROUP BY p.product_key, p.product_name, p.category
ORDER BY total_revenue DESC, p.product_key;
GO

-- 2. Bottom five products by revenue.
-- This is intentionally ascending: it returns the lowest revenue products.
SELECT TOP (5)
    p.product_key,
    p.product_name,
    p.category,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
INNER JOIN gold.dim_products AS p
    ON f.product_key = p.product_key
GROUP BY p.product_key, p.product_name, p.category
ORDER BY total_revenue ASC, p.product_key;
GO

-- 3. Top five subcategories by revenue.
SELECT TOP (5)
    p.category,
    p.subcategory,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
INNER JOIN gold.dim_products AS p
    ON f.product_key = p.product_key
GROUP BY p.category, p.subcategory
ORDER BY total_revenue DESC, p.category, p.subcategory;
GO

-- 4. Rank products using a window function.
WITH product_revenue AS
(
    SELECT
        p.product_key,
        p.product_name,
        p.category,
        SUM(f.sales_amount) AS total_revenue
    FROM gold.fact_sales AS f
    INNER JOIN gold.dim_products AS p
        ON f.product_key = p.product_key
    GROUP BY p.product_key, p.product_name, p.category
),
ranked_products AS
(
    SELECT
        *,
        ROW_NUMBER() OVER (
            ORDER BY total_revenue DESC, product_key
        ) AS revenue_row_number,
        RANK() OVER (
            ORDER BY total_revenue DESC
        ) AS revenue_rank
    FROM product_revenue
)
SELECT *
FROM ranked_products
WHERE revenue_row_number <= 5
ORDER BY revenue_row_number;
GO

-- 5. Top ten customers by distinct order count.
WITH customer_orders AS
(
    SELECT
        c.customer_key,
        c.customer_number,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        COUNT(DISTINCT f.order_number) AS total_orders
    FROM gold.fact_sales AS f
    INNER JOIN gold.dim_customers AS c
        ON f.customer_key = c.customer_key
    GROUP BY
        c.customer_key,
        c.customer_number,
        c.first_name,
        c.last_name
)
SELECT TOP (10) *
FROM customer_orders
ORDER BY total_orders DESC, customer_key;
GO

-- 6. Customers with the fewest orders (a separate bottom-N question).
WITH customer_orders AS
(
    SELECT
        c.customer_key,
        c.customer_number,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        COUNT(DISTINCT f.order_number) AS total_orders
    FROM gold.fact_sales AS f
    INNER JOIN gold.dim_customers AS c
        ON f.customer_key = c.customer_key
    GROUP BY
        c.customer_key,
        c.customer_number,
        c.first_name,
        c.last_name
)
SELECT TOP (10) *
FROM customer_orders
ORDER BY total_orders ASC, customer_key;
GO
