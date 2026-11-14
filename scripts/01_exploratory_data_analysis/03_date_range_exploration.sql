/*
    Project : SQL Advanced Analytics
    Script  : 03 - Date Range Exploration
    Purpose : Establish time coverage and inspect date-related data quality.

    Note: DATEDIFF(YEAR, ...) alone does not calculate completed age.
    The age expression below adjusts for whether the birthday has occurred.
*/

USE [Datawarehouse Analytics];
GO

-- 1. Sales date coverage and missing order dates.
SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    DATEDIFF(DAY, MIN(order_date), MAX(order_date)) AS date_span_days,
    DATEDIFF(YEAR, MIN(order_date), MAX(order_date)) AS year_boundary_span,
    COUNT_BIG(*) AS total_fact_rows,
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS rows_without_order_date
FROM gold.fact_sales;
GO

-- 2. Customer birthdate coverage.
SELECT
    MIN(birthdate) AS earliest_birthdate,
    MAX(birthdate) AS latest_birthdate,
    SUM(CASE WHEN birthdate IS NULL THEN 1 ELSE 0 END) AS customers_without_birthdate,
    SUM(CASE WHEN birthdate > CONVERT(date, GETDATE()) THEN 1 ELSE 0 END) AS future_birthdates
FROM gold.dim_customers;
GO

-- 3. Calculate completed age rather than simply counting year boundaries.
WITH customer_ages AS
(
    SELECT
        customer_key,
        birthdate,
        CONVERT(date, GETDATE()) AS as_of_date,
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
    FROM gold.dim_customers
)
SELECT
    MIN(age_years) AS minimum_age,
    MAX(age_years) AS maximum_age,
    AVG(CONVERT(decimal(10, 2), age_years)) AS average_age
FROM customer_ages
WHERE age_years IS NOT NULL;
GO

-- 4. Product start-date coverage.
SELECT
    MIN(start_date) AS earliest_product_start_date,
    MAX(start_date) AS latest_product_start_date,
    SUM(CASE WHEN start_date IS NULL THEN 1 ELSE 0 END) AS products_without_start_date
FROM gold.dim_products;
GO

-- 5. Inspect sales activity by calendar year.
SELECT
    YEAR(order_date) AS order_year,
    COUNT_BIG(*) AS sales_line_count,
    COUNT(DISTINCT order_number) AS distinct_order_count,
    SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY order_year;
GO
