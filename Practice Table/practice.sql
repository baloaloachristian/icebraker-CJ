-- (Create the PRACTICE table first using the columns/types above, then:)
CREATE TABLE PRACTICE (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    city VARCHAR(50),
    region VARCHAR(50),
    signup_date DATE,
    total_orders INT,
    total_spent DECIMAL(10, 2)
);

INSERT INTO PRACTICE (first_name, last_name, email, city, region, signup_date, total_orders, total_spent)
VALUES
('Lily',  'Chua', 'lily.chua@email.com', 'Manila',      'NCR', '2025-01-05', 2, 5600),
('James', 'Lim',  'james.lim@email.com', 'Quezon City', 'NCR', '2025-02-15', 1, 850);

SELECT customer_name, product_name, total_amount, category
FROM sales
WHERE region = 'Visayas'
  AND total_amount < 5000
  AND category IN ('Accessories', 'Peripherals'); 

SELECT sale_date, customer_name, product_name, total_amount
FROM sales
WHERE sale_date BETWEEN '2025-04-01'
  AND sale_date < '2025-07-01'
ORDER BY sale_date DESC;

SELECT first_name, last_name, email, city
FROM customers
WHERE city NOT IN ('Manila', 'Makati', 'Pasig');

SELECT product_name, category, total_amount
FROM sales
WHERE product_name LIKE '%Pro';

SELECT first_name, last_name, total_spent
FROM customers
ORDER BY total_spent ASC, customer_id ASC
LIMIT 5;

SELECT category,
       COUNT(sale_id)      AS num_sales,
       AVG(total_amount)   AS avg_sale_amount
FROM sales
GROUP BY category
ORDER BY avg_sale_amount DESC;

SELECT region, SUM(total_amount) AS electronics_revenue
FROM sales
WHERE category = 'Electronics'      -- row filter BEFORE grouping
GROUP BY region
HAVING SUM(total_amount) > 100000;  -- group filter AFTER aggregating

SELECT c.first_name, c.last_name,
       COUNT(s.sale_id) AS purchase_count
FROM customers c
LEFT JOIN sales s
  ON s.customer_name = c.first_name || ' ' || c.last_name
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY purchase_count DESC;

SELECT item_name, quantity_on_hand,
    CASE
        WHEN quantity_on_hand = 0 THEN 'Out of Stock'
        WHEN quantity_on_hand <= 10 THEN 'Low Stock'
        ELSE 'In Stock'
    END AS stock_status
FROM inventory;

SELECT item_name,
       COALESCE(unit_cost, 0) AS unit_cost,
       COALESCE(unit_cost, 0) * quantity_on_hand AS inventory_value
FROM inventory;

-- Step 1: PREVIEW the affected rows before changing anything
SELECT item_name, unit_cost
FROM inventory
WHERE unit_cost >= 10000;

-- Step 2: Apply the update with the same WHERE
UPDATE inventory
SET unit_cost = unit_cost * 1.10
WHERE unit_cost >= 10000;

ALTER TABLE customers
ADD COLUMN membership_tier TEXT DEFAULT 'Standard';
