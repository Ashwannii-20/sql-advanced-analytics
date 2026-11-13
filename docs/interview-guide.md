# Interview Guide — SQL Advanced Analytics

Use this guide to explain the project clearly and accurately in a technical or analytics interview. The goal is to show business understanding, SQL reasoning, and validation discipline—not to recite a list of functions.

## 1. 60-second project introduction

> I built a SQL Server analytics project on top of a dimensional data warehouse that I maintain in a separate repository. The warehouse exposes a Gold Layer sales fact view connected to customer and product dimensions. I used T-SQL to explore the data, establish baseline measures, analyse sales by business dimensions and time, rank performance, calculate running totals and period comparisons, measure category contribution, and segment customers and products. I then developed customer-level and product-level reporting views. I also documented the reporting grain, metric definitions, edge cases, and reconciliation checks so the analytical outputs can be reviewed systematically.

Be ready to show the SQL scripts, explain the logic, and run the validation checks. The current repository contains 13 documented scripts; execution and reconciliation evidence must still be produced from the target SQL Server environment.

## 2. Suggested interview walkthrough

### Step 1 — Explain the business problem

The business has sales transactions but needs to understand performance and customer/product behaviour. The analysis converts transactional rows into measures and comparisons that decision-makers can use.

### Step 2 — Explain the data model

Describe the sales fact and the customer/product dimensions. Explain the join keys and, most importantly, what one fact row represents. In this warehouse, the fact view is at sales-line grain. One order can therefore appear in multiple rows.

### Step 3 — Demonstrate exploratory analysis

Show how you inspected tables and columns, distinct dimension values, minimum and maximum dates, and baseline measures. Explain why this must happen before trend or ranking analysis.

### Step 4 — Demonstrate advanced analysis

Choose two or three examples and explain the business question, SQL method, and interpretation:

- Monthly sales trend using a date-period grouping.
- Running total using an ordered window aggregate.
- Product performance compared with an average or previous available period using `AVG() OVER()` or `LAG()`.
- Category revenue contribution using a window total.
- Customer/product segmentation using an explicit `CASE` definition.

### Step 5 — Explain the reporting views

Explain how a base query is joined, transformed, aggregated to a chosen grain, enriched with derived metrics, and stored as a view. Explain the difference between a customer-level report and a product-level report.

### Step 6 — Explain validation and limitations

Discuss join cardinality, duplicate multiplication, distinct order counting, zero denominators, date-boundary effects, and whether segmentation thresholds are consistent. An analyst should be able to explain both what the query does and where it could mislead.

## 3. Technical questions to prepare

### Why use a CTE?

A CTE gives a complex query a readable structure by naming an intermediate result. It is scoped to the statement that follows it. It is not automatically a stored table or a performance optimisation.

### What is the difference between a CTE and a view?

A CTE exists for one statement. A view is a database object that stores a query definition and can be reused by other statements. A normal view does not store a materialised copy of its results.

### Why use `COUNT(DISTINCT order_number)` instead of `COUNT(*)`?

The fact view is at sales-line grain, so an order may create multiple fact rows. `COUNT(*)` counts sales lines; `COUNT(DISTINCT order_number)` counts unique orders.

### What is the difference between `ROW_NUMBER()`, `RANK()`, and `DENSE_RANK()`?

- `ROW_NUMBER()` assigns a unique sequential number, even when values tie.
- `RANK()` gives tied rows the same rank and leaves gaps after ties.
- `DENSE_RANK()` gives tied rows the same rank without gaps.

### How do you calculate a running total?

Aggregate to the required time grain first, then use a window such as `SUM(monthly_sales) OVER (ORDER BY month_start ROWS UNBOUNDED PRECEDING)`. Do not partition by the same month if the intention is a cumulative total across months; that would restart the total for each month.

### What does `LAG()` compare?

It returns a value from a preceding row in the ordered window. If some years are missing, it compares with the previous available year, not necessarily the immediately preceding calendar year. A calendar-complete series is needed for strict year-over-year comparison.

### What is the difference between average sales per order and average monthly sales?

Average sales per order is total sales divided by distinct orders. Average monthly sales is total sales divided by a defined number of active or elapsed months. The metric name must match the denominator.

### Why is grain important?

Grain defines what one row represents. Incorrect assumptions about grain can cause double counting, incorrect order counts, or inflated totals after joins.

### How do you validate an aggregate report?

Check dimension-key uniqueness, inspect row counts before and after joins, compare totals with the source fact, verify the report's entity grain, test null/zero cases, and compare report metrics with independent source aggregates.

## 4. Project-specific design decisions

- **Sales-line grain:** fact rows are not equivalent to distinct orders; use distinct order numbers for order counts.
- **Running total:** the all-time cumulative calculation orders by month without partitioning by that same month.
- **Year comparisons:** `LAG()` is labelled as previous available year; missing years are not silently assumed to be zero.
- **Age:** the customer report adjusts age for whether the birthday has occurred this year.
- **Month lifespan:** active calendar months are defined inclusively as `DATEDIFF(MONTH, first_date, last_date) + 1`.
- **Average selling price:** product report uses total sales divided by total quantity, a weighted calculation.
- **Average order value:** total sales divided by distinct orders.
- **Average monthly sales:** total sales divided by inclusive active calendar months.
- **Customer segmentation:** VIP uses sales of at least 5,000 and activity across at least 12 calendar months; Regular uses sales of at least 1,000 and at least 12 active calendar months; all others are New. These are learning-project assumptions, not a universal business policy.
- **Customer/product coverage:** the reports are fact-driven and include entities with dated sales activity; entities with no dated sales are not included.
- **Dynamic age and recency:** these use the current system date and change as time passes.

## 5. Validation evidence to show

Run `tests/validate_reporting_views.sql` after creating the two reporting views. Be prepared to show:

1. Duplicate customer and product key checks.
2. Source-to-report sales and entity-count reconciliations.
3. Entity-level `EXCEPT` comparisons.
4. A few manually inspected customer and product records.
5. The SQL Server version and date on which you executed the scripts.

Do not claim an output, finding, performance improvement, or validation result that you cannot reproduce from the SQL and data.

## 6. Learning reference and ownership

The learning roadmap is inspired by [Data With Baraa's SQL Data Analytics Project](https://github.com/DataWithBaraa/sql-data-analytics-project). In an interview, acknowledge the reference directly. Then explain the parts you followed, the query logic you reviewed or changed, and what you independently tested or added. Do not present an instructor's original framework as entirely original work.

## 7. Honest project boundary

The repository contains 13 documented T-SQL working scripts aligned to the Gold Layer schema in the separate personal warehouse project, plus documentation and a validation script. They were reconstructed into portfolio form from the queries and logic discussed during development; they are not confirmed to be byte-for-byte copies of the original local files. End-to-end execution and validation evidence is still pending.

In an interview, distinguish clearly between:
- what you personally wrote and tested,
- what was followed as part of course material,
- what you modified or extended,
- and what remains a future improvement.