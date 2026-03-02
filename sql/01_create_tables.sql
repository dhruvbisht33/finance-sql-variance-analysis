DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS superstore_raw;

CREATE TABLE superstore_raw (
  row_id INT,
  order_id TEXT,
  order_date TEXT,
  ship_date TEXT,
  ship_mode TEXT,
  customer_id TEXT,
  customer_name TEXT,
  segment TEXT,
  country TEXT,
  city TEXT,
  state TEXT,
  postal_code TEXT,
  region TEXT,
  product_id TEXT,
  category TEXT,
  sub_category TEXT,
  product_name TEXT,
  sales NUMERIC,
  quantity INT,
  discount NUMERIC,
  profit NUMERIC
);

CREATE TABLE transactions (
  order_id TEXT,
  order_date DATE,
  category TEXT,
  sub_category TEXT,
  region TEXT,
  segment TEXT,
  sales NUMERIC,
  profit NUMERIC,
  cost NUMERIC,
  budget_sales NUMERIC,
  budget_cost NUMERIC
);