/*
    Project : SQL Advanced Analytics
    Script  : Reporting View Validation
    Purpose : Validate dimension keys, unmatched fact rows, report grain,
              and aggregate reconciliation.

    Run after creating gold.report_customers and gold.report_products.

    This script distinguishes the full dated fact population from the
    mapped populations included in each report. Investigate unmatched
    dimension keys; do not assume they are harmless.
*/

USE [Datawarehouse Analytics];
GO

-- 1. Customer dimension keys should be unique.
SELECT
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING customer_key IS NULL OR COUNT(*) > 1;
GO

-- 2. Product dimension keys should be unique.
SELECT
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING product_key IS NULL OR COUNT(*) > 1;
GO

-- 3. Dated fact rows without a matching customer dimension record.
-- Review both the number of affected order lines and their sales value.
SELECT
    COUNT_BIG(*) AS unmatched_customer_fact_rows,
    COUNT(DISTINCT f.order_number) AS affected_orders,
    SUM(f.sales_amount) AS sales_on_unmatched_customer_rows
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
    ON f.customer_key = c.customer_key
WHERE f.order_date IS NOT NULL
  AND c.customer_key IS NULL;
GO

-- 4. Dated fact rows without a matching product dimension record.
-- The upstream product dimension contains current products only.
SELECT
    COUNT_BIG(*) AS unmatched_product_fact_rows,
    COUNT(DISTINCT f.order_number) AS affected_orders,
    SUM(f.sales_amount) AS sales_on_unmatched_product_rows
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
    ON f.product_key = p.product_key
WHERE f.order_date IS NOT NULL
  AND p.product_key IS NULL;
GO

-- 5. Customer report should contain one row per customer key.
SELECT
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.report_customers
GROUP BY customer_key
HAVING customer_key IS NULL OR COUNT(*) > 1;
GO

-- 6. Product report should contain one row per product key.
SELECT
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.report_products
GROUP BY product_key
HAVING product_key IS NULL OR COUNT(*) > 1;
GO

-- 7. Reconcile customer report coverage and sales to dated fact rows
-- with a matching customer dimension record.
WITH expected_customer_totals AS
(
    SELECT
        COUNT(DISTINCT f.customer_key) AS expected_customer_count,
        SUM(f.sales_amount) AS expected_sales
    FROM gold.fact_sales AS f
    INNER JOIN gold.dim_customers AS c
        ON f.customer_key = c.customer_key
    WHERE f.order_date IS NOT NULL
),
actual_customer_totals AS
(
    SELECT
        COUNT_BIG(*) AS report_customer_count,
        SUM(total_sales) AS report_sales
    FROM gold.report_customers
)
SELECT
    e.expected_customer_count,
    a.report_customer_count,
    e.expected_sales,
    a.report_sales,
    e.expected_sales - a.report_sales AS sales_difference
FROM expected_customer_totals AS e
CROSS JOIN actual_customer_totals AS a;
GO

-- 8. Reconcile product report coverage and sales to dated fact rows
-- with a matching product dimension record.
WITH expected_product_totals AS
(
    SELECT
        COUNT(DISTINCT f.product_key) AS expected_product_count,
        SUM(f.sales_amount) AS expected_sales
    FROM gold.fact_sales AS f
    INNER JOIN gold.dim_products AS p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
),
actual_product_totals AS
(
    SELECT
        COUNT_BIG(*) AS report_product_count,
        SUM(total_sales) AS report_sales
    FROM gold.report_products
)
SELECT
    e.expected_product_count,
    a.report_product_count,
    e.expected_sales,
    a.report_sales,
    e.expected_sales - a.report_sales AS sales_difference
FROM expected_product_totals AS e
CROSS JOIN actual_product_totals AS a;
GO

-- 9. Compare customer report metrics with an independent aggregation.
-- Any returned row indicates a difference that needs investigation.
WITH expected AS
(
    SELECT
        f.customer_key,
        COUNT(DISTINCT f.order_number) AS total_orders,
        SUM(f.quantity) AS total_quantity,
        SUM(f.sales_amount) AS total_sales
    FROM gold.fact_sales AS f
    INNER JOIN gold.dim_customers AS c
        ON f.customer_key = c.customer_key
    WHERE f.order_date IS NOT NULL
    GROUP BY f.customer_key
),
actual AS
(
    SELECT
        customer_key,
        total_orders,
        total_quantity,
        total_sales
    FROM gold.report_customers
)
SELECT 'Expected but not in report' AS difference_type, *
FROM
(
    SELECT customer_key, total_orders, total_quantity, total_sales FROM expected
    EXCEPT
    SELECT customer_key, total_orders, total_quantity, total_sales FROM actual
) AS customer_differences
UNION ALL
SELECT 'Report but not expected' AS difference_type, *
FROM
(
    SELECT customer_key, total_orders, total_quantity, total_sales FROM actual
    EXCEPT
    SELECT customer_key, total_orders, total_quantity, total_sales FROM expected
) AS report_differences;
GO

-- 10. Compare product report metrics with an independent aggregation.
WITH expected AS
(
    SELECT
        f.product_key,
        COUNT(DISTINCT f.order_number) AS total_orders,
        COUNT(DISTINCT f.customer_key) AS distinct_customers,
        SUM(f.quantity) AS total_quantity,
        SUM(f.sales_amount) AS total_sales
    FROM gold.fact_sales AS f
    INNER JOIN gold.dim_products AS p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY f.product_key
),
actual AS
(
    SELECT
        product_key,
        total_orders,
        distinct_customers,
        total_quantity,
        total_sales
    FROM gold.report_products
)
SELECT 'Expected but not in report' AS difference_type, *
FROM
(
    SELECT product_key, total_orders, distinct_customers, total_quantity, total_sales FROM expected
    EXCEPT
    SELECT product_key, total_orders, distinct_customers, total_quantity, total_sales FROM actual
) AS product_differences
UNION ALL
SELECT 'Report but not expected' AS difference_type, *
FROM
(
    SELECT product_key, total_orders, distinct_customers, total_quantity, total_sales FROM actual
    EXCEPT
    SELECT product_key, total_orders, distinct_customers, total_quantity, total_sales FROM expected
) AS report_differences;
GO

-- 11. Identify report rows with unexpected null or non-positive core metrics.
SELECT *
FROM gold.report_customers
WHERE customer_key IS NULL
   OR total_orders IS NULL
   OR total_orders <= 0
   OR total_sales IS NULL;
GO

SELECT *
FROM gold.report_products
WHERE product_key IS NULL
   OR total_orders IS NULL
   OR total_orders <= 0
   OR total_sales IS NULL;
GO
