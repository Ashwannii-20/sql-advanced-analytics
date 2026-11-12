# SQL Advanced Analytics

![SQL Server](https://img.shields.io/badge/SQL%20Server-T--SQL-red)
![Project](https://img.shields.io/badge/Focus-Advanced%20Analytics-blue)
![Status](https://img.shields.io/badge/Status-Learning%20project-success)

A practical **SQL Server (T-SQL) analytics project** built on top of a dimensional data warehouse. It demonstrates how raw business questions can be translated into structured SQL analysis and reusable reporting views.

The project uses the Gold Layer tables from a separate data warehouse project. The focus here is not building the warehouse; it is using trusted, modelled data to discover trends, measure performance, understand customer and product behaviour, and prepare analytical outputs.

> **Project boundary:** Data warehouse engineering and analytical consumption are maintained as two separate repositories. See [SQL Data Warehouse Project](https://github.com/Ashwannii-20/SQL-Data-Warehouse-Project) for the upstream warehouse implementation.

---

## 1. Business purpose

Business data becomes useful when it is converted into evidence that supports decisions. This project applies SQL to answer questions such as:

- Which product categories and products generate the most revenue?
- How are sales changing month by month and year by year?
- Which products are performing above or below their historical averages?
- What share of overall revenue comes from each category?
- How can customers be grouped using purchasing behaviour?
- Which customer and product metrics should be exposed in reusable reports?

The aim is to demonstrate the complete analytical workflow: **explore → measure → compare → explain → segment → report**.

## 2. Analytical workflow

The project is organised into 12 learning topics across two stages.

### Stage 1 — Exploratory Data Analysis (EDA)

| # | Topic | What it investigates |
|---:|---|---|
| 01 | Database Exploration | Tables, schemas, columns, and database structure |
| 02 | Dimensions Exploration | Descriptive attributes such as country, gender, category, and product |
| 03 | Date Exploration | Date ranges, order history, and customer age ranges |
| 04 | Measures Exploration | Core metrics such as revenue, quantity, price, orders, and customers |
| 05 | Magnitude Analysis | How measures vary across categories, countries, and customers |
| 06 | Ranking Analysis | Highest- and lowest-performing products, categories, and customers |

### Stage 2 — Advanced Data Analytics

| # | Topic | What it investigates |
|---:|---|---|
| 07 | Change-over-Time Analysis | Monthly and yearly trends |
| 08 | Cumulative Analysis | Running totals and cumulative performance |
| 09 | Performance Analysis | Current performance compared with averages and previous periods |
| 10 | Part-to-Whole Analysis | Contribution of a category or segment to the overall total |
| 11 | Data Segmentation | Grouping products and customers using defined business rules |
| 12 | Reporting | Reusable customer and product reporting views |

## 3. How the analysis is structured

The analytical process starts with the Gold Layer fact and dimension tables. SQL then shapes the data into a useful base dataset, applies business logic, aggregates the results, enriches the output with derived metrics, and exposes the result through reporting views.

The detailed architecture diagram is available in [docs/architecture.md](docs/architecture.md).

## 4. Data model used

The project analyses a simple star-schema-style model:

| Table | Role | Typical contents |
|---|---|---|
| `gold.fact_sales` | Fact table | Sales transactions, order dates, quantities, sales amounts, customer and product keys |
| `gold.dim_customers` | Dimension table | Customer identifiers and descriptive attributes |
| `gold.dim_products` | Dimension table | Product identifiers, names, categories, subcategories, and costs |

The fact table contains measurable business events. Dimension tables provide the descriptive context used to group, filter, and interpret those events.

**Join pattern:** `fact_sales` is joined to `dim_customers` using `customer_key`, and to `dim_products` using `product_key`.

## 5. Reporting outputs

The reporting stage creates two reusable views:

### `gold.report_customers`

A customer-level analytical view designed to summarise purchasing behaviour. Its measures and derived attributes include:

- Total orders, sales, quantity, and distinct products
- Customer lifespan and most recent order date
- Recency, average order value, and average monthly spend
- Age group and customer segment classifications

### `gold.report_products`

A product-level analytical view designed to summarise product performance. Its measures and derived attributes include:

- Total sales, quantity, and orders
- Number of distinct customers
- Product lifespan and most recent order date
- Recency and sales performance category
- Average sales per unit and derived sales metrics

Business rules and calculation definitions should be reviewed alongside the SQL before these views are used for operational or financial decisions.

## 6. SQL techniques demonstrated

- Relational joins and filtering
- Aggregations with `GROUP BY`
- Common Table Expressions (CTEs)
- Subqueries and derived tables
- Ranking functions such as `ROW_NUMBER()` and `RANK()`
- Analytic window functions such as `SUM() OVER()`, `AVG() OVER()`, and `LAG()`
- Date functions such as `YEAR()`, `MONTH()`, `DATEDIFF()`, and `DATETRUNC()`
- Conditional business logic with `CASE`
- Views for reusable reporting datasets

## 7. Repository structure

```text
sql-advanced-analytics/
├── scripts/
│   ├── 01_exploratory_data_analysis/
│   ├── 02_advanced_analytics/
│   └── 03_reporting/
├── docs/
│   ├── architecture.md
│   ├── analytics-workflow.md
│   └── README.md
└── README.md
```

SQL scripts will be placed in the folder matching their topic. The original learning queries are to be preserved; suggested corrections and review notes should be documented separately rather than silently changing the original work.

## 8. Tools and environment

- Microsoft SQL Server
- T-SQL
- SQL Server Management Studio (SSMS) or a compatible SQL editor
- Git and GitHub for version control

## 9. Project status and validation

The 12-topic analytics workflow and the customer/product reporting exercises have been completed as learning exercises. The repository structure and documentation are now in place.

The project should be considered **portfolio-ready only after** the complete SQL scripts, data/schema assumptions, execution checks, and report calculations have been reviewed and validated against the source database. No claim is made here that the scripts have been independently executed in this repository.

## 10. Related project

The upstream warehouse project covers data ingestion, transformation, data quality, and the Bronze/Silver/Gold architecture:

[SQL Data Warehouse Project](https://github.com/Ashwannii-20/SQL-Data-Warehouse-Project)

This repository focuses on the next step: using the Gold Layer to perform business analysis and create reporting outputs.
