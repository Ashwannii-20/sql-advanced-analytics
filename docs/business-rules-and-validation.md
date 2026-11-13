# Business Rules, Metric Definitions, and Validation

This file records the metrics and business assumptions implemented in the current portfolio scripts, along with the checks required before the reports can be treated as final.

## 1. Metric definition register

| Metric | Definition used in the scripts | Important interpretation |
|---|---|---|
| Total sales | Sum of sales amount at fact grain | Confirm currency and additive treatment |
| Total quantity | Sum of transaction quantity | Assumes a consistent unit of measure |
| Distinct orders | Count of distinct order numbers | The fact is at sales-line grain; row count is not order count |
| Distinct customers | Count of distinct customer keys | Confirm treatment of any unknown/placeholder keys |
| Average order value | Total sales divided by distinct orders | Protect against zero orders |
| Average selling price per unit | Total sales divided by total quantity | Weighted calculation; confirm treatment of discounts/tax |
| Recency | Month boundaries from last activity to current date | Uses `GETDATE()`; result changes with time |
| Active calendar months | `DATEDIFF(MONTH, first_date, last_date) + 1` | Inclusive count of calendar months touched, not complete elapsed months |
| Category contribution | Category sales divided by overall sales | Numerator and denominator must share the intended filter context |

Use numeric results in SQL and apply display formatting in the presentation layer.

## 2. Segmentation rules implemented

The scripts currently use these learning-project thresholds:

### Product cost bands

- Below 100
- 100 to less than 500
- 500 to 1,000 inclusive
- Above 1,000
- Unknown cost where cost is NULL

These ranges are continuous at the boundary values. Negative costs should be treated as a source-data exception and investigated if they appear.

### Customer segments

- **VIP:** total sales at least 5,000 and at least 12 active calendar months.
- **Regular:** total sales at least 1,000 and at least 12 active calendar months.
- **New:** all other customers included in the sales-driven analysis.

These are illustrative portfolio assumptions, not universal customer policies or externally approved business rules. Change them only with a documented business rationale.

### Product performance bands

- High Performance: total sales greater than 50,000.
- Medium Performance: total sales from 10,000 through 50,000 inclusive.
- Low Performance: total sales below 10,000.

Thresholds should be calibrated to the business context before they are used for management decisions.

## 3. Important SQL interpretation points

| Area | Correct interpretation |
|---|---|
| Cumulative total | The all-time running total is ordered by month without partitioning by that same month. A separate year-to-date example partitions by year deliberately. |
| Ranking | Descending revenue returns top-N; ascending revenue returns bottom-N. |
| `LAG()` | Compares with the previous available row in the ordered set, not automatically the previous calendar year. |
| Customer age | The report adjusts the year difference for whether the birthday has occurred. |
| Month lifespan | `DATEDIFF(MONTH)` counts month boundaries; the scripts use an inclusive calendar-month definition by adding one. |
| Average per unit | The product report uses total sales divided by total quantity, which is weighted by quantity. |
| Average per order | Total sales divided by distinct orders. |
| Average monthly sales | Total sales divided by inclusive active calendar months. |
| Customer/product coverage | The current reports are fact-driven and exclude entities with no dated sales activity. |
| Dynamic recency and age | These fields use the current system date and will change when the view is queried later. |

## 4. Validation checklist

### Data model and joins

- Confirm the sales fact's sales-line grain.
- Check customer and product dimension key uniqueness.
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

## 5. Validation status

The SQL checks are committed in `tests/validate_reporting_views.sql`. They have not yet been run against the target SQL Server database in this workflow. Once executed, record the SQL Server version, run date, actual result counts, reconciliation differences, and any accepted exceptions here.

Do not publish invented row counts, performance claims, or business findings.