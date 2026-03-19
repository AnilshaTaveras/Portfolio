/* 9.10E Consider the following relational model:

COURSE(coursenr, coursename, profnr) – profnr is a foreign key referring to profnr in PROFESSOR
PROFESSOR(profnr, profname)
PRE-REQUISITE(coursenr, pre-req-coursenr) – coursenr is a foreign key referring to coursenr in COURSE; 
pre-req-coursenr is a foreign key referring to coursenr in COURSE

The PRE-REQUISITE relation essentially models a recursive N:M relationship type for COURSE,
since a course can have multiple prerequisite courses and a course can be a prerequisite for multiple other courses.
Write a recursive SQL query to list all prerequisite courses for the course “Principles of Database Management”. */

WITH RECURSIVE pre_reqs AS (
    SELECT pr.pre-req-coursenr, c.coursename
    FROM PRE-REQUISITE pr
    JOIN COURSE c 
        ON pr.pre-req-coursenr = c.coursenr
    WHERE c.coursename = 'Principles of Database Management'
    UNION ALL
    SELECT pr.pre-req-coursenr, c.coursename
    FROM PRE-REQUISITE pr
    JOIN COURSE c 
        ON pr.pre-req-coursenr = c.coursenr
    JOIN pre_reqs p 
        ON pr.coursenr = p.prereq_coursenr
    )
SELECT * FROM pre_reqs;


/* Problem 2. Using the "employees" table in the database (schema) “classicmodels” on server xxxxx, create a recursive query to find all subordinates of a given employee. 
Note that "with subordinates" should be replaced with "with recursive subordinates" in MySQL.
The output should contain five columns: "employeeNumber", "lastName", "firstName", "manager", "level". */

WITH RECURSIVE Subordinates AS (
    SELECT employeeNumber, lastName, firstName, reportsTo AS manager, 1 AS level
    FROM employees
    WHERE reportsTo IS NULL -- Assuming we start with the top-level manager
    UNION ALL
    SELECT e.employeeNumber, e.lastName, e.firstName, e.reportsTo, s.level + 1
    FROM employees e
    INNER JOIN Subordinates s ON e.reportsTo = s.employeeNumber
    )
SELECT * FROM Subordinates;

/* Problem 3. Using the database (schema) “classicmodels”, create a SQL query that retrieves "customernumber","customername", "total # of shipped orders" for
all customers except the customer(s) with the least number of orders. */

SELECT c.customerNumber, c.customerName, COUNT(o.orderNumber) AS totalOrders
FROM customers c
JOIN orders o ON c.customerNumber = o.customerNumber
WHERE o.status = 'Shipped'
GROUP BY c.customerNumber, c.customerName
HAVING COUNT(orderNumber) > (
    SELECT MIN(totalOrders)
    FROM (
        SELECT COUNT(orderNumber) AS totalOrders
        FROM orders
        WHERE status = 'Shipped'
        GROUP BY customerNumber
        ) AS subquery
);

/* Problem 4. Using the database (schema) “classicmodels”, create a view that returns customer number, customer name, total order value (i.e., dollar amount.
Note only to count the shipped orders) for all customers. Then use the view to retrieve the top 5 customers with the highest total order value. */

CREATE VIEW CustomerOrderValue AS ( 
    SELECT c.customerNumber, c.customerName, SUM(od.quantityOrdered * od.priceEach) AS totalOrderValue
    FROM customers c
    JOIN orders o ON c.customerNumber = o.customerNumber
    JOIN orderdetails od ON o.orderNumber = od.orderNumber
    WHERE o.status = 'Shipped'
    GROUP BY c.customerNumber, c.customerName
    )
ORDER BY totalOrderValue DESC
LIMIT 5;

/* Problem 5. Using the database (schema) “classicmodels”, create a SQL query that retrieves the productCode and totalProfit of top 5 products with the highest
total profit value. For each product, it has buy price (buyPrice in product table) and sell price (priceEach in orderdetails table). Use these two to calculate profit. Sort the results by
totalProfit decreasing. */

SELECT p.productCode, SUM((od.priceEach - p.buyPrice) * od.quantityOrdered) AS totalProfit
FROM products p
JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY p.productCode
ORDER BY totalProfit DESC
LIMIT 5;

/* Problem 6. Using the database (schema) “classicmodels” to solve the following questions:
1. Create a stored procedure called ‘customers_details’ retrieving customers table.
2. Create a stored procedure called ‘In_process_order’ retrieving customerNumber, customerName, phone of the customers with status ‘In_process’.
3. Create a stored procedure called ‘office_insert’ inserting new tuple into office table,
providing officeCode and city. */

DELIMITER //
-- Stored Procedure: customers_details
CREATE PROCEDURE customers_details() AS
BEGIN
    SELECT * FROM customers;
END //

-- Stored Procedure: In_process_order
CREATE PROCEDURE In_process_order() AS
BEGIN
    SELECT
    c.customerNumber, c.customerName, c.phone
    FROM
    customers c
    JOIN
    orders o ON c.customerNumber = o.customerNumber
    WHERE
    o.status = 'In Process';
END //

-- Stored Procedure: office_insert
CREATE PROCEDURE office_insert(p_officeCode IN VARCHAR(10), p_city IN VARCHAR(50)) AS
BEGIN
    INSERT INTO offices (officeCode, city)
    VALUES (p_officeCode, p_city);
END //
DELIMITER ;

-- Testing Stored Procedures
CALL customers_details();
CALL In_process_order();
CALL office_insert('8', 'New City');