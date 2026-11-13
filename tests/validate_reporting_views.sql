/*
    Project : SQL Advanced Analytics
    Script  : Reporting View Validation
    Purpose : Check report grain, coverage, and key aggregate reconciliation.

    Run after scripts/03_reporting/12_report_customers.sql and
    scripts/03_reporting/13_report_products.sql.

    Expected behaviour:
      - Duplicate-key queries should return no rows.
      - Source-versus-report reconciliation should show zero differences.
      - Entity-level EXCEPT checks should return no rows.

    These checks have been authored but still need execution against the
    user's SQL Server database before results can be claimed as verified.
*/

USE DataWarehouse;
GO

-- 1. Customer report: duplicate customer keys should not exist.
SELECT
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.report_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;
GO

-- 2. Product report: duplicate product keys should not exist.
SELECT
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.report_products
GROUP BY product_key
HAVING COUNT(*) > 1;
GO

-- 3. Reconcile customer-report coverage and sales against the dated fact rows
-- that have a matching customer dimension row.
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

-- 4. Reconcile product-report coverage and sales against dated fact rows
-- that have a matching product dimension row.
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

-- 5. Compare customer report metrics with an independent aggregation.
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

-- 6. Compare product report metrics with an independent aggregation.
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

-- 7. Identify report rows with unexpected null or negative core metrics.
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
