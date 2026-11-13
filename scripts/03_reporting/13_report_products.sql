/*
    Project : SQL Advanced Analytics
    Script  : 13 - Product Report
    Output  : gold.report_products
    Grain   : One row per product with at least one dated sales record.

    Metric definitions:
      - total_orders: distinct order numbers, not sales-line count.
      - distinct_customers: distinct customer keys.
      - average_selling_price_per_unit: total sales / total quantity
        (weighted average).
      - average_order_value: total sales / distinct orders.
      - average_monthly_sales: total sales / inclusive active calendar months.

    Products with no dated sales are not included because the aggregation
    is driven from the sales fact. Use the product dimension as the driving
    table with LEFT JOIN if zero-sales products must also be reported.
*/

USE DataWarehouse;
GO

CREATE OR ALTER VIEW gold.report_products
AS
WITH product_sales_base AS
(
    SELECT
        f.order_number,
        f.order_date,
        f.customer_key,
        f.sales_amount,
        f.quantity,
        p.product_key,
        p.product_id,
        p.product_number,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost,
        p.product_line
    FROM gold.fact_sales AS f
    INNER JOIN gold.dim_products AS p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
),
product_aggregation AS
(
    SELECT
        product_key,
        product_id,
        product_number,
        product_name,
        category,
        subcategory,
        cost,
        product_line,
        MIN(order_date) AS first_order_date,
        MAX(order_date) AS last_order_date,
        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT customer_key) AS distinct_customers,
        SUM(quantity) AS total_quantity,
        SUM(sales_amount) AS total_sales
    FROM product_sales_base
    GROUP BY
        product_key,
        product_id,
        product_number,
        product_name,
        category,
        subcategory,
        cost,
        product_line
),
product_metrics AS
(
    SELECT
        *,
        DATEDIFF(MONTH, first_order_date, last_order_date) + 1 AS active_calendar_months,
        DATEDIFF(MONTH, last_order_date, CONVERT(date, GETDATE())) AS recency_months,
        total_sales / NULLIF(CONVERT(decimal(18, 2), total_quantity), 0) AS average_selling_price_per_unit,
        total_sales / NULLIF(CONVERT(decimal(18, 2), total_orders), 0) AS average_order_value,
        total_sales / NULLIF(CONVERT(decimal(18, 2), DATEDIFF(MONTH, first_order_date, last_order_date) + 1), 0) AS average_monthly_sales
    FROM product_aggregation
)
SELECT
    product_key,
    product_id,
    product_number,
    product_name,
    category,
    subcategory,
    product_line,
    cost,
    first_order_date,
    last_order_date,
    active_calendar_months,
    recency_months,
    total_orders,
    distinct_customers,
    total_quantity,
    total_sales,
    average_selling_price_per_unit,
    average_order_value,
    average_monthly_sales,
    CASE
        WHEN total_sales > 50000 THEN 'High Performance'
        WHEN total_sales >= 10000 THEN 'Medium Performance'
        ELSE 'Low Performance'
    END AS sales_performance_category
FROM product_metrics;
GO

-- 1. Preview the product report.
SELECT TOP (20) *
FROM gold.report_products
ORDER BY total_sales DESC, product_key;
GO

-- 2. Check that the view has one row per product key.
SELECT
    product_key,
    COUNT(*) AS rows_per_product
FROM gold.report_products
GROUP BY product_key
HAVING COUNT(*) > 1;
GO
