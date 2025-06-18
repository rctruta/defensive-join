-- setup.sql

-- Clean up previous runs
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;

-- Create the customers table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name TEXT,
    state VARCHAR(2)
);

-- Create the orders table
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT, -- We will add the NOT NULL constraint later
    order_total DECIMAL(10, 2)
);

-- Generate 1 Million Customers
INSERT INTO customers (customer_id, customer_name, state)
SELECT
    i,
    'Customer ' || i,
    (ARRAY['CA', 'NY', 'TX', 'FL', 'IL'])[floor(random() * 5 + 1)]
FROM generate_series(1, 1000000) AS i;

-- Generate 50 Million Orders, with most being valid
INSERT INTO orders (order_id, customer_id, order_total)
SELECT
    i,
    floor(random() * 1000000 + 1), -- Most IDs are valid (1 to 1,000,000)
    random() * 1000 + 10
FROM generate_series(1, 50000000) AS i;

-- **THE CRITICAL STEP: Create 50,000 Orphan Records**
-- These orders have customer_id values that do not exist in the customers table.
INSERT INTO orders (order_id, customer_id, order_total)
SELECT
    i,
    i + 1000000, -- Invalid IDs (1,000,001 to 1,050,000)
    random() * 500 + 5
FROM generate_series(50000001, 50050000) AS i;

-- Add a NOT NULL constraint for the clean state later
ALTER TABLE orders ALTER COLUMN customer_id SET NOT NULL;

-- Analyze tables for the optimizer
ANALYZE customers;
ANALYZE orders;

SELECT 'Setup Complete' AS status;