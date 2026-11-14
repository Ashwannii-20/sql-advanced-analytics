# Project Walkthrough

This document provides a concise, technically accurate explanation of the project's business context, data model, analytical approach, design decisions, and current validation status.

## Project summary

This project uses Microsoft SQL Server and T-SQL to analyse sales data from a dimensional data warehouse. It progresses from source-model exploration to business analysis and reusable customer- and product-level reporting views.

The analytical work is organised around a practical question: how can transaction-line data be converted into consistent measures that help explain sales performance and customer/product behaviour?

## Business questions

1. **Sales overview:** What are the baseline sales, quantity, order, customer, and product measures?
2. **Product and customer analysis:** Which categories, products, and customers have the highest or lowest contribution?
3. **Time analysis:** How do sales and order activity change by month and year?
4. **Performance and mix:** How do products compare with historical averages, and how much does each category contribute to total sales?
5. **Segmentation and reporting:** How can product costs and customer purchasing behaviour be grouped using explicit rules?

## Data architecture

The project consumes three views from the Gold Layer of the related [SQL Data Warehouse Project](https://github.com/Ashwannii-20/SQL-Data-Warehouse-Project):

- **gold.fact_sales:** order number, customer and product keys, order date, sales amount, quantity, and price.
- **gold.dim_customers:** customer identifiers and descriptive attributes.
- **gold.dim_products:** product identifiers, hierarchy, cost, and product attributes.

The sales fact is at order-line grain. One order can contain multiple product lines, so a row count is not a valid substitute for a distinct order count.

The upstream fact view left-joins the customer and product dimensions. Rows without a matching dimension record can have a null dimension key. The reporting views use inner joins and therefore report only dated sales rows with a matching key for the relevant dimension. The product dimension contains current products only, so some historical product sales may not have a current dimension match.

## Analytical approach

| Stage | Focus | Deliverables |
|---|---|---|
| Exploratory analysis | Understand the schema, dimensions, dates, measures, magnitude, and rankings | Scripts 01–06 |
| Advanced analytics | Analyse trends, running totals, performance, contribution, and segments | Scripts 07–11 |
| Reporting | Aggregate and enrich data at customer and product grain | Scripts 12–13 |

CTEs separate logical query stages. Window functions support ranking, running totals, historical comparisons, and contribution calculations. The reporting scripts use CREATE OR ALTER VIEW to expose reusable SQL definitions.

## Important metric definitions

- **Distinct orders:** count of distinct order numbers, because the fact is at order-line grain.
- **Customer average order value:** customer sales divided by that customer's distinct orders.
- **Product sales per order:** product sales divided by the distinct orders containing that product. This is not the overall basket value of those orders.
- **Weighted sales per unit:** total sales divided by total quantity.
- **Calendar-month span:** DATEDIFF(MONTH, first_order_date, last_order_date) + 1. This is the inclusive span between the first and last order months; it is not the count of months with at least one purchase.
- **Recency:** month boundaries between the last dated order and the current system date.
- **Previous-period comparison:** LAG() returns the previous available row in the ordered data. It does not guarantee the previous calendar year when gaps exist.

The complete metric register and classification thresholds are maintained in [Business Rules and Validation](business-rules-and-validation.md).

## Design and control considerations

- Define the grain before aggregating.
- Check dimension-key uniqueness and join cardinality.
- Identify fact rows without customer or product dimension mappings.
- Use distinct order counts where the business question concerns orders.
- Protect division calculations against zero denominators.
- Keep percentages numeric until presentation.
- Make date-boundary behaviour explicit.
- Document segmentation thresholds as assumptions that require business approval before operational use.
- Reconcile report totals and entity-level measures to independent source queries.

## Current status and evidence

Selected SQL queries were executed successfully in SSMS on 14 November 2026. The observed fact table contained 60,398 rows, 29,356,250 in sales, 60,423 units, and 27,659 distinct orders. The two report views each returned sales of 29,351,258.

The 4,992 difference is explained by 19 fact rows with NULL order dates. Both reporting view definitions contain `order_date IS NOT NULL`, and 29,356,250 - 4,992 = 29,351,258. The tested unmatched-customer and unmatched-product queries returned zero; the tested duplicate-product-key query returned no rows. See [Execution Evidence and Reconciliation](validation-evidence.md).


No runtime improvements or production-readiness claims are made.

## Further development

Potential next steps, subject to validated requirements:

- Add a calendar dimension for complete month and year comparisons.
- Define an explicit approach for historical products absent from the current-product dimension.
- Add zero-activity customer/product coverage where required by the business.
- Parameterise reporting as-of dates for reproducible snapshots.
- Add a Power BI model using the validated reporting views.
- Capture repeatable execution evidence and query plans before making performance claims.
