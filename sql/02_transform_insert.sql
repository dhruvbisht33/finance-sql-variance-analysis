TRUNCATE transactions;

INSERT INTO transactions (
  order_id, order_date, category, sub_category, region, segment,
  sales, profit, cost, budget_sales, budget_cost
)
SELECT
  order_id,
  TO_DATE(order_date, 'MM/DD/YYYY') AS order_date,
  category,
  sub_category,
  region,
  segment,
  sales,
  profit,
  (sales - profit) AS cost,
  (sales * 1.05) AS budget_sales,
  ((sales - profit) * 1.03) AS budget_cost
FROM superstore_raw;