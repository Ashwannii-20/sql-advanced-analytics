# Setup and Execution Guide

## Prerequisites

- Microsoft SQL Server and SSMS (or a compatible T-SQL client).
- The separate [SQL Data Warehouse Project](https://github.com/Ashwannii-20/SQL-Data-Warehouse-Project) restored or executed.
- A database named `DataWarehouse` containing the Gold Layer views:
  - `gold.fact_sales`
  - `gold.dim_customers`
  - `gold.dim_products`

The existing Data Warehouse repository provides the source schema and Gold Layer views. This analytics repository does not recreate or drop that database.

## Confirm the source model

Run `01_database_exploration.sql` and confirm that the expected object names and columns are present. The scripts were written against the Gold Layer definitions in the linked warehouse repository.

Known important fields include:

- Fact: `order_number`, `product_key`, `customer_key`, `order_date`, `sales_amount`, `quantity`, `price`.
- Customer: `customer_key`, `customer_id`, `customer_number`, `first_name`, `last_name`, `country`, `gender`, `marital_status`, `birthdate`.
- Product: `product_key`, `product_id`, `product_number`, `product_name`, `category`, `subcategory`, `cost`, `product_line`, `start_date`.

## Execution order

Run the 13 SQL scripts in numerical order:

1. `scripts/01_exploratory_data_analysis/01_database_exploration.sql`
2. `scripts/01_exploratory_data_analysis/02_dimensions_exploration.sql`
3. `scripts/01_exploratory_data_analysis/03_date_range_exploration.sql`
4. `scripts/01_exploratory_data_analysis/04_measures_exploration.sql`
5. `scripts/01_exploratory_data_analysis/05_magnitude_analysis.sql`
6. `scripts/01_exploratory_data_analysis/06_ranking_analysis.sql`
7. `scripts/02_advanced_analytics/07_change_over_time_analysis.sql`
8. `scripts/02_advanced_analytics/08_cumulative_analysis.sql`
9. `scripts/02_advanced_analytics/09_performance_analysis.sql`
10. `scripts/02_advanced_analytics/10_part_to_whole_analysis.sql`
11. `scripts/02_advanced_analytics/11_data_segmentation.sql`
12. `scripts/03_reporting/12_report_customers.sql`
13. `scripts/03_reporting/13_report_products.sql`

Scripts 01–11 are read-only analytical queries. Scripts 12 and 13 create or alter the customer and product reporting views in the `gold` schema.

## Validate the reporting views

After creating both reporting views, run `tests/validate_reporting_views.sql`.

Review the output:
- Duplicate-key checks should return no rows.
- Source/report aggregate reconciliations should show no difference.
- Entity-level `EXCEPT` comparisons should return no rows.
- Any rows returned by the null/metric checks must be investigated.

A query executing without an error is not proof that its business logic is correct. Record the SQL Server version, execution date, row counts, reconciliation outputs, and any accepted exceptions when validating the project.

## Important notes

- The scripts use T-SQL and include SQL Server-specific functions.
- The customer and product reports include entities with dated sales activity. Entities without dated sales are excluded.
- Recency and age metrics in the customer report use `GETDATE()`, so those fields change over time.
- Active calendar months use the inclusive definition `DATEDIFF(MONTH, first_date, last_date) + 1`.
- Segmentation thresholds are analytical assumptions for this learning project, not externally approved business policies.
- These scripts were reconstructed into a documented portfolio set from the SQL exercises and reporting logic discussed during development. They should be compared with the original local files and executed before being treated as the final validated versions.