# Business Rules, Metric Definitions, and Validation

This document records the metric formulas and classification assumptions used by the portfolio scripts. It also defines the checks required before the reporting views are treated as validated.

## 1. Metric definition register

| Metric | Formula / implementation | Interpretation |
|---|---|---|
| Total sales | SUM(sales_amount) | Confirm currency, tax, discount, and additive treatment in the source model. |
| Total quantity | SUM(quantity) | Assumes units are comparable across the aggregated rows. |
| Distinct orders | COUNT(DISTINCT order_number) | The fact is at order-line grain; row count is not order count. |
| Distinct customers | COUNT(DISTINCT customer_key) | Excludes null customer keys. |
| Customer average order value | Customer sales / customer's distinct orders | Average sales per order for that customer. |
| Product sales per order | Product sales / distinct orders containing that product | Not the overall basket value of those orders. |
| Weighted sales per unit | Total sales / total quantity | Quantity-weighted calculation; confirm discount and tax treatment. |
| Month-boundary recency | DATEDIFF(MONTH, last_order_date, as_of_date) | Counts month boundaries, not completed 30-day periods. |
| Sales activity month span | DATEDIFF(MONTH, first_order_date, last_order_date) + 1 | Inclusive calendar-month span between first and last dated orders; not the number of months with purchases. |
| Average sales per calendar month in span | Total sales / sales activity month span | Includes calendar months with no orders inside the span. |
| Category contribution | Category sales / overall sales | Numerator and denominator must use the intended filter context. |

Use numeric results in SQL and apply display formatting in the presentation layer.

## 2. Classification assumptions

The following thresholds are explicit learning-project assumptions. They are not universal customer policies or externally approved commercial rules.

### Product cost bands

| Segment | Rule |
|---|---|
| Below 100 | Cost < 100 |
| 100 to under 500 | Cost >= 100 and < 500 |
| 500 to 1,000 | Cost >= 500 and <= 1,000 |
| Above 1,000 | Cost > 1,000 |
| Unknown Cost | Cost is NULL |

The ranges are continuous at their boundaries. Negative costs should be investigated as source-data exceptions if present.

### Customer segments

- **VIP:** total sales of at least 5,000 and a sales activity month span of at least 12.
- **Regular:** total sales of at least 1,000 and a sales activity month span of at least 12.
- **New:** all other customers included in the sales-driven analysis.

The label **New** is the residual bucket in this exercise; it does not prove that a customer was newly acquired. The span condition is based on first and last dated order months, not the number of months with an order.

### Product revenue performance bands

| Segment | Rule |
|---|---|
| High Performance | Total sales > 50,000 |
| Medium Performance | Total sales >= 10,000 and <= 50,000 |
| Low Performance | Total sales < 10,000 |

These bands measure sales revenue only. They do not measure profit, margin, unit economics, or growth. Calibrate thresholds to a business context before using them for management decisions.

## 3. SQL interpretation notes

| Area | Interpretation |
|---|---|
| Running total | The all-time running total is ordered by month without partitioning by that same month. The separate year-to-date example partitions by year deliberately. |
| Ranking | Descending revenue returns the highest values; ascending revenue returns the lowest values. |
| LAG() | Returns the previous available row in the ordered set. It is not necessarily the previous calendar year when periods are missing. |
| Customer age | The expression adjusts the year difference for whether the birthday has occurred by the as-of date. |
| Calendar-month span | DATEDIFF(MONTH) + 1 measures the inclusive calendar-month span. It is not an active-month count. |
| Weighted sales per unit | Total sales divided by total quantity; not the unweighted average of row-level prices. |
| Customer/product coverage | Reports require a non-null order date and a matching key in the relevant dimension. |
| Dynamic fields | Age and month-boundary recency use the current system date and change over time. |

## 4. Source coverage and join behaviour

The upstream fact view uses left joins to customer and product dimensions. A fact row can have a null dimension key if the source key has no match.

The customer report joins the customer dimension and therefore excludes fact rows without a matching customer. The product report joins the product dimension and therefore excludes fact rows without a matching product. The upstream product dimension contains current products only; historical sales for discontinued or otherwise absent products may not have a product match.

The validation script reports unmatched fact rows and their sales amounts separately from report reconciliations. A reconciliation that uses inner joins validates the mapped reporting population; it does not, by itself, prove that every source fact row is represented.

## 5. Validation checklist

### Data model and joins
- Confirm the sales fact's order-line grain.
- Check customer and product dimension-key uniqueness.
- Identify fact rows with null or unmatched customer and product keys.
- Compare row counts before and after joins.
- Investigate unexpected row multiplication or unmatched dimension keys.

### Aggregations
- Reconcile total sales and quantity to the defined source population.
- Compare distinct order counts with independent order-level results.
- Verify that grouping columns match the intended output grain.
- Test tied values in ranking queries.
- Check empty groups and null-measure behaviour.

### Calculations
- Use NULLIF(denominator, 0) where division by zero is possible.
- Check decimal precision and integer-division behaviour.
- Keep ratios numeric until presentation.
- Verify date logic around year-end, month-end, and birthdays.
- Test values immediately below, at, and above segmentation boundaries.

### Reporting views
- Confirm the views compile against the target SQL Server schema.
- Verify one row per intended customer or product key.
- Check output column names and data types.
- Reconcile the mapped sales population to the relevant report.
- Record the as-of date used for dynamic recency and age fields.

## 6. Validation status and observed execution evidence

Selected manual validation queries were executed successfully in SSMS on 14 November 2026. The observed results are recorded in [Execution Evidence and Reconciliation](validation-evidence.md).

| Check | Observed result | Status |
|---|---:|---|
| Fact rows | 60,398 | Observed |
| Fact sales | 29,356,250 | Observed |
| Fact quantity | 60,423 | Observed |
| Distinct orders | 27,659 | Observed |
| Unmatched customer keys in tested fact join | 0 | Pass for this query |
| Unmatched product keys in tested fact join | 0 | Pass for this query |
| Duplicate product keys | No rows returned | Pass for this query |
| NULL order-date rows | 19 rows; sales 4,992 | Documented exclusion |
| Customer report rows | 18,482 | Observed |
| Product report rows | 130 | Observed |
| Customer report sales | 29,351,258 | Observed |
| Product report sales | 29,351,258 | Observed |

Both report definitions contain `order_date IS NOT NULL`. The 4,992 difference between the full fact sales and each report is exactly the sales amount on the 19 rows with a NULL order date. Thus, the totals reconcile for the dated population represented by the two views.

**Scope limitation:** these screenshots establish selected manual checks only. They do not establish that the complete committed validation script has been run. Customer dimension-key duplicates, reporting-view key uniqueness, entity-level metric comparisons, and unexpected-null checks still require explicit result evidence.

**Database-context limitation:** screenshots show SSMS working context `Datawarehouse Analytics`; the committed SQL scripts currently specify `USE DataWarehouse;`. Confirm and standardise this context before describing the screenshots as evidence that the committed scripts ran unchanged.

Do not publish performance claims or claim the full validation suite passed until the remaining checks are executed and recorded.
