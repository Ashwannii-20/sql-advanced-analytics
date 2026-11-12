# SQL Advanced Analytics

A hands-on SQL analytics project built on the Gold Layer of a dimensional data warehouse. The project focuses on exploring business data, analysing performance, identifying patterns, segmenting customers and products, and building reusable reporting views using Microsoft SQL Server (T-SQL).

## Project objectives

- Explore the database structure, dimensions, dates, and key measures.
- Analyse business magnitude and rank products, categories, and customers.
- Track changes over time and calculate cumulative metrics.
- Evaluate product performance and category contribution.
- Segment products and customers using business rules.
- Build customer and product reporting views for downstream analysis.

## Analytics workflow

The project follows a practical analytics workflow:

1. Database and dimension exploration
2. Date and measure exploration
3. Magnitude and ranking analysis
4. Change-over-time and cumulative analysis
5. Performance and part-to-whole analysis
6. Data segmentation
7. Customer and product reporting

## Repository structure

```text
sql-advanced-analytics/
├── scripts/
│   ├── 01_exploratory_data_analysis/
│   ├── 02_advanced_analytics/
│   └── 03_reporting/
├── docs/
└── README.md
```

## Technology

- Microsoft SQL Server
- T-SQL
- Common Table Expressions (CTEs)
- Joins and aggregations
- Window functions
- Views

## Data model

The analysis uses a Gold Layer dimensional model with:

- `gold.fact_sales` — sales transactions and measures
- `gold.dim_customers` — customer attributes
- `gold.dim_products` — product attributes

The source data and warehouse-building work are maintained separately in the [SQL Data Warehouse Project](https://github.com/Ashwannii-20/SQL-Data-Warehouse-Project).

## Reporting views

- `gold.report_customers` — customer-level metrics, recency, age group, and customer segment.
- `gold.report_products` — product-level sales, customer, order, recency, and performance metrics.

## Status

The 12-topic analytics workflow and the customer/product reporting exercises have been completed as part of the learning project. SQL scripts are being organised and reviewed before the repository is treated as a final, validated portfolio release.

## Notes

This repository is dedicated to analytics and reporting. It is intentionally separate from the data warehouse implementation repository.