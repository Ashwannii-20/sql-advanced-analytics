# Analytics Workflow

This guide explains the purpose of each analytical topic and the business question it supports.

## Stage 1 — Exploratory Data Analysis

### 01. Database exploration
Inspect schemas, objects, columns, data types, and row counts. Establish the structure of the Gold Layer before writing analytical queries.

### 02. Dimensions exploration
Review descriptive attributes and distinct values, including customer geography and profile fields and the product hierarchy. Identify missing or inconsistent labels.

### 03. Date range exploration
Establish sales date coverage and inspect missing dates, customer birthdates, and product start dates. Apply completed-age logic rather than relying only on a year-boundary difference.

### 04. Measures exploration
Calculate baseline sales, quantity, order, customer, and product measures. Distinguish transaction-line counts from distinct order counts.

### 05. Magnitude analysis
Compare measures across business dimensions, including category revenue, customer geography, product counts, and customer spending.

### 06. Ranking analysis
Identify top- and bottom-performing products, subcategories, and customers. Validate sort direction and define a tie-handling approach.

## Stage 2 — Advanced Analytics

### 07. Change-over-time analysis
Aggregate sales and activity by month and year. Use date values for chronological grouping and sorting.

### 08. Cumulative analysis
Calculate an all-time running total across monthly periods and a separate year-to-date measure. The all-time window is not partitioned by month; the year-to-date window is partitioned by year intentionally.

### 09. Performance analysis
Compare annual product sales with the product's average annual sales and its previous available year. The output identifies the prior available year so missing calendar periods are not mistaken for zero-sales periods.

### 10. Part-to-whole analysis
Calculate category revenue as a percentage of overall revenue. Keep percentages numeric in the SQL layer and apply display formatting downstream.

### 11. Data segmentation
Group products into cost bands and customers into purchasing segments. Boundary values are defined explicitly. Thresholds are analytical assumptions and should not be treated as approved commercial policy.

### 12. Reporting
Create customer- and product-level views using CTEs to separate base selection, aggregation, metric calculation, and classification.

## Working principles

- Establish the row grain before aggregating.
- Use clear aliases and consistent formatting.
- Make metric formulas and denominators explicit.
- Preserve numeric precision through the analytical layer.
- Document treatment of nulls, zero values, and missing periods.
- Verify join cardinality and reconcile totals to source data.
