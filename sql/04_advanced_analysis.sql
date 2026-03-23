-- ============================================================
-- Advanced Financial Analysis
-- ============================================================


-- 7) Year-over-Year Revenue & Profit Growth by Category

WITH yearly AS (
  SELECT
    EXTRACT(YEAR FROM order_date)::INT AS year,
    category,
    ROUND(SUM(sales), 2)  AS revenue,
    ROUND(SUM(profit), 2) AS profit
  FROM transactions
  GROUP BY 1, 2
)
SELECT
  year,
  category,
  revenue,
  profit,
  ROUND(
    (revenue - LAG(revenue) OVER (PARTITION BY category ORDER BY year))
    / NULLIF(LAG(revenue) OVER (PARTITION BY category ORDER BY year), 0) * 100, 2
  ) AS yoy_revenue_growth_pct,
  ROUND(
    (profit - LAG(profit) OVER (PARTITION BY category ORDER BY year))
    / NULLIF(LAG(profit) OVER (PARTITION BY category ORDER BY year), 0) * 100, 2
  ) AS yoy_profit_growth_pct
FROM yearly
ORDER BY category, year;


-- 8) Customer Segment Profitability

SELECT
  segment,
  COUNT(DISTINCT order_id)                                          AS orders,
  ROUND(SUM(sales), 2)                                             AS revenue,
  ROUND(SUM(cost), 2)                                              AS total_cost,
  ROUND(SUM(profit), 2)                                            AS gross_profit,
  ROUND((SUM(profit) / NULLIF(SUM(sales), 0)) * 100, 2)           AS profit_margin_pct,
  ROUND(SUM(sales) / NULLIF(COUNT(DISTINCT order_id), 0), 2)      AS avg_order_value
FROM transactions
GROUP BY segment
ORDER BY revenue DESC;


-- 9) Sub-Category Profit / Loss Ranking

SELECT
  sub_category,
  ROUND(SUM(sales), 2)                                          AS revenue,
  ROUND(SUM(cost), 2)                                           AS total_cost,
  ROUND(SUM(profit), 2)                                         AS profit,
  ROUND((SUM(profit) / NULLIF(SUM(sales), 0)) * 100, 2)        AS profit_margin_pct,
  RANK() OVER (ORDER BY SUM(profit) DESC)                       AS profit_rank
FROM transactions
GROUP BY sub_category
ORDER BY profit DESC;


-- 10) Quarterly Seasonality (aggregated across all years)

SELECT
  EXTRACT(QUARTER FROM order_date)::INT                                            AS quarter,
  ROUND(SUM(sales), 2)                                                             AS revenue,
  ROUND(SUM(profit), 2)                                                            AS profit,
  ROUND((SUM(profit) / NULLIF(SUM(sales), 0)) * 100, 2)                           AS profit_margin_pct,
  ROUND(SUM(sales) / (SELECT SUM(sales) FROM transactions) * 100, 2)              AS pct_of_annual_revenue
FROM transactions
GROUP BY 1
ORDER BY 1;


-- 11) Shipping Mode Impact on Profitability

SELECT
  ship_mode,
  COUNT(*)                                                        AS line_items,
  COUNT(DISTINCT order_id)                                        AS orders,
  ROUND(SUM(sales), 2)                                            AS revenue,
  ROUND(SUM(profit), 2)                                           AS profit,
  ROUND((SUM(profit) / NULLIF(SUM(sales), 0)) * 100, 2)          AS profit_margin_pct,
  ROUND(AVG(sales), 2)                                            AS avg_line_item_value
FROM superstore_raw
GROUP BY ship_mode
ORDER BY revenue DESC;
