# Analytics Workflow — Topic Guide

This guide describes the purpose of each of the 12 analysis topics in the repository.

## Stage 1 — Exploratory Data Analysis

### 01. Database Exploration
Understand the available schemas, tables, columns, and relationships. The goal is to learn what data exists before writing business analysis.

### 02. Dimensions Exploration
Inspect descriptive attributes and their distinct values. Examples include customer country, gender, product category, and subcategory.

### 03. Date Exploration
Inspect minimum and maximum dates, date coverage, and date ranges. Date coverage is important before comparing periods or calculating customer age and lifespan.

### 04. Measures Exploration
Identify the key numerical measures and calculate baseline metrics such as revenue, quantity, average price, order count, product count, and customer count.

### 05. Magnitude Analysis
Compare measures across business dimensions. Examples include revenue by category, customers by country, and spending by customer.

### 06. Ranking Analysis
Identify the highest- and lowest-performing entities using sorting and ranking functions. Check sort direction carefully: ascending order returns the smallest values first.

## Stage 2 — Advanced Data Analytics

### 07. Change-over-Time Analysis
Aggregate measures by month, quarter, or year to understand trends. Use date data types for sorting and grouping where possible; formatted strings are usually better suited to presentation.

### 08. Cumulative Analysis
Calculate running totals over an ordered time series. A cumulative window should order by the time period and should not partition by that same period, otherwise the running total resets for each period.

### 09. Performance Analysis
Compare current performance with a benchmark such as an average or a previous period. Functions such as `AVG() OVER()` and `LAG()` help make these comparisons.

### 10. Part-to-Whole Analysis
Measure each category's contribution to an overall total. Keep percentage results numeric in the analytical layer and format them for display later.

### 11. Data Segmentation
Group entities using documented rules, such as product cost bands or customer purchasing segments. Define boundary values carefully so every value belongs to an intentional range.

### 12. Reporting
Combine the analytical steps into reusable customer and product reporting views. Confirm the grain, calculation definitions, and totals before using the views downstream.

## Review principles

- Preserve the original query before applying improvements.
- Use clear aliases and consistent indentation.
- Make the grain of every aggregate explicit.
- Keep numeric calculations numeric until the presentation layer.
- Document business thresholds and edge cases.
- Validate totals and row counts after joins and aggregations.
