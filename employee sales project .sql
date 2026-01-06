-- SQL Schema for E-commerce Sales Data Analysis

-- Customers Table
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    registration_date DATE
);

-- Products Table
CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10, 2),
    stock_quantity INT
);

-- Orders Table
CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10, 2),
    status VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- Order_Details Table (Junction table for many-to-many relationship between Orders and Products)
CREATE TABLE Order_Details (
    order_detail_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10, 2),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- Inserting Sample Data

-- Customers
INSERT INTO Customers (customer_id, first_name, last_name, email, registration_date) VALUES
(1, 'Alice', 'Smith', 'alice.smith@example.com', '2023-01-15'),
(2, 'Bob', 'Johnson', 'bob.j@example.com', '2023-02-20'),
(3, 'Charlie', 'Brown', 'charlie.b@example.com', '2023-03-10'),
(4, 'Diana', 'Prince', 'diana.p@example.com', '2023-04-05'),
(5, 'Eve', 'Adams', 'eve.a@example.com', '2023-05-01');

-- Products
INSERT INTO Products (product_id, product_name, category, price, stock_quantity) VALUES
(101, 'Laptop Pro X', 'Electronics', 1200.00, 50),
(102, 'Wireless Mouse', 'Electronics', 25.00, 200),
(103, 'Mechanical Keyboard', 'Electronics', 80.00, 100),
(104, 'Desk Chair Ergonomic', 'Furniture', 250.00, 30),
(105, 'Coffee Mug Set', 'Home Goods', 15.00, 150),
(106, 'Smartphone Z', 'Electronics', 800.00, 75);

-- Orders
INSERT INTO Orders (order_id, customer_id, order_date, total_amount, status) VALUES
(1001, 1, '2023-06-01', 1225.00, 'Completed'),
(1002, 2, '2023-06-05', 80.00, 'Completed'),
(1003, 1, '2023-06-10', 895.00, 'Processing'),
(1004, 3, '2023-06-12', 250.00, 'Completed'),
(1005, 4, '2023-06-15', 15.00, 'Pending');

-- Order_Details
INSERT INTO Order_Details (order_detail_id, order_id, product_id, quantity, unit_price) VALUES
(1, 1001, 101, 1, 1200.00),
(2, 1001, 102, 1, 25.00),
(3, 1002, 103, 1, 80.00),
(4, 1003, 106, 1, 800.00),
(5, 1003, 103, 1, 80.00),
(6, 1003, 105, 1, 15.00),
(7, 1004, 104, 1, 250.00),
(8, 1005, 105, 1, 15.00);

-- Example Queries for Analysis

-- 1. Total Sales by Month
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
    SUM(total_amount) AS total_sales
FROM Orders
GROUP BY sales_month
ORDER BY sales_month;

-- 2. Top 5 Selling Products
SELECT
    p.product_name,
    SUM(od.quantity) AS total_quantity_sold,
    SUM(od.quantity * od.unit_price) AS total_revenue
FROM Order_Details od
JOIN Products p ON od.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_quantity_sold DESC
LIMIT 5;

-- 3. Customers with the Highest Total Spending
SELECT
    c.first_name,
    c.last_name,
    SUM(o.total_amount) AS total_spent
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC
LIMIT 5;

-- 4. Average Order Value
SELECT
    AVG(total_amount) AS average_order_value
FROM Orders;

-- 5. Products that are Low in Stock (e.g., less than 50 units)
SELECT
    product_name,
    stock_quantity
FROM Products
WHERE stock_quantity < 50
ORDER BY stock_quantity;

-- 6. Customers who have placed more than one order
SELECT
    c.first_name,
    c.last_name,
    COUNT(o.order_id) AS number_of_orders
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(o.order_id) > 1
ORDER BY number_of_orders DESC;

-- 7. Orders with their associated customer and product details
SELECT
    o.order_id,
    c.first_name AS customer_first_name,
    c.last_name AS customer_last_name,
    o.order_date,
    p.product_name,
    od.quantity,
    od.unit_price
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Order_Details od ON o.order_id = od.order_id
JOIN Products p ON od.product_id = p.product_id
ORDER BY o.order_id, p.product_name;