# Financial Performance & Variance Analysis (PostgreSQL)

## Overview
I built this project to demonstrate a finance-style reporting workflow using PostgreSQL and SQL. I loaded a retail transactions dataset into Postgres, engineered key financial fields (cost and budget), and then produced FP&A-style outputs such as gross margin trends and budget vs actual variance. This is meant to simulate how a business operations tream would analyze metrics such as revenue,margin, and budget variance using SQL.

## Components
- A staging table (`superstore_raw`) to ingest the raw CSV
- A reporting table (`transactions`) with derived financial fields:
  - **Cost = Sales - Profit**
  - **Budget Revenue = Sales × 1.05**
  - **Budget Cost = Cost × 1.03**
- A set of SQL queries to generate decision-ready financial reporting outputs

## Dataset
- Sample Superstore retail dataset
- ~9,994 rows of order-level transactions
- Fields used: Order Date, Sales, Profit, Category, Sub-Category, Region, Discount

## Analyses (Outputs)
The SQL queries in `/sql/03_financial_analysis.sql` generate:
1. **Monthly financials**: revenue, cost, gross profit, gross margin %
2. **Budget vs actual variance**: revenue variance and cost variance by month
3. **Variance by region**: which regions are over/under budget
4. **Profitability by category**: margin % by category
5. **Top cost drivers**: sub-categories contributing most to total cost
6. **Discount impact**: profit margin by discount bucket

All query results are exported to `/outputs` as CSV files.

## How to Reproduce
1. Create tables using: `/sql/01_create_tables.sql`
2. Load data into `superstore_raw` (CSV import)
3. Transform into `transactions` using: `/sql/02_transform_insert.sql`
4. Run analysis queries from: `/sql/03_financial_analysis.sql`

## Skills Demonstrated
- SQL data ingestion + transformation
- Financial metric engineering (cost, margin)
- Budget vs actual variance analysis
- Aggregation, CASE logic, subqueries
- Business-focused reporting outputs
