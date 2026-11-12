# SQL Advanced Analytics

[![SQL Server](https://img.shields.io/badge/SQL%20Server-T--SQL-red)](https://www.microsoft.com/sql-server)
[![Focus](https://img.shields.io/badge/Focus-Business%20Analytics-blue)](#project-overview)
[![Repository status](https://img.shields.io/badge/Repository-Documentation%20scaffold-orange)](#current-delivery-status)

A SQL Server analytics portfolio project demonstrating how a dimensional data model can be explored and transformed into business-focused analysis and reusable reporting views.

The work covers exploratory data analysis, time-based analysis, cumulative metrics, performance comparisons, contribution analysis, customer/product segmentation, and reporting. It is designed to show not only how SQL statements work, but **why a particular analytical method is appropriate, what each result means, and how its correctness should be checked**.

> **Portfolio transparency:** The documentation and folder structure are committed. The original executable SQL scripts, representative query outputs, and run-validation evidence still need to be added. This repository should not be presented as a fully reproducible code sample until those items are committed and tested.

## Project overview

### Business context

A business has sales transactions linked to customer and product dimensions. Decision-makers need consistent answers to questions about revenue, order activity, customer behaviour, product performance, and changes over time.

This project uses SQL to move from row-level sales data to analytical outputs that can support business review and dashboard development.

### Questions explored

- Which product categories and products contribute the most and least revenue?
- How do sales, quantities, and order activity change over time?
- How does current product performance compare with a product's historical average or previous available year?
- What percentage of total revenue is contributed by each category?
- How can products be grouped into cost bands?
- How can customers be grouped using purchasing value and activity lifespan?
- Which customer and product measures belong in reusable reporting views?

### Intended outcome

Two reporting outputs form the reporting stage:

- **Customer report:** customer-level sales, order activity, recency, lifespan, age grouping, and customer segmentation.
- **Product report:** product-level sales, quantity, order/customer counts, recency, and product performance classification.

The views are intended as a consistent SQL layer for further analysis or Power BI consumption. The precise formulas and business thresholds must be confirmed against the committed SQL and documented business rules.

## Analytical workflow

The project is organised into 12 topics in two stages.

### Stage 1 — Exploratory Data Analysis

| # | Topic | Purpose |
|---:|---|---|
| 01 | Database exploration | Understand schemas, tables, columns, and available data |
| 02 | Dimensions exploration | Inspect customer and product attributes and their distinct values |
| 03 | Date exploration | Establish date coverage and understand order/customer date ranges |
| 04 | Measures exploration | Establish baseline metrics such as sales, quantity, price, orders, and customers |
| 05 | Magnitude analysis | Compare business measures across categories, countries, and customers |
| 06 | Ranking analysis | Identify highest- and lowest-performing products, categories, and customers |

### Stage 2 — Advanced Data Analytics

| # | Topic | Purpose |
|---:|---|---|
| 07 | Change-over-time analysis | Evaluate monthly and yearly trends |
| 08 | Cumulative analysis | Calculate running totals across ordered periods |
| 09 | Performance analysis | Compare performance with averages and prior available periods |
| 10 | Part-to-whole analysis | Measure category contribution to an overall total |
| 11 | Data segmentation | Group products and customers using explicit business rules |
| 12 | Reporting | Combine calculations into reusable customer and product views |

See [Analytics workflow](docs/analytics-workflow.md) for topic-level explanations and [Architecture](docs/architecture.md) for the end-to-end workflow and fact/dimension diagrams. The portfolio groups the two reporting outputs (customer and product) under one reporting topic; the learning reference may number those deliverables separately.

## Data model and analytical grain

The analysis consumes the Gold Layer of a separate dimensional warehouse project:

| Entity | Role | Analytical purpose |
|---|---|---|
| Sales fact table | Fact | Sales events and numeric measures such as sales amount and quantity |
| Customer dimension | Dimension | Customer attributes used for grouping and filtering |
| Product dimension | Dimension | Product name, category, subcategory, and cost attributes |

The expected relationship pattern is a sales fact joined to the customer dimension through the customer key and to the product dimension through the product key. Exact physical object names and join keys will be confirmed in the committed scripts and setup notes.

**Grain is a key design decision.** A fact row may represent an order line rather than a complete order. Therefore, row counts and order counts are not interchangeable. Distinct order counts should be used where the business question asks for orders rather than transaction rows.

## Methods and SQL capabilities

- Joins, filtering, and relational exploration
- Aggregations and grouping with `GROUP BY`
- Common Table Expressions (CTEs) and derived tables
- Ranking with `ROW_NUMBER()` and `RANK()`
- Window aggregates with `SUM() OVER()` and `AVG() OVER()`
- Period comparisons with `LAG()`
- Date grouping and calculations with functions such as `YEAR()`, `MONTH()`, `DATEDIFF()`, and `DATETRUNC()`
- Conditional classification using `CASE`
- Reusable reporting logic through SQL Server views

## Reporting design

The reporting pattern is:

1. **Base dataset:** join the fact table with the relevant dimensions and select the columns needed.
2. **Transformation:** derive or standardise fields using documented business rules.
3. **Aggregation:** group to the required reporting grain, such as one row per customer or product.
4. **Enrichment:** calculate ratios, recency, lifespan, and classifications.
5. **Reporting view:** expose the final result through a reusable SQL Server view.

A normal SQL Server view stores a query definition; it does not automatically store a materialised copy of the result.

## Repository structure

```text
sql-advanced-analytics/
├── scripts/
│   ├── 01_exploratory_data_analysis/
│   ├── 02_advanced_analytics/
│   └── 03_reporting/
├── docs/
│   ├── architecture.md
│   ├── analytics-workflow.md
│   ├── business-rules-and-validation.md
│   ├── interview-guide.md
│   └── README.md
└── README.md
```

## Technology and prerequisites

- Microsoft SQL Server with support for the T-SQL functions used in the scripts
- SQL Server Management Studio (SSMS) or an equivalent SQL editor
- Access to the upstream warehouse's Gold Layer tables
- Git and GitHub

The analysis is written for SQL Server/T-SQL, not generic ANSI SQL. Function availability can vary by SQL Server version; for example, confirm that the target version supports `DATETRUNC()` before executing scripts that use it.

## How to run

The run instructions will be finalised when the executable scripts are committed. The intended sequence is:

1. Build or restore the upstream warehouse using the [SQL Data Warehouse Project](https://github.com/Ashwannii-20/SQL-Data-Warehouse-Project).
2. Confirm the Gold Layer tables, column names, data types, and relationships.
3. Execute the EDA scripts to understand the dataset and baseline measures.
4. Execute the advanced analytics scripts.
5. Create the customer and product reporting views.
6. Run the validation checks and compare report totals with source aggregates.

Do not execute the reporting stage until the physical table names and column definitions have been checked against the target database.

## Quality and analytical controls

The project documentation includes checks for:

- Join cardinality and unintended row multiplication
- Reporting grain and one-row-per-entity expectations
- Reconciliation of aggregate totals to source data
- Null, zero, and missing-date handling
- Division-by-zero protection
- Date boundary behaviour and recency definitions
- Consistent segment thresholds and correctly named metrics

See [Business rules and validation](docs/business-rules-and-validation.md) for the review checklist and known calculation risks.

## Interview preparation

[Interview guide](docs/interview-guide.md) contains a concise project explanation, a suggested walkthrough, and technical questions to prepare for. Be ready to explain the grain of the fact table, the logic behind each metric, and how you validated the results—not just the SQL syntax.

## Current delivery status

| Deliverable | Status |
|---|---|
| Project overview and architecture documentation | Committed |
| 12-topic analytical workflow documentation | Committed |
| Interview and validation guides | Committed |
| Original executable SQL scripts | To be added |
| Query outputs or screenshots | To be added |
| End-to-end execution and reconciliation evidence | Pending |

The 12-topic workflow and the customer/product reporting exercises have been completed as learning work. The repository is being prepared as a reproducible portfolio submission; it is not yet claiming that all SQL files have been independently executed and validated from this repository.

## Learning reference and attribution

This project follows a learning workflow inspired by [Data With Baraa — SQL Data Analytics Project](https://github.com/DataWithBaraa/sql-data-analytics-project), which provides the original educational roadmap, datasets, and example SQL materials. This repository is a separate personal learning and portfolio workspace; it is not the upstream project and is not affiliated with or endorsed by its author. Any source code copied or adapted from the upstream repository must retain the applicable attribution and license notices. Original modifications, additional validation, and project-specific explanations should be identified clearly.

## Related project

The upstream warehouse implementation is maintained separately:

[SQL Data Warehouse Project](https://github.com/Ashwannii-20/SQL-Data-Warehouse-Project)

That project focuses on the data foundation and Bronze/Silver/Gold layers. This repository focuses on analytical use of the Gold Layer.