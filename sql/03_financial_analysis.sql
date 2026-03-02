 
-- 1) Monthly Revenue, Cost, Gross Profit, Gross Margin
 

SELECT
  DATE_TRUNC('month', order_date)::date AS month,
  ROUND(SUM(sales), 2) AS revenue,
  ROUND(SUM(cost), 2) AS total_cost,
  ROUND(SUM(sales - cost), 2) AS gross_profit,
  ROUND((SUM(sales - cost) / NULLIF(SUM(sales),0)) * 100, 2) AS gross_margin_pct
FROM transactions
GROUP BY 1
ORDER BY 1;


 
-- 2) Monthly Budget vs Actual Variance (Revenue + Cost)
 

SELECT
  DATE_TRUNC('month', order_date)::date AS month,
  ROUND(SUM(sales), 2) AS actual_revenue,
  ROUND(SUM(budget_sales), 2) AS budget_revenue,
  ROUND(SUM(sales - budget_sales), 2) AS revenue_variance,
  ROUND(SUM(cost), 2) AS actual_cost,
  ROUND(SUM(budget_cost), 2) AS budget_cost,
  ROUND(SUM(cost - budget_cost), 2) AS cost_variance
FROM transactions
GROUP BY 1
ORDER BY 1;


 
-- 3) Revenue Variance by Region
 

SELECT
  region,
  ROUND(SUM(sales), 2) AS actual_revenue,
  ROUND(SUM(budget_sales), 2) AS budget_revenue,
  ROUND(SUM(sales - budget_sales), 2) AS revenue_variance,
  ROUND((SUM(sales - budget_sales) / NULLIF(SUM(budget_sales),0)) * 100, 2) AS variance_pct
FROM transactions
GROUP BY region
ORDER BY variance_pct;


 
-- 4) Profitability by Category (Margin Analysis)
 

SELECT
  category,
  ROUND(SUM(sales), 2) AS revenue,
  ROUND(SUM(cost), 2) AS total_cost,
  ROUND(SUM(sales - cost), 2) AS gross_profit,
  ROUND((SUM(sales - cost) / NULLIF(SUM(sales),0)) * 100, 2) AS gross_margin_pct
FROM transactions
GROUP BY category
ORDER BY gross_margin_pct DESC;



-- 5) Top Cost Drivers (Sub-Category)


SELECT
  sub_category,
  ROUND(SUM(cost), 2) AS total_cost,
  ROUND((SUM(cost) / (SELECT SUM(cost) FROM transactions)) * 100, 2) AS pct_of_total_cost
FROM transactions
GROUP BY sub_category
ORDER BY total_cost DESC
LIMIT 10;



-- 6) Discount Impact on Profitability


SELECT
  CASE
    WHEN discount = 0 THEN '0%'
    WHEN discount <= 0.1 THEN '0–10%'
    WHEN discount <= 0.2 THEN '10–20%'
    WHEN discount <= 0.3 THEN '20–30%'
    ELSE '30%+'
  END AS discount_bucket,
  COUNT(*) AS orders,
  ROUND(SUM(sales), 2) AS revenue,
  ROUND(SUM(profit), 2) AS profit,
  ROUND((SUM(profit) / NULLIF(SUM(sales),0)) * 100, 2) AS profit_margin_pct
FROM superstore_raw
GROUP BY 1
ORDER BY orders DESC;