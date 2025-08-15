CREATE TABLE sales_data (
    region TEXT,
    country TEXT,
    item_type TEXT,
    sales_channel TEXT,
    order_priority TEXT,
    order_date DATE,
    order_id BIGINT,
    ship_date DATE,
    units_sold INT,
    unit_price DECIMAL(10,2),
    unit_cost DECIMAL(10,2),
    total_revenue DECIMAL(12,2),
    total_cost DECIMAL(12,2),
    total_profit DECIMAL(12,2)
);



--CREATE CATEGORIES TABLE
CREATE TABLE categories (
    item_type TEXT PRIMARY KEY,
    category_name TEXT NOT NULL
);

--CREATE LOCATIONS TABLE
CREATE TABLE locations (
    location_id SERIAL PRIMARY KEY,
    region TEXT NOT NULL,
    country TEXT NOT NULL
);

--CREATE CUSTOMERS TABLE
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    location_id INT REFERENCES locations(location_id)
);

--CREATE PRODUCTS TABLE
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    category_name TEXT NOT NULL,  
    product_name TEXT NOT NULL,
    unit_price DECIMAL(10,2),
    unit_cost DECIMAL(10,2)
);

--CREATE ORDERS TABLE
CREATE TABLE orders (
    order_id BIGINT PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    order_date DATE,
    ship_date DATE
);

--CREATE ORDER DETAILS TABLE
CREATE TABLE order_details (
    order_detail_id SERIAL PRIMARY KEY,
    order_id BIGINT REFERENCES orders(order_id),
    product_id INT REFERENCES products(product_id),
    quantity INT,
    unit_price DECIMAL(10,2),
    unit_cost DECIMAL(10,2)
);

--IMPORT CATEGORIES TABLE
INSERT INTO categories (item_type, category_name) VALUES
('Baby Food', 'Groceries'),
('Beverages', 'Groceries'),
('Cereal', 'Groceries'),
('Fruits', 'Groceries'),
('Meat', 'Groceries'),
('Vegetables', 'Groceries'),
('Clothes', 'Apparel'),
('Cosmetics', 'Personal Care Items'),
('Personal Care', 'Personal Care Items'),
('Household', 'Home Goods'),
('Office Supplies', 'Home Goods'),
('Snacks', 'Groceries');

--IMPORT LOCATIONS TABLE
INSERT INTO locations (region, country)
SELECT DISTINCT region, country
FROM sales_data;

--IMPORT CUSTOMERS TABLE
INSERT INTO customers (location_id)
SELECT DISTINCT l.location_id
FROM sales_data s
JOIN locations l
  ON s.region = l.region
 AND s.country = l.country;

--IMPORT PRODUCTS TABLE
INSERT INTO products (category_name, product_name, unit_price, unit_cost)
SELECT c.category_name,
       s.item_type AS product_name,
       ROUND(AVG(s.unit_price), 2),
       ROUND(AVG(s.unit_cost), 2)
FROM sales_data s
JOIN categories c
  ON s.item_type = c.item_type
GROUP BY c.category_name, s.item_type;

--IMPORT ORDERS TABLE
INSERT INTO orders (order_id, customer_id, order_date, ship_date)
SELECT DISTINCT s.order_id,
       cu.customer_id,
       s.order_date,
       s.ship_date
FROM sales_data s
JOIN locations l
  ON s.region = l.region
 AND s.country = l.country
JOIN customers cu
  ON cu.location_id = l.location_id;

--IMPORT ORDER DETAILS TABLE
INSERT INTO order_details (order_id, product_id, quantity, unit_price, unit_cost)
SELECT s.order_id,
       p.product_id,
       s.units_sold,
       s.unit_price,
       s.unit_cost
FROM sales_data s
JOIN products p
  ON s.item_type = p.product_name;


--BUSINESS QUESTIONS
--1. What is the total profit for each country?
SELECT country, 
       SUM(total_profit) AS total_profit
FROM sales_data
GROUP BY country
ORDER BY total_profit DESC;


--2. Which product sold the most units?
SELECT item_type, SUM(units_sold) AS total_units
FROM sales_data
GROUP BY item_type
ORDER BY total_units DESC
LIMIT 1;

--3. How many units were shipped to each country?
SELECT country, COUNT(order_id) AS total_orders
FROM sales_data
GROUP BY country
ORDER BY total_orders DESC;

--INDEXES
--Query 1:
CREATE INDEX country_profit ON sales_data(country, total_profit);

--Query 2: 
CREATE INDEX item_type ON sales_data(item_type);

--Query 3:
CREATE INDEX country_sales ON sales_data(country);


