# SQL Practice Exercises — Day 5

A standalone set of short exercises copied from `example.md`. Each item has a **task**, a collapsible **best-practice solution**, and the **expected output**. Tables used: `customers`, `inventory`, `sales` (from `Day05_practice.db`) and the new-signup batch in `Day05_new_customers.csv`.

> **Note on expected outputs:** Exercise 1 is verifiable against `Day05_new_customers.csv`. The `sales`/`inventory` exercises describe the correct *shape/logic* of the result, since the `.db` file is not included.

---

## 🏋️ Exercise 1 — `INSERT INTO`

**Task:** Only the NCR customers from `Day05_new_customers.csv` qualify for an early-access promo.

**Step 1 — Create the table first.** The `promo_signups` table does **not** exist yet, so you must create it before you can insert anything. Define it with these columns (figure out the `CREATE TABLE` statement yourself):

| column | suggested data type | hint |
|---|---|---|
| `first_name` | `TEXT` | short text |
| `last_name` | `TEXT` | short text |
| `email` | `TEXT` | short text |
| `city` | `TEXT` | short text |
| `region` | `TEXT` | short text |
| `signup_date` | `TEXT` (or `DATE`) | stored as `'YYYY-MM-DD'` |
| `total_orders` | `INTEGER` | whole number |
| `total_spent` | `REAL` (or `NUMERIC`) | money / decimal value |

**Step 2 — Insert the NCR customers.** Write an `INSERT` that adds **just the NCR new customers** into the `promo_signups` table you just created.

<details>
<summary><strong>Best-Practice Solution</strong></summary>

```sql
-- (Create the promo_signups table first using the columns/types above, then:)
INSERT INTO promo_signups (first_name, last_name, email, city, region, signup_date, total_orders, total_spent)
VALUES
('Lily',  'Chua', 'lily.chua@email.com', 'Manila',      'NCR', '2025-01-05', 2, 5600),
('James', 'Lim',  'james.lim@email.com', 'Quezon City', 'NCR', '2025-02-15', 1, 850);
```

*Best-practice note: explicit column list + a single multi-row insert.*
</details>

**Expected Output:** `promo_signups` gains exactly **2 rows** (Lily Chua, James Lim). Mark, Sarah, and Anne are excluded because they are not in NCR.

---

## 🏋️ Exercise 2 — `WHERE` (`AND` / `OR` / `IN`)

**Task:** The Visayas manager wants all transactions **under ₱5,000** that are **either** in the "Accessories" **or** "Peripherals" category.

<details>
<summary><strong>Best-Practice Solution</strong></summary>

```sql
SELECT customer_name, product_name, total_amount, category
FROM sales
WHERE region = 'Visayas'
  AND total_amount < 5000
  AND category IN ('Accessories', 'Peripherals');
```

*Best-practice note: when a column is compared against a list of allowed values, `IN (...)` is cleaner than `(category = 'Accessories' OR category = 'Peripherals')` — and remember to parenthesize OR logic if you do spell it out, so it doesn't break the `AND`.*
</details>

**Expected Output:** Low-value Visayas rows limited to the two named categories, e.g.:

| customer_name | product_name | total_amount | category |
|---|---|---|---|
| Mark Reyes | Wireless Mouse | 2500.0 | Accessories |

---

## 🏋️ Exercise 3 — `BETWEEN` / date ranges

**Task:** Finance needs **Q2 2025** (April–June) revenue, sorted newest first.

<details>
<summary><strong>Best-Practice Solution</strong></summary>

```sql
SELECT sale_date, customer_name, product_name, total_amount
FROM sales
WHERE sale_date >= '2025-04-01'
  AND sale_date < '2025-07-01'
ORDER BY sale_date DESC;
```

*Best-practice note: keep the half-open range (`< '2025-07-01'`) instead of `BETWEEN ... AND '2025-06-30'` so end-of-day timestamps are not lost.*
</details>

**Expected Output:** All sales dated `2025-04-01` through `2025-06-30`, most recent at the top.

---

## 🏋️ Exercise 4 — `IN` / `NOT IN`

**Task:** Marketing wants to **exclude** the metro cities and target everyone *else*. Return name, email, and city for all customers **not** in Manila, Makati, or Pasig.

<details>
<summary><strong>Best-Practice Solution</strong></summary>

```sql
SELECT first_name, last_name, email, city
FROM customers
WHERE city NOT IN ('Manila', 'Makati', 'Pasig');
```

*Best-practice note: `NOT IN` keeps the intent readable. ⚠️ Caveat — if `city` can be `NULL`, `NOT IN` returns no match for those rows; add `OR city IS NULL` if NULL cities should be included.*
</details>

**Expected Output:** Customers from all other cities (Cebu City, Davao City, Quezon City, Iloilo City, etc.).

---

## 🏋️ Exercise 5 — `LIKE`

**Task:** Find every product whose name **ends with** the word "Pro" (e.g. "Monitor Pro", "Mouse Pro").

<details>
<summary><strong>Best-Practice Solution</strong></summary>

```sql
SELECT product_name, category, total_amount
FROM sales
WHERE product_name LIKE '%Pro';
```

*Best-practice note: an "ends-with" search genuinely requires a leading wildcard, which cannot use a normal index. If this query runs often, the better long-term fix is a reversed-string index or a full-text index — call that out rather than pretending `%Pro` is index-friendly.*
</details>

**Expected Output:** All products whose name terminates in "Pro".

---

## 🏋️ Exercise 6 — `ORDER BY` and `LIMIT`

**Task:** Show the **5 lowest-spending** customers (the re-engagement list), with a stable tiebreaker.

<details>
<summary><strong>Best-Practice Solution</strong></summary>

