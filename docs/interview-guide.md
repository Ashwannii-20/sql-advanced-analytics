# Interview Guide — SQL Advanced Analytics

Use this guide to explain the project clearly and accurately in a technical or analytics interview. The goal is to show business understanding, SQL reasoning, and validation discipline—not to recite a list of functions.

## 1. 60-second project introduction

> I built a SQL Server analytics project on top of a dimensional data warehouse. The warehouse provides a Gold Layer sales fact and customer and product dimensions. I used T-SQL to explore the data, establish baseline measures, analyse sales by business dimensions and time, rank performance, calculate running totals and period comparisons, measure category contribution, and segment customers and products. I then structured customer-level and product-level reporting logic into reusable SQL views. I focused on making the analysis understandable and validating the reporting grain, joins, calculations, and business rules. The warehouse implementation is maintained separately from this analytics repository.

Use this as a speaking framework. Be prepared to show the actual scripts and query outputs once those artifacts have been committed.

## 2. Suggested interview walkthrough

### Step 1 — Explain the business problem

The business has sales transactions but needs to understand performance and customer/product behaviour. The analysis converts transactional rows into measures and comparisons that decision-makers can use.

### Step 2 — Explain the data model

Describe the sales fact and the customer/product dimensions. Explain the join keys and, most importantly, what one fact row represents. Do not assume the fact is at order grain if it is actually at order-line grain.

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

If each order can contain multiple sales lines, `COUNT(*)` counts rows or lines, not unique orders. The correct count depends on the fact table's grain and the business question.

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

Check dimension-key uniqueness, inspect row counts before and after joins, compare totals with the source fact, verify the report's entity grain, test null/zero cases, and check a few entities manually.

## 4. Project-specific review points

These are important items identified while reviewing the SQL exercises discussed during development. Resolve them in the scripts before describing the reports as final:

- **Running total:** remove the partition by the same date/month when the required result is cumulative across the full timeline.
- **Ranking direction:** `TOP (N)` with ascending order returns the smallest values. Label it as a bottom-N analysis, or sort descending for top-N.
- **Previous-period comparison:** explain that `LAG()` uses the prior available row unless missing periods are filled.
- **Age calculation:** `DATEDIFF(YEAR, birth_date, current_date)` can overstate age before the birthday in the current year.
- **Month calculations:** `DATEDIFF(MONTH, start_date, end_date)` counts month boundaries, not necessarily complete elapsed months.
- **Average per unit:** `AVG(sales_amount / quantity)` is an average of row-level ratios. A weighted average selling price is usually `SUM(sales_amount) / NULLIF(SUM(quantity), 0)`.
- **Metric naming:** total sales divided by lifespan months is average monthly sales, not average sales per order.
- **Segment consistency:** use the same threshold definitions in exploratory segmentation and the final customer report, or explain why the definitions differ.
- **Customer coverage:** a report built from the sales fact excludes customers with no sales unless the query starts from the customer dimension and handles missing fact rows.
- **Dynamic recency:** calculations using the current system date change over time. State the reference date or make it a controlled parameter for reproducible reporting.

## 5. What to show on screen

For a strong technical interview, have these items available:

1. The architecture diagram and the fact/dimension join diagram.
2. The actual SQL script for one EDA example, one window-function example, one segmentation example, and each reporting view.
3. Query outputs with the column names and a few representative rows.
4. Reconciliation or validation queries showing that totals and row grain are correct.
5. A short explanation of the business definition behind each derived metric.

Do not claim an output, finding, performance improvement, or validation result that you cannot reproduce from the SQL and data.

## 6. Learning reference and ownership

The learning roadmap is based on the educational material in [Data With Baraa's SQL Data Analytics Project](https://github.com/DataWithBaraa/sql-data-analytics-project). In an interview, acknowledge the reference directly. Then explain which parts you followed, which queries or business rules you changed, and what you independently tested or added. Do not present an instructor's original framework as entirely original work.

## 7. Honest project boundary

The analytics exercises and reporting logic have been completed as learning work. The repository currently contains the documentation scaffold; executable SQL scripts and reproducible result evidence still need to be committed and tested. Update this section of your preparation once those artifacts are available.

In an interview, distinguish clearly between:
- what you personally wrote and tested,
- what was followed as part of course material,
- what you modified or extended,
- and what remains a future improvement.