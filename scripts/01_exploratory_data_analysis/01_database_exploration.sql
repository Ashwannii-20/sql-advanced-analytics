/*
    Project : SQL Advanced Analytics
    Script  : 01 - Database Exploration
    Database: Datawarehouse Analytics
    Purpose : Inspect the Gold Layer objects and their column definitions.

    Run this script first. It is read-only and does not modify database objects.
*/

USE [Datawarehouse Analytics];
GO

-- 1. Confirm the current database.
SELECT
    DB_NAME() AS current_database,
    SUSER_SNAME() AS executing_login,
    GETDATE() AS execution_datetime;
GO

-- 2. List tables and views available in the Gold schema.
SELECT
    TABLE_SCHEMA,
    TABLE_NAME,
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'gold'
ORDER BY TABLE_TYPE, TABLE_NAME;
GO

-- 3. Inspect columns, data types, and nullability in the analytical model.
SELECT
    TABLE_SCHEMA,
    TABLE_NAME,
    ORDINAL_POSITION,
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    NUMERIC_PRECISION,
    NUMERIC_SCALE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'gold'
ORDER BY TABLE_NAME, ORDINAL_POSITION;
GO

-- 4. Check the row counts of the three expected Gold Layer objects.
SELECT 'gold.dim_customers' AS object_name, COUNT_BIG(*) AS row_count
FROM gold.dim_customers
UNION ALL
SELECT 'gold.dim_products', COUNT_BIG(*)
FROM gold.dim_products
UNION ALL
SELECT 'gold.fact_sales', COUNT_BIG(*)
FROM gold.fact_sales;
GO

-- 5. Preview a small sample from each object.
SELECT TOP (10) *
FROM gold.dim_customers
ORDER BY customer_key;
GO

SELECT TOP (10) *
FROM gold.dim_products
ORDER BY product_key;
GO

SELECT TOP (10) *
FROM gold.fact_sales
ORDER BY order_date, order_number;
GO
