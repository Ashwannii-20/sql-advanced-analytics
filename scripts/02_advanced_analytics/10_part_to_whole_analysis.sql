/*
    Project : SQL Advanced Analytics
    Script  : 10 - Part-to-Whole Analysis
    Purpose : Calculate each product category's contribution to overall
              sales revenue.

    Keep percentages numeric in SQL. Apply display formatting in a
    reporting or presentation layer.
*/

USE DataWarehouse;
GO

WITH category_sales AS
(
    SELECT
        COALESCE(p.category, 'Unclassified') AS category,
        SUM(f.sales_amount) AS total_sales
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_products AS p
        ON f.product_key = p.product_key
    GROUP BY COALESCE(p.category, 'Unclassified')
)
SELECT
    category,
    total_sales,
    SUM(total_sales) OVER () AS overall_sales,
    total_sales * 100.0 / NULLIF(SUM(total_sales) OVER (), 0) AS percentage_of_total_sales
FROM category_sales
ORDER BY total_sales DESC;
GO
