# finance-sql-variance-analysis

A financial variance analysis project using PostgreSQL and the Superstore retail dataset (2014–2017). I built this to practice writing production-style SQL for finance use cases — budget vs. actual variance, margin analysis, cost decomposition, and more recently, trend and segment analysis using window functions.

---

## Project Structure

```
sql/
  01_create_tables.sql        — DDL for superstore_raw and transactions tables
  02_transform_insert.sql     — ETL: transforms raw data, derives cost and budget figures
  03_financial_analysis.sql   — Core variance and margin queries (analyses 1–6)
  04_advanced_analysis.sql    — Advanced queries: YoY growth, segments, seasonality (analyses 7–11)
data/
  superstore_clean.csv        — Source data (~10,000 rows)
outputs/
  monthly_variance.csv
  variance_by_region.csv
  margin_by_category.csv
  discount_impact.csv
  top_cost_drivers.csv
  yoy_category_growth.csv
  segment_profitability.csv
  subcat_profit_ranking.csv
  quarterly_seasonality.csv
  ship_mode_profitability.csv
```

---

## Data Model

I load the raw Superstore CSV into `superstore_raw`, then transform it into a `transactions` table with derived financial fields:

| Field | Logic |
|---|---|
| `cost` | `sales - profit` |
| `budget_sales` | `sales * 1.05` (5% above actual as a budget benchmark) |
| `budget_cost` | `cost * 1.03` |

---

## Core Analysis (03_financial_analysis.sql)

### 1. Monthly Revenue, Cost & Gross Margin
Tracks monthly gross profit and margin over 4 years. Revenue peaks consistently in September and November each year, reaching $118K in November 2017 — the single highest month in the dataset.

### 2. Monthly Budget vs. Actual Variance
Since I set budget as actual × 1.05, actual always runs ~4.76% below budget. This is a useful baseline: in a real scenario I'd layer in true forecast figures, but this structure makes the budget variance queries easy to swap in.

### 3. Revenue Variance by Region
All four regions (West, East, Central, South) show the same ~-4.76% variance vs. budget, which is expected given the uniform budget assumption. The West leads in absolute revenue at $725K, followed by East at $679K.

### 4. Profitability by Category
Furniture stands out as a concern. Despite $742K in revenue — more than Office Supplies — its gross margin is only **2.49%**, compared to ~17% for both Technology and Office Supplies. I dug into this further in the sub-category analysis below.

### 5. Top Cost Drivers (Sub-Category)
Chairs and Phones together account for nearly **30% of total cost** ($301K and $285K respectively). Tables rank third at $225K — notable given they also generate negative profit.

### 6. Discount Impact on Profitability
This is one of the most striking findings. Orders with **no discount** have a 29.5% profit margin. That collapses to 11.6% at 10–20% discount, turns negative at 20–30% (-10%), and craters to **-48.2% at 30%+ discounts**. Heavy discounting is actively destroying value.

---

## Advanced Analysis (04_advanced_analysis.sql)

### 7. Year-over-Year Revenue & Profit Growth by Category

I used `LAG()` window functions partitioned by category to calculate YoY growth rates.

| Category | 2015 Rev Growth | 2016 Rev Growth | 2017 Rev Growth |
|---|---|---|---|
| Furniture | +8.5% | +16.7% | +8.3% |
| Office Supplies | -9.6% | +34.0% | +33.8% |
| Technology | -7.1% | +39.1% | +20.0% |

The standout is **Office Supplies and Technology both accelerating into 2016–2017**, while Furniture grew revenue but with wildly inconsistent profits (+130.8% in 2016, then -56.6% in 2017). Furniture's profit is too volatile relative to its revenue scale — a red flag I'd want to investigate with product-level detail.

### 8. Customer Segment Profitability

| Segment | Orders | Revenue | Profit Margin | Avg Order Value |
|---|---|---|---|---|
| Consumer | 2,586 | $1,161,401 | 11.55% | $449 |
| Corporate | 1,514 | $706,146 | 13.03% | $466 |
| Home Office | 909 | $429,653 | 14.03% | $473 |

