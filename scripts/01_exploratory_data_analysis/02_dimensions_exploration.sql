/*
    Project : SQL Advanced Analytics
    Script  : 02 - Dimensions Exploration
    Purpose : Understand the descriptive attributes available for analysis.

    Dimension values are useful for identifying categories, inconsistent
    labels, missing values, and the dimensions available for grouping.
*/

USE [Datawarehouse Analytics];
GO

-- 1. Customer geography.
SELECT DISTINCT
    country
FROM gold.dim_customers
ORDER BY country;
GO

-- 2. Customer demographic and profile values.
SELECT DISTINCT
    gender,
    marital_status
FROM gold.dim_customers
ORDER BY gender, marital_status;
GO

-- 3. Product hierarchy.
SELECT DISTINCT
    category,
    subcategory,
    product_line
FROM gold.dim_products
ORDER BY category, subcategory, product_line;
GO

-- 4. Customer counts by country.
SELECT
    COALESCE(country, 'Unknown') AS country,
    COUNT(*) AS customer_count
FROM gold.dim_customers
GROUP BY country
ORDER BY customer_count DESC, country;
GO

-- 5. Customer counts by gender.
SELECT
    COALESCE(gender, 'Unknown') AS gender,
    COUNT(*) AS customer_count
FROM gold.dim_customers
GROUP BY gender
ORDER BY customer_count DESC;
GO

-- 6. Product counts by category and subcategory.
SELECT
    COALESCE(category, 'Unclassified') AS category,
    COALESCE(subcategory, 'Unclassified') AS subcategory,
    COUNT(*) AS product_count
FROM gold.dim_products
GROUP BY category, subcategory
ORDER BY category, subcategory;
GO

-- 7. Profile missing descriptive values.
SELECT
    SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS missing_country,
    SUM(CASE WHEN gender IS NULL THEN 1 ELSE 0 END) AS missing_gender,
    SUM(CASE WHEN marital_status IS NULL THEN 1 ELSE 0 END) AS missing_marital_status
FROM gold.dim_customers;
GO

SELECT
    SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS missing_category,
    SUM(CASE WHEN subcategory IS NULL THEN 1 ELSE 0 END) AS missing_subcategory,
    SUM(CASE WHEN cost IS NULL THEN 1 ELSE 0 END) AS missing_cost
FROM gold.dim_products;
GO
