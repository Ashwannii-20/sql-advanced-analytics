# Setup and Execution

## Prerequisites

- Microsoft SQL Server and SQL Server Management Studio (SSMS), or a compatible T-SQL client.
- The related [SQL Data Warehouse Project](https://github.com/Ashwannii-20/SQL-Data-Warehouse-Project) built or restored.
- A database containing these Gold Layer views (the scripts select `Datawarehouse Analytics`):
  - gold.fact_sales
  - gold.dim_customers
  - gold.dim_products

This repository consumes the existing Gold Layer. It does not create or drop the upstream warehouse database.

## 1. Confirm the source model

Open scripts/01_exploratory_data_analysis/01_database_exploration.sql and confirm the expected objects, columns, and data types exist.

The scripts expect these fields:

- **Fact:** order_number, product_key, customer_key, order_date, sales_amount, quantity, price.
- **Customer:** customer_key, customer_id, customer_number, first_name, last_name, country, gender, marital_status, birthdate.
- **Product:** product_key, product_id, product_number, product_name, category, subcategory, cost, product_line, start_date.

## 2. Execute the analytical scripts

Run scripts 01–11 in numerical order:

1. scripts/01_exploratory_data_analysis/01_database_exploration.sql
2. scripts/01_exploratory_data_analysis/02_dimensions_exploration.sql
3. scripts/01_exploratory_data_analysis/03_date_range_exploration.sql
4. scripts/01_exploratory_data_analysis/04_measures_exploration.sql
5. scripts/01_exploratory_data_analysis/05_magnitude_analysis.sql
6. scripts/01_exploratory_data_analysis/06_ranking_analysis.sql
7. scripts/02_advanced_analytics/07_change_over_time_analysis.sql
8. scripts/02_advanced_analytics/08_cumulative_analysis.sql
9. scripts/02_advanced_analytics/09_performance_analysis.sql
10. scripts/02_advanced_analytics/10_part_to_whole_analysis.sql
11. scripts/02_advanced_analytics/11_data_segmentation.sql

Scripts 01–11 are analytical queries and do not create or alter database objects.

## 3. Create the reporting views

Run:

12. scripts/03_reporting/12_report_customers.sql
13. scripts/03_reporting/13_report_products.sql

These scripts use CREATE OR ALTER VIEW to create or update gold.report_customers and gold.report_products.

The customer report includes dated fact rows with a matching customer key. The product report includes dated fact rows with a matching product key. The two views can therefore represent different mapped populations when source dimension keys are missing.

## 4. Run the validation script

Execute tests/validate_reporting_views.sql after both views have been created.

Review each result set:

- Dimension-key uniqueness checks should return no rows.
- Duplicate reporting-key checks should return no rows.
- Unmatched fact-key checks should be reviewed and explained.
- Source-to-report reconciliations should have zero differences for the mapped populations used by each report.
- Entity-level EXCEPT comparisons should return no rows.
- Unexpected null or invalid report metrics should be investigated.

A query completing without a SQL error is not proof that its business logic is correct. Record the SQL Server version, execution date, result counts, reconciliation outputs, and accepted exceptions.

The observed manual results and reconciliation are documented in [Execution Evidence and Reconciliation](validation-evidence.md).

## Important implementation notes

- The scripts use SQL Server T-SQL syntax.
- The upstream sales fact is at order-line grain.
- The upstream product dimension contains current products only.
- The upstream fact view uses left joins; unmatched dimension keys can be null.
- Reporting views use inner joins and exclude fact rows without a matching key for the relevant dimension.
- The inclusive calendar-month span is DATEDIFF(MONTH, first_date, last_date) + 1; it is not a count of months with purchases.
- Age and month-boundary recency use GETDATE() and therefore change over time.
- Customer and product thresholds are illustrative assumptions for this portfolio project.