Consumer is the largest segment by volume but the least profitable by margin. Home Office is the smallest segment yet generates the highest margin (14.03%) and the highest average order value ($473). If I were advising on go-to-market, I'd look hard at shifting more effort toward Home Office and Corporate customers.

### 9. Sub-Category Profit / Loss Ranking

The ranking reveals three sub-categories that are **net loss generators**:

| Sub-Category | Revenue | Profit | Margin |
|---|---|---|---|
| Tables | $206,966 | **-$17,725** | -8.6% |
| Bookcases | $114,880 | **-$3,473** | -3.0% |
| Supplies | $46,674 | **-$1,189** | -2.6% |

Tables in particular are a serious problem — $207K in revenue but losing $17.7K. Both Tables and Bookcases are Furniture sub-categories, which explains why Furniture's overall margin is so compressed despite strong revenue.

On the other end, **Copiers** (37.2% margin), **Paper** (43.4%), **Labels** (44.4%), and **Envelopes** (42.3%) are high-margin items well worth protecting from discounting.

### 10. Quarterly Seasonality

| Quarter | Revenue | Profit | Margin | % of Annual |
|---|---|---|---|---|
| Q1 | $359,682 | $48,024 | 13.35% | 15.7% |
| Q2 | $445,510 | $55,285 | 12.41% | 19.4% |
| Q3 | $613,932 | $72,467 | 11.80% | 26.7% |
| Q4 | $878,078 | $110,622 | 12.60% | 38.2% |

**Q4 accounts for 38% of annual revenue** — roughly 2.4× Q1. The business is heavily back-half loaded. Interestingly, Q1 actually has the *highest* profit margin (13.35%) even though it's the slowest quarter, suggesting less discounting pressure early in the year. Q3's margin dips slightly (11.8%), possibly due to mid-year promotions.

### 11. Shipping Mode Impact on Profitability

| Ship Mode | Orders | Revenue | Profit Margin | Avg Line Item |
|---|---|---|---|---|
| Standard Class | 2,994 | $1,358,216 | 12.08% | $228 |
| Second Class | 964 | $459,194 | 12.51% | $236 |
| First Class | 787 | $351,428 | **13.93%** | $229 |
| Same Day | 264 | $128,363 | 12.38% | $236 |

**First Class shipping correlates with the highest profit margin at 13.93%**, about 1.85 percentage points above Standard Class. This could mean First Class orders tend to be less discounted, or that customers who choose faster shipping are buying higher-margin products. Either way, it's worth investigating as a pricing signal.

---

## Key Takeaways

1. **Furniture is a margin problem.** Revenue is growing but profit is thin and volatile. Tables and Bookcases are actively losing money and should be reviewed for pricing or discontinuation.
2. **Discounting over 20% is deeply destructive.** The business should have guardrails — especially for Furniture sub-categories that are already loss-making.
3. **Home Office and Corporate segments punch above their weight** on margin and average order value. Consumer volume doesn't translate to proportionate profit.
4. **Q4 dependency is a real risk.** 38% of revenue in a single quarter creates significant forecasting and operational exposure. Q1 development should be a strategic priority.
5. **Copiers, Paper, Labels, and Envelopes are hidden margin champions** — small in absolute revenue but well worth protecting and cross-selling.

---

## How to Run

```sql
-- 1. Create tables
\i sql/01_create_tables.sql

-- 2. Load CSV into superstore_raw
\copy superstore_raw FROM 'data/superstore_clean.csv' CSV HEADER;

-- 3. Transform and insert into transactions
\i sql/02_transform_insert.sql

-- 4. Run core analysis
\i sql/03_financial_analysis.sql

-- 5. Run advanced analysis
\i sql/04_advanced_analysis.sql
```

Tested on PostgreSQL 15+.
