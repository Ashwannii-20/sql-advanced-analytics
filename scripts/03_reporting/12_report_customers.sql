/*
    Project : SQL Advanced Analytics
    Script  : 12 - Customer Report
    Output  : gold.report_customers
    Grain   : One row per customer with at least one dated sales record.

    Metric definitions:
      - total_orders: distinct order numbers, not sales-line count.
      - active_calendar_months: inclusive count of calendar months between
        first and last dated orders.
      - average_order_value: total sales / distinct orders.
      - average_monthly_sales: total sales / active calendar months.
      - recency_months: month boundaries since the last dated order.

    Customer age and recency use the current system date; outputs therefore
    change over time. Change the reference-date design if a fixed reporting
    snapshot is required.
*/

USE DataWarehouse;
GO

CREATE OR ALTER VIEW gold.report_customers
AS
WITH customer_sales_base AS
(
    SELECT
        f.order_number,
        f.order_date,
        f.product_key,
        f.sales_amount,
        f.quantity,
        c.customer_key,
        c.customer_id,
        c.customer_number,
        c.first_name,
        c.last_name,
        c.country,
        c.gender,
        c.marital_status,
        c.birthdate
    FROM gold.fact_sales AS f
    INNER JOIN gold.dim_customers AS c
        ON f.customer_key = c.customer_key
    WHERE f.order_date IS NOT NULL
),
customer_aggregation AS
(
    SELECT
        customer_key,
        customer_id,
        customer_number,
        first_name,
        last_name,
        country,
        gender,
        marital_status,
        birthdate,
        MIN(order_date) AS first_order_date,
        MAX(order_date) AS last_order_date,
        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT product_key) AS distinct_products,
        SUM(quantity) AS total_quantity,
        SUM(sales_amount) AS total_sales
    FROM customer_sales_base
    GROUP BY
        customer_key,
        customer_id,
        customer_number,
        first_name,
        last_name,
        country,
        gender,
        marital_status,
        birthdate
),
customer_metrics AS
(
    SELECT
        *,
        DATEDIFF(MONTH, first_order_date, last_order_date) + 1 AS active_calendar_months,
        DATEDIFF(MONTH, last_order_date, CONVERT(date, GETDATE())) AS recency_months,
        CASE
            WHEN birthdate IS NULL OR birthdate > CONVERT(date, GETDATE()) THEN NULL
            ELSE
                DATEDIFF(YEAR, birthdate, CONVERT(date, GETDATE()))
                - CASE
                    WHEN DATEADD(
                        YEAR,
                        DATEDIFF(YEAR, birthdate, CONVERT(date, GETDATE())),
                        birthdate
                    ) > CONVERT(date, GETDATE())
                    THEN 1
                    ELSE 0
                  END
        END AS age_years
    FROM customer_aggregation
)
SELECT
    customer_key,
    customer_id,
    customer_number,
    CONCAT(first_name, ' ', last_name) AS customer_name,
    country,
    gender,
    marital_status,
    birthdate,
    age_years,
    CASE
        WHEN age_years IS NULL THEN 'Unknown'
        WHEN age_years < 20 THEN 'Under 20'
        WHEN age_years BETWEEN 20 AND 29 THEN '20-29'
        WHEN age_years BETWEEN 30 AND 39 THEN '30-39'
        WHEN age_years BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50+'
    END AS age_group,
    first_order_date,
    last_order_date,
    active_calendar_months,
    recency_months,
    total_orders,
    distinct_products,
    total_quantity,
    total_sales,
    total_sales / NULLIF(CONVERT(decimal(18, 2), total_orders), 0) AS average_order_value,
    total_sales / NULLIF(CONVERT(decimal(18, 2), active_calendar_months), 0) AS average_monthly_sales,
    CASE
        WHEN total_sales >= 5000 AND active_calendar_months >= 12 THEN 'VIP'
        WHEN total_sales >= 1000 AND active_calendar_months >= 12 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment
FROM customer_metrics;
GO

-- 1. Preview the customer report.
SELECT TOP (20) *
FROM gold.report_customers
ORDER BY total_sales DESC, customer_key;
GO

-- 2. Check that the view has one row per customer key.
SELECT
    customer_key,
    COUNT(*) AS rows_per_customer
FROM gold.report_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;
GO
