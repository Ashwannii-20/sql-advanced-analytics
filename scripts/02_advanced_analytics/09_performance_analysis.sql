/*
    Project : SQL Advanced Analytics
    Script  : 09 - Performance Analysis
    Purpose : Compare annual product sales with the product's average
              annual sales and the previous available year.

    LAG() compares the previous row in the ordered result. If a product
    has no sales in a calendar year, the prior row may not be the prior
    calendar year. The output includes the prior year for transparency.

    The annual average is calculated across years with recorded sales for
    that product. A zero prior-year denominator produces a NULL percentage.
*/

USE [Datawarehouse Analytics];
GO

WITH yearly_product_sales AS
(
    SELECT
        p.product_key,
        p.product_name,
        p.category,
        YEAR(f.order_date) AS order_year,
        SUM(f.sales_amount) AS annual_sales
    FROM gold.fact_sales AS f
    INNER JOIN gold.dim_products AS p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY
        p.product_key,
        p.product_name,
        p.category,
        YEAR(f.order_date)
),
product_performance AS
(
    SELECT
        *,
        AVG(CONVERT(decimal(19, 4), annual_sales)) OVER (
            PARTITION BY product_key
        ) AS average_annual_sales,
        LAG(order_year) OVER (
            PARTITION BY product_key
            ORDER BY order_year
        ) AS previous_available_year,
        LAG(annual_sales) OVER (
            PARTITION BY product_key
            ORDER BY order_year
        ) AS previous_available_year_sales
    FROM yearly_product_sales
)
SELECT
    product_key,
    product_name,
    category,
    order_year,
    annual_sales,
    average_annual_sales,
    annual_sales - average_annual_sales AS difference_from_average,
    CASE
        WHEN annual_sales > average_annual_sales THEN 'Above Average'
        WHEN annual_sales < average_annual_sales THEN 'Below Average'
        ELSE 'Average'
    END AS average_performance,
    previous_available_year,
    previous_available_year_sales,
    annual_sales - previous_available_year_sales AS change_from_previous_available_year,
    CASE
        WHEN previous_available_year_sales IS NULL THEN 'No Previous Period'
        WHEN annual_sales > previous_available_year_sales THEN 'Increase'
        WHEN annual_sales < previous_available_year_sales THEN 'Decrease'
        ELSE 'No Change'
    END AS period_performance,
    CONVERT(decimal(19, 4), annual_sales - previous_available_year_sales)
        / NULLIF(CONVERT(decimal(19, 4), previous_available_year_sales), 0) * 100.0 AS percentage_change
FROM product_performance
ORDER BY product_key, order_year;
GO