```sql
SELECT first_name, last_name, total_spent
FROM customers
ORDER BY total_spent ASC, customer_id ASC
LIMIT 5;
```

*Best-practice note: adding `customer_id ASC` as a tiebreaker makes the result deterministic when two customers have identical `total_spent`.*
</details>

**Expected Output:** The 5 customers with the smallest `total_spent`, ascending.

---

## 🏋️ Exercise 7 — `GROUP BY`

**Task:** For each `category`, report the **number of sales** and the **average sale amount**, sorted by average descending.

<details>
<summary><strong>Best-Practice Solution</strong></summary>

```sql
SELECT category,
       COUNT(sale_id)      AS num_sales,
       AVG(total_amount)   AS avg_sale_amount
FROM sales
GROUP BY category
ORDER BY avg_sale_amount DESC;
```

*Best-practice note: alias every aggregate and group by the exact non-aggregated column you selected.*
</details>

**Expected Output:**

| category | num_sales | avg_sale_amount |
|---|---|---|
| Electronics | ... | (highest avg) |
| Peripherals | ... | ... |
| Accessories | ... | (lowest avg) |

---

## 🏋️ Exercise 8 — `HAVING`

**Task:** Find regions whose **total revenue exceeds ₱100,000**, but only count **Electronics** sales toward that total.

<details>
<summary><strong>Best-Practice Solution</strong></summary>

```sql
SELECT region, SUM(total_amount) AS electronics_revenue
FROM sales
WHERE category = 'Electronics'      -- row filter BEFORE grouping
GROUP BY region
HAVING SUM(total_amount) > 100000;  -- group filter AFTER aggregating
```

*Best-practice note: this exercise shows the division of labor — `WHERE` narrows to Electronics rows first, `HAVING` then filters the summed groups.*
</details>

**Expected Output:** Only regions whose Electronics-only revenue clears ₱100,000.

---

## 🏋️ Exercise 9 — `JOIN`

**Task:** List **all customers and their total number of sales**, including customers who have **never** purchased (show `0` for them).

<details>
<summary><strong>Best-Practice Solution</strong></summary>

```sql
SELECT c.first_name, c.last_name,
       COUNT(s.sale_id) AS purchase_count
FROM customers c
LEFT JOIN sales s
  ON s.customer_name = c.first_name || ' ' || c.last_name
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY purchase_count DESC;
```

*Best-practice note: a `LEFT JOIN` keeps non-purchasers; `COUNT(s.sale_id)` (not `COUNT(*)`) correctly yields `0` for them because it ignores NULLs.*
</details>

**Expected Output:** Every customer listed, with buyers showing their count and non-buyers showing `0`.

---

## 🏋️ Exercise 10 — `CASE WHEN`

**Task:** Bucket inventory by stock level: `quantity_on_hand = 0` → `'Out of Stock'`, `1–10` → `'Low Stock'`, otherwise `'In Stock'`.

<details>
<summary><strong>Best-Practice Solution</strong></summary>

```sql
SELECT item_name, quantity_on_hand,
    CASE
        WHEN quantity_on_hand = 0 THEN 'Out of Stock'
        WHEN quantity_on_hand <= 10 THEN 'Low Stock'
        ELSE 'In Stock'
    END AS stock_status
FROM inventory;
```

*Best-practice note: order branches so each later `WHEN` only needs its upper bound, and always include `ELSE`.*
</details>

**Expected Output:**

| item_name | quantity_on_hand | stock_status |
|---|---|---|
| New Product XYZ | 0 | Out of Stock |
| Webcam HD 1080p | 12 | In Stock |

---

## 🏋️ Exercise 11 — `COALESCE`

**Task:** Some inventory rows have a `NULL` `unit_cost`. Produce a report that shows `0` instead of `NULL`, and compute total inventory value (`unit_cost × quantity_on_hand`) safely.

<details>
<summary><strong>Best-Practice Solution</strong></summary>

```sql
SELECT item_name,
       COALESCE(unit_cost, 0) AS unit_cost,
       COALESCE(unit_cost, 0) * quantity_on_hand AS inventory_value
FROM inventory;
```

*Best-practice note: wrap the nullable column in `COALESCE` **before** arithmetic — `NULL * anything` is `NULL`, which would silently zero out the math otherwise.*
</details>

**Expected Output:** Every item shows a numeric `unit_cost` and a computed `inventory_value` (never `NULL`).

---

## 🏋️ Exercise 12 — `UPDATE` / `DELETE`

**Task:** Apply a 10% price increase to every **Premium** item (`unit_cost >= 10000`) — but first verify which rows you'll touch.

<details>
<summary><strong>Best-Practice Solution</strong></summary>

```sql
-- Step 1: PREVIEW the affected rows before changing anything
SELECT item_name, unit_cost
FROM inventory
WHERE unit_cost >= 10000;

-- Step 2: Apply the update with the same WHERE
UPDATE inventory
SET unit_cost = unit_cost * 1.10
WHERE unit_cost >= 10000;
```

*Best-practice note: the "preview SELECT first" habit is the single biggest safeguard against accidental mass updates.*
</details>

**Expected Output:** Only items costing ₱10,000+ have their `unit_cost` raised by 10%; all other rows are untouched.

---

## 🏋️ Exercise 13 — `ALTER TABLE`

**Task:** Add a `membership_tier` text column that defaults every existing customer to `'Standard'`.

<details>
<summary><strong>Best-Practice Solution</strong></summary>

```sql
ALTER TABLE customers
ADD COLUMN membership_tier TEXT DEFAULT 'Standard';
```

*Best-practice note: always give a new column a `DEFAULT` so historical rows are populated immediately rather than left `NULL`.*
</details>

**Expected Output:** A new `membership_tier` column appears on `customers`, with every existing row showing `'Standard'`.
