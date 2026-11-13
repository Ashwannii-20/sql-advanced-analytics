# Reporting — Scripts 12–13

The reporting layer contains two SQL Server views, each with a defined entity-level grain.

| Script | View | Grain |
|---|---|---|
| 12 | `gold.report_customers` | One row per customer with at least one dated sales record |
| 13 | `gold.report_products` | One row per product with at least one dated sales record |

The scripts use `CREATE OR ALTER VIEW` so they can be re-run to update the view definitions. Run the validation script in `tests/validate_reporting_views.sql` after creating both views.

**Important:** These reports are fact-driven. Customers and products with no dated sales are not included.