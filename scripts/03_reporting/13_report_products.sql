/*
    Project : SQL Advanced Analytics
    Script  : 13 - Product Report
    Output  : gold.report_products
    Grain   : One row per product with dated sales and a matching product dimension record.

    Metric definitions:
      - total_orders: distinct order numbers, not sales-line count.
      - distinct_customers: distinct customer keys.
      - weighted_sales_per_unit: total sales / total quantity
        (weighted average).
      - average_product_sales_per_order: total sales / distinct orders.
      - average_sales_per_calendar_month_in_span: total sales / inclusive sales activity month span.

    Products with no dated sales or no matching current product dimension
    record are excluded by the fact-driven inner join. Use the product
    dimension as the driving table with LEFT JOIN if zero-sales products
    must also be reported; define historical-product coverage separately.
*/

USE [Datawarehouse Analytics];
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
        DATEDIFF(MONTH, first_order_date, last_order_date) + 1 AS sales_activity_month_span,
        DATEDIFF(MONTH, last_order_date, CONVERT(date, GETDATE())) AS months_since_last_order_month_boundary,
        CONVERT(decimal(19, 4), total_sales) / NULLIF(CONVERT(decimal(19, 4), total_quantity), 0) AS weighted_sales_per_unit,
        CONVERT(decimal(19, 4), total_sales) / NULLIF(CONVERT(decimal(19, 4), total_orders), 0) AS average_product_sales_per_order,
        CONVERT(decimal(19, 4), total_sales) / NULLIF(CONVERT(decimal(19, 4), DATEDIFF(MONTH, first_order_date, last_order_date) + 1), 0) AS average_sales_per_calendar_month_in_span
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
    sales_activity_month_span,
    months_since_last_order_month_boundary,
    total_orders,
    distinct_customers,
    total_quantity,
    total_sales,
    weighted_sales_per_unit,
    average_product_sales_per_order,
    average_sales_per_calendar_month_in_span,
    CASE
        WHEN total_sales > 50000 THEN 'High Performance'
        WHEN total_sales >= 10000 THEN 'Medium Performance'
        ELSE 'Low Performance'
    END AS revenue_performance_band
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
