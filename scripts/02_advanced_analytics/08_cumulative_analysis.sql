/*
    Project : SQL Advanced Analytics
    Script  : 08 - Cumulative Analysis
    Purpose : Calculate a running total across monthly sales periods.

    Important: the window is ordered by month and is not partitioned by
    month. Partitioning by the month would restart the cumulative total
    inside every month and would not produce a year-to-date/all-time run.
*/

USE DataWarehouse;
GO

WITH monthly_sales AS
(
    SELECT
        DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1) AS month_start,
        SUM(sales_amount) AS monthly_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1)
)
SELECT
    month_start,
    monthly_sales,
    SUM(monthly_sales) OVER (
        ORDER BY month_start
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_sales,
    AVG(monthly_sales) OVER (
        ORDER BY month_start
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_average_monthly_sales
FROM monthly_sales
ORDER BY month_start;
GO

-- Optional: cumulative sales by calendar year.
-- This version intentionally resets at the start of each year.
WITH monthly_sales AS
(
    SELECT
        DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1) AS month_start,
        YEAR(order_date) AS order_year,
        SUM(sales_amount) AS monthly_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY
        DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1),
        YEAR(order_date)
)
SELECT
    order_year,
    month_start,
    monthly_sales,
    SUM(monthly_sales) OVER (
        PARTITION BY order_year
        ORDER BY month_start
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS year_to_date_sales
FROM monthly_sales
ORDER BY order_year, month_start;
GO
