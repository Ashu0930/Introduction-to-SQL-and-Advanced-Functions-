-- Create Database And use it 

create database ECommerceDB;
use ECommerceDB;

-- Create Tables
create table Categories (
CategoryID INT PRIMARY KEY,
CategoryName VARCHAR(50) NOT NULL UNIQUE
);

create table Products(
ProductID INT PRIMARY KEY,
ProductName VARCHAR(100) NOT NULL UNIQUE,
CategoryID INT,
Price DECIMAL(10,2) NOT NULL,
StockQuantity INT,
foreign key (CategoryID) references Categories (CategoryID)
);

create table Customers(
CustomerID INT PRIMARY KEY,
CustomerName VARCHAR(100) NOT NULL,
Email VARCHAR(100) UNIQUE,
JoinDate DATE
);

create table Orders(
OrderID INT PRIMARY KEY,
CustomerID INT, 
OrderDate DATE NOT NULL,
TotalAmount DECIMAL(10,2),
FOREIGN KEY (CustomerID) references Customers (CustomerID)
);

-- Insert Values in table

insert into Categories(CategoryID , CategoryName ) Values
(1,'Electronics'),
(2,'Books'),
(3,'Home Goods'),
(4,'Apparel');

insert into Products (ProductID, ProductName, CategoryID, Price, StockQuantity)
Values
(101, 'Laptop Pro', 1, 1200.00, 50),
(102, 'SQL Handbook', 2, 45.50, 200),
(103, 'Smart Speaker', 1, 99.99, 150),
(104, 'Coffee Maker', 3, 75.00, 80),
(105, 'Novel: The Great SQL', 2, 25.00, 120),
(106, 'Wireless Earbuds', 1, 150.00, 100),
(107, 'Blender X', 3, 120.00, 60),
(108, 'T-Shirt Casual', 4, 20.00, 300);

insert into Customers (CustomerID, CustomerName, Email, JoinDate)
Values
(1, 'Alice Wonderland', 'alice@example.com', '2023-01-10'),
(2, 'Bob the Builder', 'bob@example.com', '2022-11-25'),
(3, 'Charlie Chaplin', 'charlie@example.com', '2023-03-01'),
(4, 'Diana Prince', 'diana@example.com', '2021-04-26');

insert into Orders (OrderID, CustomerID, OrderDate, TotalAmount)
values
(1001, 1, '2023-04-26', 1245.50),
(1002, 2, '2023-10-12', 99.99),
(1003, 1, '2023-07-01', 145.00),
(1004, 3, '2023-01-14', 150.00),
(1005, 2, '2023-09-24', 120.00),
(1006, 1, '2023-06-19', 20.00);

/* Generate a report showing CustomerName, Email, and the
 TotalNumberofOrders for each customer. Include customers who have not placed
 any orders, in which case their TotalNumberofOrders should be 0. Order the results
 by CustomerName. */

SELECT 
    c.CustomerName,
    c.Email,
    COUNT(o.OrderID) AS TotalNumberofOrders
FROM 
    Customers c
LEFT JOIN 
    Orders o ON c.CustomerID = o.CustomerID
GROUP BY 
    c.CustomerID, c.CustomerName, c.Email
ORDER BY 
    c.CustomerName;
    
/*  Retrieve Product Information with Category: Write a SQL query to
display the ProductName, Price, StockQuantity, and CategoryName for all
products. Order the results by CategoryName and then ProductName alphabetically */

SELECT 
    p.ProductName,
    p.Price,
    p.StockQuantity,
    c.CategoryName
FROM 
    Products p
INNER JOIN 
    Categories c ON p.CategoryID = c.CategoryID
ORDER BY 
    c.CategoryName ASC,
    p.ProductName ASC;
    
/*Write a SQL query that uses a Common Table Expression (CTE) and a
Window Function (specifically ROW_NUMBER() or RANK()) to display the
CategoryName, ProductName, and Price for the top 2 most expensive products in
each CategoryName.*/

WITH RankedProducts AS (
    SELECT 
        c.CategoryName,
        p.ProductName,
        p.Price,
        ROW_NUMBER() OVER (
            PARTITION BY c.CategoryName
            ORDER BY p.Price DESC
        ) AS rn
    FROM 
        Products p
    INNER JOIN 
        Categories c ON p.CategoryID = c.CategoryID
)
SELECT 
    CategoryName,
    ProductName,
    Price
FROM 
    RankedProducts
WHERE 
    rn <= 2
ORDER BY 
    CategoryName,
    Price DESC;

/* You are hired as a data analyst by Sakila Video Rentals, a global movie
rental company. The management team is looking to improve decision-making by
analyzing existing customer, rental, and inventory data.
Using the Sakila database, answer the following business questions to support key strategic
initiatives.*/

-- Top 5 Customers Based on Total Amount Spent
-- Use Sakila DB

SELECT 
    c.first_name AS FirstName,
    c.last_name AS LastName,
    c.email,
    SUM(p.amount) AS TotalAmountSpent
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id
ORDER BY TotalAmountSpent DESC
LIMIT 5;


-- Top 3 Categories with the Highest Number of Products

SELECT 
    cat.name AS CategoryName,
    COUNT(r.rental_id) AS RentalCount
FROM category cat
JOIN film_category fc ON cat.category_id = fc.category_id
JOIN inventory i ON fc.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY cat.category_id
ORDER BY RentalCount DESC
LIMIT 3;


-- Count of Products in Each Category AND Products That Are Out of Stock

			-- Total products per category
SELECT 
    s.store_id,
    COUNT(i.inventory_id) AS TotalFilms
FROM store s
JOIN inventory i ON s.store_id = i.store_id
GROUP BY s.store_id;


			-- Products that were NEVER in stock (Stock = 0)

SELECT 
    s.store_id,
    COUNT(i.inventory_id) AS NeverRentedFilms
FROM store s
JOIN inventory i ON s.store_id = i.store_id
LEFT JOIN rental r ON i.inventory_id = r.inventory_id
WHERE r.rental_id IS NULL
GROUP BY s.store_id;


-- Total Revenue per Month for the Year 2023 (From Orders Table)

SELECT 
    DATE_FORMAT(p.payment_date, '%Y-%m') AS Month,
    SUM(p.amount) AS TotalRevenue
FROM payment p
WHERE YEAR(p.payment_date) = 2023
GROUP BY DATE_FORMAT(p.payment_date, '%Y-%m')
ORDER BY Month;


-- Customers Who Placed More Than 10 Orders in the Last 6 Months

SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(r.rental_id) AS RentalCount
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
WHERE r.rental_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY c.customer_id
HAVING COUNT(r.rental_id) > 10
ORDER BY RentalCount DESC;




