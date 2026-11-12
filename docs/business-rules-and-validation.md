# Business Rules, Metric Definitions, and Validation

This file records how analytical definitions should be documented and what must be checked before the reporting views are treated as final.

## 1. Metric definition register

| Metric | Recommended definition | Important check |
|---|---|---|
| Total sales | Sum of the sales amount at the fact grain | Confirm the source amount is additive and currency is consistent |
| Total quantity | Sum of transaction quantity | Confirm unit of measure is consistent |
| Distinct orders | Count of distinct order identifiers | Do not substitute fact-row count when one order has multiple lines |
| Distinct customers | Count of distinct customer keys | Confirm unknown/placeholder keys are treated consistently |
| Average order value | Total sales divided by distinct orders | Protect against zero orders |
| Average selling price per unit | Total sales divided by total quantity | This is a weighted calculation; document whether discounts/tax are included |
| Recency | Reference date minus last activity date | State the reference date and unit |
| Activity lifespan | Difference between first and last activity dates | Define whether this means month boundaries or complete elapsed months |
| Category contribution | Category sales divided by total sales | Ensure numerator and denominator use the same filter context |

Use numeric results in SQL and apply display formatting in the presentation layer.

## 2. Segmentation rules

Segmentation thresholds are business definitions, not universal truths. Document the exact boundaries and confirm they are mutually exclusive and collectively exhaustive.

For every band, check:
- Lower and upper bounds
- Whether each bound is inclusive or exclusive
- Decimal values between integer-looking boundaries
- Null and negative values
- Whether entities without transactions are included
- Whether thresholds are consistent across exploratory analysis and reporting views

The product cost bands and customer VIP/Regular/New segments discussed during development should be reconciled with the final reporting definitions before publication.

## 3. Review findings from the learning queries

The following are review items based on the SQL logic discussed while developing this project. They are not a claim that the source scripts in this repository have already been revised.

| Area | Potential issue | Recommended action |
|---|---|---|
| Cumulative total | Partitioning by the same month/date resets the running total | Aggregate by period, order by period, and omit that partition |
| Top-N ranking | Ascending sort returns the smallest values | Use descending for top-N; ascending for bottom-N |
| `LAG()` | Previous row may not be previous calendar year | Fill missing periods or label as previous available period |
| Customer age | Year difference ignores whether birthday has occurred | Apply a birthday adjustment or use a validated age expression |
| Month lifespan | `DATEDIFF(MONTH)` counts month boundaries | State the definition; calculate complete months if required |
| Average per unit | `AVG(row_sales / row_quantity)` is an unweighted average of row ratios | Use `SUM(sales) / SUM(quantity)` for a weighted unit average when appropriate |
| Average per order | Sales divided by lifespan months is monthly sales | Rename it or change the denominator to distinct orders |
| Segment rules | Different thresholds in analysis and report produce inconsistent labels | Define thresholds once and reuse them |
| Customer coverage | Starting from the sales fact omits customers with no sales | Start from the customer dimension if zero-activity customers are required |
| Recency | `GETDATE()` changes output over time | Use a declared as-of date for repeatable reporting |

## 4. SQL validation checklist

### Data model and joins

- Confirm the sales fact's grain from its keys and source design.
- Check that customer and product dimension keys are unique at the join grain.
- Compare row counts before and after joins.
- Check for unmatched dimension keys.
- Confirm no unintended many-to-many relationship multiplies sales rows.

### Aggregations

- Reconcile total sales and quantity to the fact table.
- Compare distinct order counts with known order-level results.
- Verify grouping columns match the intended grain.
- Test tied values in ranking queries.
- Check empty groups and null measure behaviour.

### Calculations

- Use `NULLIF(denominator, 0)` where division by zero is possible.
- Check decimal precision and integer division.
- Keep ratios numeric until presentation.
- Verify date logic around year-end, month-end, and birthdays.
- Test values exactly below, at, and above segmentation thresholds.

### Reporting views

- Confirm the view compiles against the target SQL Server schema.
- Verify one row per intended customer or product key.
- Check column names and data types.
- Reconcile key metrics to independently written validation queries.
- Record the date used for dynamic recency calculations.

## 5. Reproducibility

When scripts are added, document:
- SQL Server version
- Required database and schema
- Upstream repository and setup sequence
- Expected source tables and columns
- Script execution order
- Expected output grain
- Validation queries and observed results

Do not publish invented row counts, performance claims, or business findings. Add only results reproduced from the actual database.