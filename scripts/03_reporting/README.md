# Reporting — Scripts 12–13

The reporting layer contains two SQL Server views with explicit entity-level grain and documented metric definitions.

| Script | View | Output grain |
|---|---|---|
| 12 | gold.report_customers | One row per customer with dated sales and a matching customer dimension record |
| 13 | gold.report_products | One row per product with dated sales and a matching product dimension record |

The scripts use CREATE OR ALTER VIEW and can be rerun to update the view definitions.

After creating both views, execute [tests/validate_reporting_views.sql](../../tests/validate_reporting_views.sql). The reports use inner joins to the relevant dimensions, so fact rows without a matching dimension key are excluded. The validation script surfaces those unmatched rows separately.

The product report's revenue performance band is based on sales value only; it does not represent profitability or growth.
