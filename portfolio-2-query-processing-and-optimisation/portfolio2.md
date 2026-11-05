# Portfolio 2: Query Processing and Optimisation

## Heywizzle Limited – E-commerce Database Management System

**Student:** Adedayo Ayodele  
**Matric Number:** 2026/A/MIT/0422  
**Course:** Advanced Database System (MIT 8103)

**Project:** Heywizzle Limited – E-commerce Database Management System  


---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Aim and Objectives](#2-aim-and-objectives)
3. [Database Environment and Scope](#3-database-environment-and-scope)
4. [SQL Data Manipulation Operations](#4-sql-data-manipulation-operations)
5. [Retrieving Data Using SQL Queries](#5-retrieving-data-using-sql-queries)
6. [Queries Involving Multiple Tables (JOIN)](#6-queries-involving-multiple-tables-join)
7. [Aggregate Functions and Grouping](#7-aggregate-functions-and-grouping)
8. [Subqueries](#8-subqueries)
9. [Database Views](#9-database-views)
10. [Query Execution Plan Analysis](#10-query-execution-plan-analysis)
11. [Indexing Techniques](#11-indexing-techniques)
12. [Query Optimisation Techniques](#12-query-optimisation-techniques)
13. [Performance Evaluation](#13-performance-evaluation)
14. [Conclusion](#14-conclusion)

---

## 1. Introduction

Query processing and optimisation are important aspects of database management systems. They determine how database queries are written, interpreted, executed, and improved to ensure efficient data retrieval and manipulation.

Heywizzle Limited operates an e-commerce platform that manages products, customers, orders, payments, inventory, and deliveries. As the volume of business transactions increases, the database must be capable of retrieving information efficiently while maintaining data accuracy and consistency.

This portfolio examines the application of SQL query processing and optimisation techniques using the relational database design developed in Portfolio 1.

The implementation uses MySQL to demonstrate data manipulation operations, data retrieval, table joins, aggregate functions, subqueries, database views, execution plan analysis, indexing, and query optimisation.

The objective is to demonstrate how well-structured SQL queries and appropriate indexing techniques can improve database performance and support the operational requirements of Heywizzle Limited.

## 2. Aim and Objectives

### 2.1 Aim

To examine and implement SQL query processing and optimisation techniques that improve the performance, efficiency, and reliability of the Heywizzle Limited database management system.

### 2.2 Objectives

The objectives of this portfolio are to:

- Write SQL queries to insert, retrieve, update, and delete database records.
- Retrieve information from multiple tables using JOIN operations.
- Apply aggregate functions such as COUNT, SUM, AVG, MIN, and MAX.
- Implement subqueries to retrieve records based on specified conditions.
- Create database views to simplify frequently executed queries.
- Analyse query execution plans using EXPLAIN and EXPLAIN ANALYZE.
- Apply indexing techniques to improve data retrieval performance.
- Identify inefficient SQL queries and implement optimisation techniques.
- Examine how query optimisation improves database performance.

## 3. Database Environment and Scope

### 3.1 Database Environment

The portfolio uses the following database environment:

| Component | Technology |
|---|---|
| Database Management System | MySQL 8.0 |
| Storage Engine | InnoDB |
| Query Language | Structured Query Language (SQL) |
| Database Model | Relational Database Model |
| Query Analysis | EXPLAIN and EXPLAIN ANALYZE |
| Indexing | Primary, Unique, Single-column and Composite Indexes |

### 3.2 Database Name

The database will be named:

```sql
CREATE DATABASE heywizzle_db;

USE heywizzle_db;
```

The database structure follows the entities and relationships established in Portfolio 1.

The major tables used in this portfolio include:

| Table | Purpose |
|---|---|
| customer | Stores customer information |
| customer_address | Stores customer delivery addresses |
| category | Stores product categories |
| product | Stores product information |
| attribute_definition | Defines product attributes |
| product_attribute_value | Stores product attribute values |
| inventory | Stores product stock information |
| customer_order | Stores customer order records |
| order_item | Stores individual products within orders |
| payment | Stores payment transaction records |
| delivery | Stores delivery and shipment information |

**Implementation assumption:** The tables and relationships have already been created based on Portfolio 1. The examples below assume that primary keys are automatically generated and that the appropriate foreign key constraints have been established.

## 4. SQL Data Manipulation Operations

Data Manipulation Language (DML) consists of SQL commands used to insert, retrieve, update, and delete records in database tables.

The major DML operations demonstrated in this section are INSERT, SELECT, UPDATE, and DELETE.

### 4.1 Inserting Records (INSERT)

The INSERT statement is used to add new records to database tables.

**Example 1: Adding a new product category**

```sql
INSERT INTO category (
    category_name,
    description
)
VALUES (
    'Electronics',
    'Electronic devices and accessories'
);
```

**Example 2: Registering a new customer**

```sql
INSERT INTO customer (
    first_name,
    last_name,
    email,
    phone,
    password_hash,
    created_at,
    account_status
)
VALUES (
    'John',
    'Ade',
    'john.ade@example.com',
    '08012345678',
    'sample_hashed_password',
    NOW(),
    'active'
);
```

**Example 3: Adding a new product**

```sql
INSERT INTO product (
    category_id,
    product_name,
    description,
    sku,
    price,
    is_active,
    created_at,
    updated_at
)
SELECT
    category_id,
    'Wireless Bluetooth Headphones',
    'Wireless headphones with Bluetooth connectivity',
    'HWZ-ELEC-001',
    45000.00,
    TRUE,
    NOW(),
    NOW()
FROM category
WHERE category_name = 'Electronics';
```

**Example 4: Recording product inventory**

```sql
INSERT INTO inventory (
    product_id,
    quantity_on_hand,
    reorder_level,
    last_updated
)
SELECT
    product_id,
    100,
    10,
    NOW()
FROM product
WHERE sku = 'HWZ-ELEC-001';
```

These operations demonstrate how new business records can be added while maintaining the relationships between database tables.

### 4.2 Retrieving Records (SELECT)

The SELECT statement retrieves information stored in database tables.

**Example 1: Retrieve all products**

```sql
SELECT *
FROM product;
```

**Example 2: Retrieve active products**

```sql
SELECT
    product_id,
    product_name,
    sku,
    price
FROM product
WHERE is_active = TRUE;
```

**Example 3: Retrieve products within a specified price range**

```sql
SELECT
    product_name,
    sku,
    price
FROM product
WHERE price BETWEEN 10000 AND 100000
ORDER BY price ASC;
```

**Example 4: Retrieve products with low stock**

```sql
SELECT
    p.product_name,
    p.sku,
    i.quantity_on_hand,
    i.reorder_level
FROM product p
INNER JOIN inventory i
    ON p.product_id = i.product_id
WHERE i.quantity_on_hand <= i.reorder_level;
```

### 4.3 Updating Records (UPDATE)

The UPDATE statement modifies existing records in a database table.

**Example 1: Updating a product price**

```sql
UPDATE product
SET
    price = 42000.00,
    updated_at = NOW()
WHERE sku = 'HWZ-ELEC-001';
```

**Example 2: Updating inventory quantities**

```sql
UPDATE inventory
SET
    quantity_on_hand = 150,
    last_updated = NOW()
WHERE product_id = (
    SELECT product_id
    FROM product
    WHERE sku = 'HWZ-ELEC-001'
);
```

**Example 3: Updating an order status**

```sql
UPDATE customer_order
SET order_status = 'processing'
WHERE order_reference = 'HWZ-ORD-0001';
```

**Important:** UPDATE statements should include appropriate WHERE conditions to avoid unintentionally modifying every record in a table.

### 4.4 Deleting Records (DELETE)

The DELETE statement removes existing records from database tables.

**Example 1: Removing an unused product attribute value**

```sql
DELETE FROM product_attribute_value
WHERE product_attribute_value_id = 10;
```

**Example 2: Removing an unused customer address**

```sql
DELETE FROM customer_address
WHERE address_id = 15
AND NOT EXISTS (
    SELECT 1
    FROM customer_order
    WHERE customer_order.shipping_address_id =
          customer_address.address_id
);
```

**Example 3: Deactivating a product**

For products that have existing order records, deactivation is preferable to physical deletion.

```sql
UPDATE product
SET
    is_active = FALSE,
    updated_at = NOW()
WHERE sku = 'HWZ-ELEC-001';
```

This approach helps preserve historical transaction records.

## 5. Retrieving Data Using SQL Queries

This section demonstrates how SQL queries can retrieve specific business information from the Heywizzle database.

### 5.1 Retrieving Customers

```sql
SELECT
    customer_id,
    first_name,
    last_name,
    email,
    phone,
    account_status
FROM customer
ORDER BY created_at DESC;
```

**Purpose:** Retrieves customer records, displaying the most recently registered customers first.

### 5.2 Retrieving Available Products

```sql
SELECT
    product_id,
    product_name,
    description,
    price
FROM product
WHERE is_active = TRUE
ORDER BY product_name ASC;
```

**Purpose:** Retrieves all active products available for sale.

### 5.3 Retrieving Pending Orders

```sql
SELECT
    order_reference,
    customer_id,
    order_date,
    total_amount,
    order_status
FROM customer_order
WHERE order_status = 'pending'
ORDER BY order_date DESC;
```

**Purpose:** Helps order management personnel identify orders awaiting processing.

### 5.4 Retrieving Successful Payments

```sql
SELECT
    payment_reference,
    order_id,
    payment_method,
    amount,
    payment_date
FROM payment
WHERE payment_status = 'successful'
ORDER BY payment_date DESC;
```

**Purpose:** Retrieves successfully processed payment transactions for financial monitoring.

## 6. Queries Involving Multiple Tables (JOIN)

JOIN operations allow information from multiple related database tables to be retrieved through their relationships.

The Heywizzle database uses foreign keys to establish these relationships.

### 6.1 INNER JOIN

An INNER JOIN returns records that have matching values in both tables.

**Example: Retrieve products with their categories**

```sql
SELECT
    p.product_id,
    p.product_name,
    p.sku,
    p.price,
    c.category_name
FROM product p
INNER JOIN category c
    ON p.category_id = c.category_id;
```

**Purpose:** Displays products alongside their respective categories.

### 6.2 LEFT JOIN

A LEFT JOIN returns all records from the left table and matching records from the right table. Where no match exists, NULL values are returned.

**Example: Retrieve all products and their inventory records**

```sql
SELECT
    p.product_name,
    p.sku,
    i.quantity_on_hand,
    i.reorder_level
FROM product p
LEFT JOIN inventory i
    ON p.product_id = i.product_id;
```

**Purpose:** Retrieves all products, including products that do not yet have an inventory record.

### 6.3 Multiple Table JOIN

Multiple JOIN operations can be used to retrieve information from several related tables.

**Example: Retrieve complete customer order information**

```sql
SELECT
    co.order_reference,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    oi.line_total,
    co.order_date,
    co.order_status
FROM customer_order co
INNER JOIN customer c
    ON co.customer_id = c.customer_id
INNER JOIN order_item oi
    ON co.order_id = oi.order_id
INNER JOIN product p
    ON oi.product_id = p.product_id
ORDER BY co.order_date DESC;
```

**Purpose:** Provides a detailed view of customer purchases, including customer information, products purchased, quantities, prices, and order statuses.

### 6.4 Joining Orders and Payments

```sql
SELECT
    co.order_reference,
    co.total_amount AS order_amount,
    py.payment_reference,
    py.payment_method,
    py.amount AS payment_amount,
    py.payment_status,
    py.payment_date
FROM customer_order co
LEFT JOIN payment py
    ON co.order_id = py.order_id
ORDER BY co.order_date DESC;
```

**Purpose:** Allows finance personnel to monitor payments associated with customer orders, including orders without payment records.

### 6.5 Joining Orders and Deliveries

```sql
SELECT
    co.order_reference,
    co.order_status,
    d.tracking_reference,
    d.delivery_person,
    d.expected_delivery_date,
    d.actual_delivery_date,
    d.delivery_status
FROM customer_order co
LEFT JOIN delivery d
    ON co.order_id = d.order_id
ORDER BY co.order_date DESC;
```

**Purpose:** Enables order management personnel to monitor the delivery progress of customer orders.

## 7. Aggregate Functions and Grouping

Aggregate functions perform calculations on multiple records and return a single result or a result for each group.

The major aggregate functions used in this portfolio include:

- COUNT(): Counts the number of records.
- SUM(): Calculates the total of numeric values.
- AVG(): Calculates the average value.
- MIN(): Returns the smallest value.
- MAX(): Returns the largest value.

### 7.1 COUNT Function

**Example: Count the total number of registered customers**

```sql
SELECT
    COUNT(*) AS total_customers
FROM customer;
```

**Purpose:** Determines the total number of customers registered on the platform.

### 7.2 SUM Function

**Example: Calculate total successful payments**

```sql
SELECT
    SUM(amount) AS total_payments
FROM payment
WHERE payment_status = 'successful';
```

**Purpose:** Calculates the total value of successfully processed payments.

### 7.3 AVG Function

**Example: Calculate the average product price**

```sql
SELECT
    AVG(price) AS average_product_price
FROM product
WHERE is_active = TRUE;
```

**Purpose:** Determines the average selling price of active products.

### 7.4 MIN and MAX Functions

**Example: Retrieve the cheapest and most expensive products**

```sql
SELECT
    MIN(price) AS lowest_product_price,
    MAX(price) AS highest_product_price
FROM product
WHERE is_active = TRUE;
```

**Purpose:** Identifies the minimum and maximum selling prices within the product catalogue.

### 7.5 GROUP BY

The GROUP BY clause groups records based on one or more columns.

**Example: Count products in each category**

```sql
SELECT
    c.category_name,
    COUNT(p.product_id) AS total_products
FROM category c
LEFT JOIN product p
    ON c.category_id = p.category_id
GROUP BY
    c.category_id,
    c.category_name
ORDER BY total_products DESC;
```

**Purpose:** Provides an overview of the number of products available in each category.

### 7.6 HAVING Clause

The HAVING clause filters grouped results based on aggregate conditions.

**Example: Identify customers who have placed more than three orders**

```sql
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(co.order_id) AS total_orders
FROM customer c
INNER JOIN customer_order co
    ON c.customer_id = co.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
HAVING COUNT(co.order_id) > 3;
```

**Purpose:** Identifies frequent customers who have placed more than three orders.

### 7.7 Sales Summary

**Example: Calculate total successful sales by order date**

```sql
SELECT
    DATE(co.order_date) AS sales_date,
    COUNT(DISTINCT co.order_id) AS total_orders,
    SUM(py.amount) AS total_sales
FROM customer_order co
INNER JOIN payment py
    ON co.order_id = py.order_id
WHERE py.payment_status = 'successful'
GROUP BY DATE(co.order_date)
ORDER BY sales_date DESC;
```

**Purpose:** Generates a daily sales summary based on successful payment transactions.

**Note:** Where an order has multiple successful payment records, the query sums all successful payments. This measures collected payment amounts rather than necessarily the original order value.

## 8. Subqueries

A subquery is a query nested inside another SQL query. It allows one query to use the result returned by another query.

Subqueries can be used in SELECT, FROM, and WHERE clauses.

### 8.1 Subquery Using WHERE

**Example: Retrieve products with prices above the average product price**

```sql
SELECT
    product_name,
    price
FROM product
WHERE price > (
    SELECT AVG(price)
    FROM product
    WHERE is_active = TRUE
)
AND is_active = TRUE
ORDER BY price DESC;
```

**Purpose:** Identifies active products whose prices are higher than the average price of all active products.

### 8.2 Subquery Using IN

**Example: Retrieve customers who have successfully paid for an order**

```sql
SELECT
    customer_id,
    first_name,
    last_name,
    email
FROM customer
WHERE customer_id IN (
    SELECT customer_id
    FROM customer_order
    WHERE order_id IN (
        SELECT order_id
        FROM payment
        WHERE payment_status = 'successful'
    )
);
```

**Purpose:** Identifies customers who have at least one order associated with a successful payment.

### 8.3 Correlated Subquery

A correlated subquery references a column from the outer query.

**Example: Retrieve customers who have placed at least one order**

```sql
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email
FROM customer c
WHERE EXISTS (
    SELECT 1
    FROM customer_order co
    WHERE co.customer_id = c.customer_id
);
```

**Purpose:** Identifies customers who have placed at least one order.

The EXISTS operator checks whether the subquery returns at least one matching record.

### 8.4 Subquery Using FROM

**Example: Calculate the average number of orders per customer who has placed an order**

```sql
SELECT
    AVG(customer_order_count) AS average_orders_per_customer
FROM (
    SELECT
        customer_id,
        COUNT(*) AS customer_order_count
    FROM customer_order
    GROUP BY customer_id
) AS customer_order_summary;
```

**Purpose:** Calculates the average number of orders placed by customers who have made at least one purchase.

## 9. Database Views

A database view is a virtual table created from an SQL query. It presents data from one or more tables without necessarily storing a separate copy of the underlying records.

Views simplify frequently executed queries, improve consistency in reporting, and can help restrict access to selected columns.

### 9.1 Creating a Customer Order Summary View

```sql
CREATE OR REPLACE VIEW vw_customer_order_summary AS
SELECT
    co.order_id,
    co.order_reference,
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    co.order_date,
    co.total_amount,
    co.order_status
FROM customer_order co
INNER JOIN customer c
    ON co.customer_id = c.customer_id;
```

**Purpose:** Combines customer information and order details into a single reusable view.

**Retrieving records from the view:**

```sql
SELECT *
FROM vw_customer_order_summary
ORDER BY order_date DESC;
```

### 9.2 Creating a Product Inventory View

```sql
CREATE OR REPLACE VIEW vw_product_inventory AS
SELECT
    p.product_id,
    p.product_name,
    p.sku,
    c.category_name,
    p.price,
    i.quantity_on_hand,
    i.reorder_level,
    CASE
        WHEN i.quantity_on_hand <= i.reorder_level
            THEN 'Low Stock'
        ELSE 'Available'
    END AS stock_status
FROM product p
INNER JOIN category c
    ON p.category_id = c.category_id
LEFT JOIN inventory i
    ON p.product_id = i.product_id;
```

**Purpose:** Provides inventory managers with a consolidated view of product information, categories, stock quantities, and stock availability.

**Retrieving low-stock products:**

```sql
SELECT *
FROM vw_product_inventory
WHERE stock_status = 'Low Stock';
```

### 9.3 Creating a Successful Payment Summary View

```sql
CREATE OR REPLACE VIEW vw_successful_payments AS
SELECT
    py.payment_id,
    py.payment_reference,
    co.order_reference,
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    py.payment_method,
    py.amount,
    py.payment_date
FROM payment py
INNER JOIN customer_order co
    ON py.order_id = co.order_id
INNER JOIN customer c
    ON co.customer_id = c.customer_id
WHERE py.payment_status = 'successful';
```

**Purpose:** Provides finance personnel with a reusable view of successful payment transactions.

**Retrieving payment records:**

```sql
SELECT *
FROM vw_successful_payments
ORDER BY payment_date DESC;
```

## 10. Query Execution Plan Analysis

Query execution plan analysis helps database administrators understand how MySQL processes SQL queries.

It provides information about table access methods, indexes, estimated rows, join operations, and the order in which tables are accessed.

MySQL provides the EXPLAIN and EXPLAIN ANALYZE statements for examining query execution.

### 10.1 EXPLAIN Statement

The EXPLAIN statement displays the execution plan that MySQL intends to use when executing a query.

**Example: Analyse a product retrieval query**

```sql
EXPLAIN
SELECT
    product_id,
    product_name,
    price
FROM product
WHERE category_id = 1;
```

The execution plan provides information such as:

| Column | Description |
|---|---|
| id | Identifier of the SELECT operation |
| select_type | Type of SELECT query |
| table | Table being accessed |
| type | Access method used by MySQL |
| possible_keys | Indexes that may be used |
| key | Index selected by MySQL |
| rows | Estimated number of rows examined |
| Extra | Additional execution information |

### 10.2 Understanding Access Types

MySQL uses different access methods when retrieving records.

| Access Type | Description |
|---|---|
| system | Table contains only one record |
| const | At most one matching record is accessed using a unique key |
| eq_ref | One matching record is retrieved using a unique index for each preceding row |
| ref | Multiple matching records are retrieved using a non-unique index |
| range | Records are retrieved within an index range |
| index | MySQL scans an index |
| ALL | MySQL performs a full table scan |

Generally, accessing a small number of records through an appropriate index is preferable to scanning an entire large table. However, the best access method depends on the query and data distribution.

### 10.3 EXPLAIN ANALYZE

EXPLAIN ANALYZE executes the query and provides information about its actual execution behaviour.

**Example:**

```sql
EXPLAIN ANALYZE
SELECT
    product_id,
    product_name,
    price
FROM product
WHERE category_id = 1;
```

It provides information such as:

- Actual execution time.
- Number of rows returned.
- Number of loops performed.
- Estimated versus actual row counts.
- Execution operations performed by the database.

**Note:** EXPLAIN ANALYZE executes the underlying SELECT query. It is supported in MySQL 8.0.18 and later.

### 10.4 Analysing an Inefficient Query

Consider the following query:

```sql
SELECT *
FROM product
WHERE category_id = 1;
```

If the product table contains a large number of records and the category_id column is not indexed, MySQL may perform a full table scan.

This means that the database may need to examine many records to identify products belonging to the specified category.

The execution plan can be inspected using:

```sql
EXPLAIN
SELECT *
FROM product
WHERE category_id = 1;
```

### 10.5 Improving the Query

An index can be created on the category_id column:

```sql
CREATE INDEX idx_product_category
ON product(category_id);
```

The query can then be analysed again:

```sql
EXPLAIN
SELECT
    product_id,
    product_name,
    price
FROM product
WHERE category_id = 1;
```

MySQL may now use the newly created index to retrieve matching products more efficiently.

The actual result depends on the table size, data distribution, index statistics, and query selectivity.

## 11. Indexing Techniques

Indexing is a database optimisation technique that improves the speed of data retrieval by allowing the database engine to locate records without necessarily scanning every row.

MySQL supports different indexing techniques, including primary key indexes, unique indexes, single-column indexes, and composite indexes.

### 11.1 Primary Key Index

A primary key uniquely identifies each record in a table.

In InnoDB, the primary key is implemented as the clustered index.

**Example:**

```sql
ALTER TABLE customer
ADD PRIMARY KEY (customer_id);
```

If the primary key has already been defined during table creation, this statement is not required.

### 11.2 Unique Index

A unique index ensures that duplicate values are not stored in the indexed column or combination of columns.

**Example: Ensure customer email addresses are unique**

```sql
CREATE UNIQUE INDEX idx_customer_email
ON customer(email);
```

**Purpose:** Prevents duplicate customer email addresses and supports efficient customer lookups by email.

If a UNIQUE constraint already exists on the email column, an additional unique index is unnecessary.

### 11.3 Single-Column Index

A single-column index is created on one column to improve queries that frequently filter or search using that column.

**Example: Index the product SKU**

```sql
CREATE INDEX idx_product_sku
ON product(sku);
```

**Purpose:** Supports product searches based on SKU values.

### 11.4 Composite Index

A composite index is created using two or more columns.

It is useful when queries frequently filter using multiple columns.

**Example: Index customer orders by customer and order date**

```sql
CREATE INDEX idx_order_customer_date
ON customer_order(customer_id, order_date);
```

This index can support queries such as:

```sql
SELECT
    order_reference,
    order_date,
    total_amount
FROM customer_order
WHERE customer_id = 1
ORDER BY order_date DESC;
```

The index is particularly useful because the query filters by customer_id and sorts by order_date.

**Important:** The order of columns in a composite index matters. MySQL can generally use the leftmost prefix of a composite index.

### 11.5 Indexing Payment Records

Payment records may be frequently searched by transaction status and payment date.

**Example:**

```sql
CREATE INDEX idx_payment_status_date
ON payment(payment_status, payment_date);
```

This can support queries such as:

```sql
SELECT
    payment_reference,
    amount,
    payment_date
FROM payment
WHERE payment_status = 'successful'
AND payment_date >= '2026-01-01';
```

### 11.6 Reviewing Existing Indexes

The SHOW INDEX statement displays indexes associated with a database table.

**Example:**

```sql
SHOW INDEX FROM product;
```

To inspect customer order indexes:

```sql
SHOW INDEX FROM customer_order;
```

To inspect payment indexes:

```sql
SHOW INDEX FROM payment;
```

### 11.7 Indexing Considerations

Although indexes improve data retrieval performance, excessive indexing can negatively affect database operations.

The following considerations should guide index implementation:

- Index columns frequently used in WHERE conditions.
- Consider indexing columns used in JOIN conditions.
- Consider composite indexes for frequently executed multi-column queries.
- Avoid creating duplicate indexes.
- Monitor the impact of indexes on INSERT, UPDATE, and DELETE operations.
- Remove indexes that are unnecessary or rarely used after careful evaluation.

## 12. Query Optimisation Techniques

Query optimisation involves improving SQL statements and database structures to reduce execution time and resource consumption.

The following techniques are proposed for the Heywizzle database.

### 12.1 Avoid SELECT *

Retrieving every column from a table when only a few columns are required can increase data transfer and processing overhead.

**Less efficient approach:**

```sql
SELECT *
FROM product
WHERE category_id = 1;
```

**Improved approach:**

```sql
SELECT
    product_id,
    product_name,
    price
FROM product
WHERE category_id = 1;
```

**Benefit:** Reduces the amount of data retrieved and transferred.

### 12.2 Use Appropriate Indexes

Frequently queried columns should be evaluated for indexing.

**Example:**

```sql
CREATE INDEX idx_customer_order_status
ON customer_order(order_status);
```

This can support queries that retrieve orders based on their status.

```sql
SELECT
    order_reference,
    order_date,
    total_amount
FROM customer_order
WHERE order_status = 'pending';
```

**Benefit:** May reduce the number of records MySQL needs to examine.

### 12.3 Avoid Unnecessary Functions in WHERE Conditions

Applying functions to indexed columns can prevent efficient use of ordinary indexes in some queries.

**Less efficient approach:**

```sql
SELECT *
FROM customer_order
WHERE YEAR(order_date) = 2026;
```

**Improved approach:**

```sql
SELECT
    order_reference,
    order_date,
    total_amount
FROM customer_order
WHERE order_date >= '2026-01-01'
AND order_date < '2027-01-01';
```

**Benefit:** The improved query uses a date range that can take advantage of an index on order_date.

### 12.4 Use EXISTS Where Appropriate

EXISTS is useful when the requirement is to determine whether matching records exist.

**Example:**

```sql
SELECT
    c.customer_id,
    c.first_name,
    c.last_name
FROM customer c
WHERE EXISTS (
    SELECT 1
    FROM customer_order co
    WHERE co.customer_id = c.customer_id
);
```

**Benefit:** Expresses an existence check without requiring the outer query to retrieve all matching order records.

The optimiser may transform EXISTS and IN queries into similar execution strategies, so performance should be measured rather than assumed.

### 12.5 Retrieve Only Required Records Using LIMIT

The LIMIT clause restricts the number of records returned.

**Example: Retrieve the ten most recently added products**

```sql
SELECT
    product_id,
    product_name,
    price,
    created_at
FROM product
ORDER BY created_at DESC
LIMIT 10;
```

**Benefit:** Reduces the number of records returned to the application.

### 12.6 Use Appropriate JOIN Conditions

JOIN operations should use correctly defined primary and foreign key relationships.

**Example:**

```sql
SELECT
    co.order_reference,
    c.first_name,
    c.last_name,
    co.total_amount
FROM customer_order co
INNER JOIN customer c
    ON co.customer_id = c.customer_id
WHERE co.order_status = 'completed';
```

**Benefit:** Retrieves the required business information from related tables while avoiding unnecessary data retrieval.

### 12.7 Use Transactions for Related Data Changes

When a business operation affects multiple records, related changes should be grouped into a transaction where appropriate.

For example, processing an order may require updating inventory and creating order records.

```sql
START TRANSACTION;

UPDATE inventory
SET quantity_on_hand = quantity_on_hand - 2,
    last_updated = NOW()
WHERE product_id = 1
AND quantity_on_hand >= 2;

-- Check that the inventory update affected one row
-- before continuing with order processing.

COMMIT;
```

If a subsequent operation fails, the application should execute:

```sql
ROLLBACK;
```

**Benefit:** Helps maintain data consistency when multiple related database operations are performed.

A complete order-processing transaction, including validation and error handling, will be demonstrated in Portfolio 3.

### 12.8 Maintain Database Statistics

MySQL uses table and index statistics to determine suitable query execution plans.

The ANALYZE TABLE statement updates table statistics.

**Example:**

```sql
ANALYZE TABLE product;
```

Other tables can also be analysed:

```sql
ANALYZE TABLE customer_order;

ANALYZE TABLE payment;

ANALYZE TABLE inventory;
```

**Benefit:** Helps the query optimiser make informed decisions about index selection and query execution strategies.

## 13. Performance Evaluation

Performance evaluation is necessary to determine whether the optimisation techniques applied to the database produce measurable improvements.

This section proposes a practical approach to comparing query performance before and after optimisation.

### 13.1 Performance Testing Approach

The following procedure will be used:

1. Execute a query before applying optimisation.
2. Examine the query execution plan using EXPLAIN.
3. Record the execution time and other relevant execution statistics.
4. Identify possible performance bottlenecks.
5. Apply appropriate indexing or query restructuring.
6. Execute the query again.
7. Compare the results and execution plans.

### 13.2 Before and After Optimisation Example

**Scenario:** Retrieve all products belonging to a particular category.

**Before optimisation:**

```sql
SELECT
    product_id,
    product_name,
    price
FROM product
WHERE category_id = 1;
```

Execution plan:

```sql
EXPLAIN
SELECT
    product_id,
    product_name,
    price
FROM product
WHERE category_id = 1;
```

**Optimisation:**

```sql
CREATE INDEX idx_product_category
ON product(category_id);
```

**After optimisation:**

```sql
EXPLAIN ANALYZE
SELECT
    product_id,
    product_name,
    price
FROM product
WHERE category_id = 1;
```

The execution plans can be compared to determine whether MySQL uses the newly created index and whether the number of examined rows or actual execution time has improved.

### 13.3 Performance Measurement Criteria

The following metrics will be considered during testing:

| Metric | Description |
|---|---|
| Execution Time | Time required to execute a query |
| Rows Examined | Number of records examined during query processing |
| Rows Returned | Number of records returned by the query |
| Access Type | Method used by MySQL to retrieve records |
| Index Usage | Whether an appropriate index was selected |
| Estimated Rows | Number of rows estimated by the query optimiser |
| Actual Rows | Number of rows processed during actual execution |

### 13.4 Performance Comparison Table

The following table will be used to document actual test results.

| Test | Query Scenario | Before Optimisation | After Optimisation | Observation |
|---|---|---|---|---|
| 1 | Product retrieval by category | To be measured | To be measured | Evaluate index usage |
| 2 | Customer order retrieval | To be measured | To be measured | Evaluate composite indexing |
| 3 | Payment retrieval by status and date | To be measured | To be measured | Evaluate composite indexing |
| 4 | Product retrieval by SKU | To be measured | To be measured | Evaluate unique/index lookup |

**Note:** Actual execution times and query statistics must be obtained from the implemented database. No performance improvements are assumed without testing.

### 13.5 Expected Outcomes

After implementing the proposed query optimisation techniques, the following outcomes are expected:

- Faster retrieval of frequently accessed records.
- Improved performance of queries involving multiple tables.
- Reduced unnecessary data retrieval.
- More efficient execution of reporting queries.
- Improved database performance through appropriate indexing.
- Better understanding of query execution plans.
- Improved efficiency in handling increasing volumes of e-commerce transactions.

## 14. Conclusion

This portfolio has examined SQL query processing and optimisation techniques using the proposed relational database structure for Heywizzle Limited.

The implementation demonstrates the use of SQL Data Manipulation Language operations, including INSERT, SELECT, UPDATE, and DELETE, for managing business records.

It also demonstrates the retrieval of information from multiple tables using JOIN operations, the application of aggregate functions and subqueries, and the creation of database views for simplified reporting.

Furthermore, the portfolio examines query execution plans using EXPLAIN and EXPLAIN ANALYZE, explores different indexing techniques, and presents practical query optimisation methods.

The proposed techniques provide a foundation for improving the efficiency and performance of the Heywizzle Limited database as the volume of products, customers, orders, payments, and transactions increases.

The knowledge and practical implementation from this portfolio will support subsequent work on **Portfolio 3: Transactions and Concurrency**, where database transaction management, ACID properties, locking mechanisms, isolation levels, and concurrent transaction processing will be examined.

The complete mysql query for the database has been attached to this portfolio - heywizzle_db.sql
---
