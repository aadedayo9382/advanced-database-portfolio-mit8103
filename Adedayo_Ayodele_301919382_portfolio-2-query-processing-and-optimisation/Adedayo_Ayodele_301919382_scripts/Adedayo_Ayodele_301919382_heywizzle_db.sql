-- =============================================================
-- HEYWIZZLE LIMITED
-- E-COMMERCE DATABASE MANAGEMENT SYSTEM
-- Database: heywizzle_db
-- Portfolio 2: Query Processing and Optimisation
-- Target: MySQL 8.0.18+ / InnoDB
-- =============================================================

CREATE DATABASE IF NOT EXISTS heywizzle_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE heywizzle_db;

SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS category (
    category_id       BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    category_name     VARCHAR(100) NOT NULL,
    description       TEXT,
    created_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_category_name UNIQUE (category_name)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS customer (
    customer_id       BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    first_name        VARCHAR(80) NOT NULL,
    last_name         VARCHAR(80) NOT NULL,
    email             VARCHAR(190) NOT NULL,
    phone             VARCHAR(30),
    password_hash     VARCHAR(255) NOT NULL,
    account_status    ENUM('ACTIVE','INACTIVE','SUSPENDED') NOT NULL DEFAULT 'ACTIVE',
    created_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_customer_email UNIQUE (email)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS customer_address (
    address_id        BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    customer_id       BIGINT UNSIGNED NOT NULL,
    address_label     VARCHAR(50) DEFAULT 'Home',
    recipient_name    VARCHAR(160) NOT NULL,
    phone             VARCHAR(30),
    address_line1     VARCHAR(190) NOT NULL,
    address_line2     VARCHAR(190),
    city              VARCHAR(100) NOT NULL,
    state_region      VARCHAR(100),
    postal_code       VARCHAR(20),
    country           VARCHAR(100) NOT NULL DEFAULT 'Nigeria',
    is_default        BOOLEAN NOT NULL DEFAULT FALSE,
    created_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_address_customer FOREIGN KEY (customer_id)
      REFERENCES customer(customer_id) ON UPDATE CASCADE ON DELETE CASCADE,
    INDEX idx_address_customer (customer_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS product (
    product_id        BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    category_id       BIGINT UNSIGNED NOT NULL,
    product_name      VARCHAR(180) NOT NULL,
    sku               VARCHAR(80) NOT NULL,
    description       TEXT,
    price             DECIMAL(12,2) NOT NULL,
    is_active         BOOLEAN NOT NULL DEFAULT TRUE,
    created_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_product_sku UNIQUE (sku),
    CONSTRAINT chk_product_price CHECK (price >= 0),
    CONSTRAINT fk_product_category FOREIGN KEY (category_id)
      REFERENCES category(category_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_product_category (category_id),
    INDEX idx_product_active_price (is_active, price)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS product_attribute (
    product_attribute_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    attribute_name       VARCHAR(100) NOT NULL,
    CONSTRAINT uq_attribute_name UNIQUE (attribute_name)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS product_attribute_value (
    product_attribute_value_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id                 BIGINT UNSIGNED NOT NULL,
    product_attribute_id       BIGINT UNSIGNED NOT NULL,
    attribute_value            VARCHAR(255) NOT NULL,
    CONSTRAINT fk_pav_product FOREIGN KEY (product_id)
      REFERENCES product(product_id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_pav_attribute FOREIGN KEY (product_attribute_id)
      REFERENCES product_attribute(product_attribute_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT uq_product_attribute UNIQUE (product_id, product_attribute_id),
    INDEX idx_pav_attribute_value (product_attribute_id, attribute_value)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS inventory (
    inventory_id       BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id         BIGINT UNSIGNED NOT NULL,
    quantity_on_hand   INT NOT NULL DEFAULT 0,
    reorder_level      INT NOT NULL DEFAULT 5,
    last_stock_update  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_inventory_product UNIQUE (product_id),
    CONSTRAINT chk_inventory_quantity CHECK (quantity_on_hand >= 0),
    CONSTRAINT chk_inventory_reorder CHECK (reorder_level >= 0),
    CONSTRAINT fk_inventory_product FOREIGN KEY (product_id)
      REFERENCES product(product_id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS customer_order (
    order_id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    customer_id         BIGINT UNSIGNED NOT NULL,
    shipping_address_id BIGINT UNSIGNED,
    order_reference     VARCHAR(50) NOT NULL,
    order_date          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_amount        DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    order_status        ENUM('PENDING','PROCESSING','SHIPPED','DELIVERED','CANCELLED') NOT NULL DEFAULT 'PENDING',
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_order_reference UNIQUE (order_reference),
    CONSTRAINT chk_order_total CHECK (total_amount >= 0),
    CONSTRAINT fk_order_customer FOREIGN KEY (customer_id)
      REFERENCES customer(customer_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_order_address FOREIGN KEY (shipping_address_id)
      REFERENCES customer_address(address_id) ON UPDATE CASCADE ON DELETE SET NULL,
    INDEX idx_order_customer_date (customer_id, order_date),
    INDEX idx_order_status_date (order_status, order_date)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS order_item (
    order_item_id       BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id            BIGINT UNSIGNED NOT NULL,
    product_id          BIGINT UNSIGNED NOT NULL,
    quantity            INT NOT NULL,
    unit_price          DECIMAL(12,2) NOT NULL,
    line_total          DECIMAL(12,2) NOT NULL,
    CONSTRAINT chk_order_item_quantity CHECK (quantity > 0),
    CONSTRAINT chk_order_item_price CHECK (unit_price >= 0 AND line_total >= 0),
    CONSTRAINT fk_order_item_order FOREIGN KEY (order_id)
      REFERENCES customer_order(order_id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_order_item_product FOREIGN KEY (product_id)
      REFERENCES product(product_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_order_item_order (order_id),
    INDEX idx_order_item_product (product_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS payment (
    payment_id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id            BIGINT UNSIGNED NOT NULL,
    payment_reference   VARCHAR(100) NOT NULL,
    payment_method      ENUM('CARD','BANK_TRANSFER','USSD','WALLET','CASH_ON_DELIVERY') NOT NULL,
    amount              DECIMAL(12,2) NOT NULL,
    payment_date        DATETIME,
    payment_status      ENUM('PENDING','SUCCESSFUL','FAILED','REFUNDED') NOT NULL DEFAULT 'PENDING',
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_payment_reference UNIQUE (payment_reference),
    CONSTRAINT chk_payment_amount CHECK (amount >= 0),
    CONSTRAINT fk_payment_order FOREIGN KEY (order_id)
      REFERENCES customer_order(order_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_payment_order_status (order_id, payment_status),
    INDEX idx_payment_date_status (payment_date, payment_status)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS delivery (
    delivery_id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id                BIGINT UNSIGNED NOT NULL,
    tracking_reference      VARCHAR(100) NOT NULL,
    delivery_person         VARCHAR(160),
    expected_delivery_date  DATE,
    actual_delivery_date    DATE,
    delivery_status         ENUM('PENDING','DISPATCHED','IN_TRANSIT','DELIVERED','FAILED','RETURNED') NOT NULL DEFAULT 'PENDING',
    created_at              TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_delivery_tracking UNIQUE (tracking_reference),
    CONSTRAINT uq_delivery_order UNIQUE (order_id),
    CONSTRAINT fk_delivery_order FOREIGN KEY (order_id)
      REFERENCES customer_order(order_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_delivery_status_expected (delivery_status, expected_delivery_date)
) ENGINE=InnoDB;

SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================
-- SECTION 1: SAMPLE DATA (safe to re-run due to unique-key checks)
-- =============================================================

INSERT INTO category (category_name, description) VALUES
('Electronics', 'Electronic devices and accessories'),
('Fashion', 'Clothing, footwear and fashion accessories'),
('Home & Kitchen', 'Household and kitchen products')
ON DUPLICATE KEY UPDATE description = VALUES(description);

INSERT INTO customer
(first_name, last_name, email, phone, password_hash, account_status)
VALUES
('Ada', 'Okafor', 'ada.okafor@example.com', '+2348011110001', 'DEMO_HASH_REPLACE_IN_APPLICATION', 'ACTIVE'),
('Tunde', 'Balogun', 'tunde.balogun@example.com', '+2348022220002', 'DEMO_HASH_REPLACE_IN_APPLICATION', 'ACTIVE'),
('Mariam', 'Yusuf', 'mariam.yusuf@example.com', '+2348033330003', 'DEMO_HASH_REPLACE_IN_APPLICATION', 'ACTIVE'),
('David', 'Eze', 'david.eze@example.com', '+2348044440004', 'DEMO_HASH_REPLACE_IN_APPLICATION', 'INACTIVE')
ON DUPLICATE KEY UPDATE
 first_name = VALUES(first_name), last_name = VALUES(last_name),
 phone = VALUES(phone), account_status = VALUES(account_status);

INSERT INTO customer_address
(customer_id, address_label, recipient_name, phone, address_line1, city, state_region, postal_code, country, is_default)
SELECT c.customer_id, 'Home', CONCAT(c.first_name, ' ', c.last_name), c.phone,
       '12 Example Street', 'Lagos', 'Lagos', '100001', 'Nigeria', TRUE
FROM customer c
WHERE c.email IN ('ada.okafor@example.com','tunde.balogun@example.com','mariam.yusuf@example.com')
AND NOT EXISTS (
  SELECT 1 FROM customer_address a
  WHERE a.customer_id = c.customer_id AND a.address_label = 'Home'
);

INSERT INTO product (category_id, product_name, sku, description, price, is_active)
SELECT c.category_id, x.product_name, x.sku, x.description, x.price, TRUE
FROM (
  SELECT 'Electronics' category_name, 'Wireless Headphones' product_name, 'HWZ-ELEC-001' sku,
         'Bluetooth wireless headphones' description, 45000.00 price
  UNION ALL
  SELECT 'Electronics', 'Smart Watch', 'HWZ-ELEC-002', 'Fitness and notification smart watch', 65000.00
  UNION ALL
  SELECT 'Fashion', 'Unisex Backpack', 'HWZ-FASH-001', 'Everyday travel backpack', 28000.00
  UNION ALL
  SELECT 'Home & Kitchen', 'Electric Blender', 'HWZ-HOME-001', 'Multi-speed kitchen blender', 52000.00
) x
JOIN category c ON c.category_name = x.category_name
ON DUPLICATE KEY UPDATE
 product_name = VALUES(product_name), description = VALUES(description),
 price = VALUES(price), is_active = VALUES(is_active);

INSERT INTO inventory (product_id, quantity_on_hand, reorder_level)
SELECT p.product_id,
       CASE p.sku
         WHEN 'HWZ-ELEC-001' THEN 25
         WHEN 'HWZ-ELEC-002' THEN 12
         WHEN 'HWZ-FASH-001' THEN 40
         WHEN 'HWZ-HOME-001' THEN 4
       END,
       5
FROM product p
WHERE p.sku IN ('HWZ-ELEC-001','HWZ-ELEC-002','HWZ-FASH-001','HWZ-HOME-001')
ON DUPLICATE KEY UPDATE
 quantity_on_hand = VALUES(quantity_on_hand), reorder_level = VALUES(reorder_level);

INSERT INTO product_attribute (attribute_name) VALUES
('Colour'), ('Size'), ('Brand')
ON DUPLICATE KEY UPDATE attribute_name = VALUES(attribute_name);

INSERT INTO product_attribute_value (product_id, product_attribute_id, attribute_value)
SELECT p.product_id, a.product_attribute_id, v.attribute_value
FROM (
  SELECT 'HWZ-ELEC-001' sku, 'Colour' attribute_name, 'Black' attribute_value
  UNION ALL SELECT 'HWZ-ELEC-002', 'Colour', 'Silver'
  UNION ALL SELECT 'HWZ-FASH-001', 'Colour', 'Blue'
  UNION ALL SELECT 'HWZ-FASH-001', 'Size', 'Large'
  UNION ALL SELECT 'HWZ-HOME-001', 'Brand', 'Heywizzle Home'
) v
JOIN product p ON p.sku = v.sku
JOIN product_attribute a ON a.attribute_name = v.attribute_name
ON DUPLICATE KEY UPDATE attribute_value = VALUES(attribute_value);

-- Three example orders; the INSERT ... SELECT form resolves generated IDs.
INSERT INTO customer_order
(customer_id, shipping_address_id, order_reference, order_date, total_amount, order_status)
SELECT c.customer_id, a.address_id, x.order_reference, x.order_date, x.total_amount, x.order_status
FROM (
  SELECT 'ada.okafor@example.com' email, 'HWZ-ORD-0001' order_reference,
         '2026-10-15 10:30:00' order_date, 90000.00 total_amount, 'DELIVERED' order_status
  UNION ALL
  SELECT 'tunde.balogun@example.com', 'HWZ-ORD-0002',
         '2026-10-20 14:15:00', 65000.00, 'SHIPPED'
  UNION ALL
  SELECT 'mariam.yusuf@example.com', 'HWZ-ORD-0003',
         '2026-10-25 09:00:00', 80000.00, 'PROCESSING'
) x
JOIN customer c ON c.email = x.email
LEFT JOIN customer_address a ON a.customer_id = c.customer_id AND a.address_label = 'Home'
ON DUPLICATE KEY UPDATE
 total_amount = VALUES(total_amount), order_status = VALUES(order_status);

INSERT INTO order_item (order_id, product_id, quantity, unit_price, line_total)
SELECT o.order_id, p.product_id, x.quantity, p.price, x.quantity * p.price
FROM (
  SELECT 'HWZ-ORD-0001' order_reference, 'HWZ-ELEC-001' sku, 2 quantity
  UNION ALL SELECT 'HWZ-ORD-0002', 'HWZ-ELEC-002', 1
  UNION ALL SELECT 'HWZ-ORD-0003', 'HWZ-FASH-001', 1
  UNION ALL SELECT 'HWZ-ORD-0003', 'HWZ-HOME-001', 1
) x
JOIN customer_order o ON o.order_reference = x.order_reference
JOIN product p ON p.sku = x.sku
WHERE NOT EXISTS (
  SELECT 1 FROM order_item oi
  WHERE oi.order_id = o.order_id AND oi.product_id = p.product_id
);

INSERT INTO payment
(order_id, payment_reference, payment_method, amount, payment_date, payment_status)
SELECT o.order_id, x.payment_reference, x.payment_method, x.amount, x.payment_date, x.payment_status
FROM (
  SELECT 'HWZ-ORD-0001' order_reference, 'HWZ-PAY-0001' payment_reference,
         'CARD' payment_method, 90000.00 amount, '2026-10-15 10:35:00' payment_date,
         'SUCCESSFUL' payment_status
  UNION ALL
  SELECT 'HWZ-ORD-0002', 'HWZ-PAY-0002', 'BANK_TRANSFER', 65000.00,
         '2026-10-20 14:20:00', 'SUCCESSFUL'
  UNION ALL
  SELECT 'HWZ-ORD-0003', 'HWZ-PAY-0003', 'USSD', 80000.00,
         '2026-10-25 09:10:00', 'PENDING'
) x
JOIN customer_order o ON o.order_reference = x.order_reference
ON DUPLICATE KEY UPDATE amount = VALUES(amount), payment_status = VALUES(payment_status);

INSERT INTO delivery
(order_id, tracking_reference, delivery_person, expected_delivery_date, actual_delivery_date, delivery_status)
SELECT o.order_id, x.tracking_reference, x.delivery_person,
       x.expected_delivery_date, x.actual_delivery_date, x.delivery_status
FROM (
  SELECT 'HWZ-ORD-0001' order_reference, 'HWZ-TRK-0001' tracking_reference,
         'Chika Delivery' delivery_person, '2026-10-18' expected_delivery_date,
         '2026-10-17' actual_delivery_date, 'DELIVERED' delivery_status
  UNION ALL
  SELECT 'HWZ-ORD-0002', 'HWZ-TRK-0002', 'Kunle Delivery',
         '2026-10-28', NULL, 'IN_TRANSIT'
) x
JOIN customer_order o ON o.order_reference = x.order_reference
ON DUPLICATE KEY UPDATE
 delivery_person = VALUES(delivery_person),
 expected_delivery_date = VALUES(expected_delivery_date),
 actual_delivery_date = VALUES(actual_delivery_date),
 delivery_status = VALUES(delivery_status);

-- =============================================================
-- SECTION 2: BASIC DML OPERATIONS
-- =============================================================

-- INSERT: add a new customer.
INSERT INTO customer
(first_name, last_name, email, phone, password_hash, account_status)
VALUES
('Grace', 'Adeleke', 'grace.adeleke@example.com', '+2348055550005',
 'DEMO_HASH_REPLACE_IN_APPLICATION', 'ACTIVE');

-- SELECT: retrieve all active customers.
SELECT customer_id, first_name, last_name, email, phone, created_at
FROM customer
WHERE account_status = 'ACTIVE'
ORDER BY created_at DESC;

-- UPDATE: change a customer's phone number.
UPDATE customer
SET phone = '+2348066660006'
WHERE email = 'grace.adeleke@example.com';

-- DELETE: delete the demonstration customer only.
-- Customer addresses cascade; orders restrict deletion.
DELETE FROM customer
WHERE email = 'grace.adeleke@example.com'
  AND NOT EXISTS (
    SELECT 1 FROM customer_order o WHERE o.customer_id = customer.customer_id
  );

-- =============================================================
-- SECTION 3: SIMPLE RETRIEVAL AND FILTERING
-- =============================================================

-- Products within a price range.
SELECT product_id, product_name, sku, price
FROM product
WHERE price BETWEEN 20000 AND 70000
  AND is_active = TRUE
ORDER BY price ASC;

-- Search products by a partial name.
SELECT product_id, product_name, sku, price
FROM product
WHERE product_name LIKE '%Watch%';

-- Products with low inventory.
SELECT p.product_id, p.product_name, p.sku,
       i.quantity_on_hand, i.reorder_level
FROM product p
JOIN inventory i ON i.product_id = p.product_id
WHERE i.quantity_on_hand <= i.reorder_level
ORDER BY i.quantity_on_hand ASC;

-- =============================================================
-- SECTION 4: JOIN QUERIES
-- =============================================================

-- INNER JOIN: products and their categories.
SELECT p.product_id, p.product_name, p.sku, p.price,
       c.category_name
FROM product p
INNER JOIN category c ON c.category_id = p.category_id
ORDER BY c.category_name, p.product_name;

-- LEFT JOIN: include customers who have not placed an order.
SELECT c.customer_id, c.first_name, c.last_name, c.email,
       COUNT(o.order_id) AS total_orders
FROM customer c
LEFT JOIN customer_order o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email
ORDER BY total_orders DESC;

-- Multi-table join: order, customer, items and products.
SELECT o.order_reference, o.order_date, o.order_status,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       p.product_name, oi.quantity, oi.unit_price, oi.line_total
FROM customer_order o
JOIN customer c ON c.customer_id = o.customer_id
JOIN order_item oi ON oi.order_id = o.order_id
JOIN product p ON p.product_id = oi.product_id
ORDER BY o.order_date DESC, o.order_reference;

-- Orders with payment and delivery details.
SELECT o.order_reference, o.order_date, o.order_status,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       pay.payment_reference, pay.payment_method, pay.amount,
       pay.payment_status, d.tracking_reference, d.delivery_status
FROM customer_order o
JOIN customer c ON c.customer_id = o.customer_id
LEFT JOIN payment pay ON pay.order_id = o.order_id
LEFT JOIN delivery d ON d.order_id = o.order_id
ORDER BY o.order_date DESC;

-- =============================================================
-- SECTION 5: AGGREGATE FUNCTIONS, GROUP BY AND HAVING
-- =============================================================

-- Total number of customers.
SELECT COUNT(*) AS total_customers FROM customer;

-- Product price statistics.
SELECT COUNT(*) AS product_count,
       MIN(price) AS minimum_price,
       MAX(price) AS maximum_price,
       AVG(price) AS average_price
FROM product
WHERE is_active = TRUE;

-- Total orders and sales value by order status.
SELECT order_status, COUNT(*) AS number_of_orders,
       SUM(total_amount) AS order_value
FROM customer_order
GROUP BY order_status
ORDER BY order_value DESC;

-- Revenue by product category (based on order-item values).
SELECT c.category_name,
       SUM(oi.quantity) AS units_sold,
       SUM(oi.line_total) AS gross_sales
FROM category c
JOIN product p ON p.category_id = c.category_id
JOIN order_item oi ON oi.product_id = p.product_id
JOIN customer_order o ON o.order_id = oi.order_id
WHERE o.order_status <> 'CANCELLED'
GROUP BY c.category_id, c.category_name
ORDER BY gross_sales DESC;

-- Customers whose total order value exceeds 50,000.
SELECT c.customer_id, c.first_name, c.last_name,
       COUNT(o.order_id) AS order_count,
       SUM(o.total_amount) AS total_order_value
FROM customer c
JOIN customer_order o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING SUM(o.total_amount) > 50000
ORDER BY total_order_value DESC;

-- =============================================================
-- SECTION 6: SUBQUERIES
-- =============================================================

-- WHERE subquery: products priced above the average active-product price.
SELECT product_id, product_name, price
FROM product
WHERE is_active = TRUE
  AND price > (
    SELECT AVG(price) FROM product WHERE is_active = TRUE
  );

-- IN subquery: customers who have placed at least one order.
SELECT customer_id, first_name, last_name, email
FROM customer
WHERE customer_id IN (
  SELECT customer_id FROM customer_order
);

-- EXISTS correlated subquery: products that have appeared in an order.
SELECT p.product_id, p.product_name, p.sku
FROM product p
WHERE EXISTS (
  SELECT 1
  FROM order_item oi
  WHERE oi.product_id = p.product_id
);

-- NOT EXISTS: customers who have never placed an order.
SELECT c.customer_id, c.first_name, c.last_name, c.email
FROM customer c
WHERE NOT EXISTS (
  SELECT 1 FROM customer_order o
  WHERE o.customer_id = c.customer_id
);

-- FROM subquery: customers with at least one order, with their order totals.
SELECT customer_totals.customer_id,
       customer_totals.customer_name,
       customer_totals.order_count,
       customer_totals.total_spent
FROM (
  SELECT c.customer_id,
         CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
         COUNT(o.order_id) AS order_count,
         SUM(o.total_amount) AS total_spent
  FROM customer c
  JOIN customer_order o ON o.customer_id = c.customer_id
  GROUP BY c.customer_id, c.first_name, c.last_name
) AS customer_totals
WHERE customer_totals.total_spent > 50000;

-- =============================================================
-- SECTION 7: VIEWS
-- =============================================================

CREATE OR REPLACE VIEW vw_customer_order_summary AS
SELECT c.customer_id,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       c.email,
       COUNT(o.order_id) AS total_orders,
       COALESCE(SUM(o.total_amount), 0.00) AS total_order_value
FROM customer c
LEFT JOIN customer_order o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email;

CREATE OR REPLACE VIEW vw_product_inventory AS
SELECT p.product_id, p.product_name, p.sku, c.category_name,
       p.price, i.quantity_on_hand, i.reorder_level,
       CASE
         WHEN i.quantity_on_hand <= i.reorder_level THEN 'REORDER'
         ELSE 'IN STOCK'
       END AS stock_status
FROM product p
JOIN category c ON c.category_id = p.category_id
JOIN inventory i ON i.product_id = p.product_id;

CREATE OR REPLACE VIEW vw_successful_payments AS
SELECT pay.payment_id, pay.payment_reference, pay.payment_method,
       pay.amount, pay.payment_date, o.order_reference,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name
FROM payment pay
JOIN customer_order o ON o.order_id = pay.order_id
JOIN customer c ON c.customer_id = o.customer_id
WHERE pay.payment_status = 'SUCCESSFUL';

-- Query the views.
SELECT * FROM vw_customer_order_summary ORDER BY total_order_value DESC;
SELECT * FROM vw_product_inventory ORDER BY stock_status, product_name;
SELECT * FROM vw_successful_payments ORDER BY payment_date DESC;

-- =============================================================
-- SECTION 8: INDEXING
-- Most indexes are created with their tables above. The following
-- statements demonstrate checking and adding indexes safely.
-- =============================================================

SHOW INDEX FROM customer;
SHOW INDEX FROM product;
SHOW INDEX FROM customer_order;
SHOW INDEX FROM order_item;
SHOW INDEX FROM payment;

-- Composite index for order status and date filtering.
-- The index is created in the table definition as idx_order_status_date.
-- If adapting an older database, create it only if it does not exist.

-- Example index for product name searches/sorting.
-- CREATE INDEX idx_product_name ON product(product_name);

-- Example composite index for order-item lookup by product and order.
-- CREATE INDEX idx_order_item_product_order ON order_item(product_id, order_id);

-- =============================================================
-- SECTION 9: QUERY EXECUTION PLANS AND OPTIMISATION
-- =============================================================

-- Baseline query: inspect the execution plan.
EXPLAIN
SELECT o.order_id, o.order_reference, o.order_date, o.total_amount
FROM customer_order o
WHERE o.customer_id = 1
  AND o.order_date >= '2026-01-01'
ORDER BY o.order_date DESC;

-- Actual execution analysis (MySQL 8.0.18+).
EXPLAIN ANALYZE
SELECT o.order_id, o.order_reference, o.order_date, o.total_amount
FROM customer_order o
WHERE o.customer_id = 1
  AND o.order_date >= '2026-01-01'
ORDER BY o.order_date DESC;

-- Check whether the product category index is used.
EXPLAIN
SELECT product_id, product_name, price
FROM product
WHERE category_id = 1
ORDER BY product_name;

-- Optimised retrieval: select only required columns and limit output.
SELECT product_id, product_name, price
FROM product
WHERE is_active = TRUE
ORDER BY created_at DESC
LIMIT 10;

-- Avoid applying a function to an indexed date column in the filter.
-- Prefer a date range as shown here:
SELECT order_id, order_reference, order_date
FROM customer_order
WHERE order_date >= '2026-10-01 00:00:00'
  AND order_date <  '2026-11-01 00:00:00';

-- Update table statistics to help the optimiser.
ANALYZE TABLE customer, product, customer_order, order_item, payment, inventory;

-- =============================================================
-- SECTION 10: TRANSACTION EXAMPLE FOR INVENTORY UPDATE
-- Portfolio 2 demonstrates transaction syntax. The complete order
-- placement workflow, validation, rollback handling and concurrency
-- controls should be expanded in Portfolio 3.
-- =============================================================

START TRANSACTION;

-- Lock the inventory row while checking and updating stock.
SELECT quantity_on_hand
FROM inventory
WHERE product_id = 1
FOR UPDATE;

-- Example stock deduction. The WHERE condition prevents negative stock.
UPDATE inventory
SET quantity_on_hand = quantity_on_hand - 1
WHERE product_id = 1
  AND quantity_on_hand >= 1;

-- Check the affected row count in the client/application.
-- COMMIT only if exactly one row was updated; otherwise ROLLBACK.
-- This script rolls back the demonstration change to preserve sample data.
ROLLBACK;

-- =============================================================
-- SECTION 11: USEFUL REPORTING QUERIES
-- =============================================================

-- Orders placed within a date range.
SELECT order_reference, customer_id, order_date, total_amount, order_status
FROM customer_order
WHERE order_date >= '2026-10-01'
  AND order_date < '2026-11-01'
ORDER BY order_date DESC;

-- Payment summary by payment method.
SELECT payment_method, COUNT(*) AS payment_count,
       SUM(amount) AS total_amount
FROM payment
WHERE payment_status = 'SUCCESSFUL'
GROUP BY payment_method
ORDER BY total_amount DESC;

-- Deliveries that are not yet completed.
SELECT o.order_reference, d.tracking_reference,
       d.expected_delivery_date, d.delivery_status
FROM delivery d
JOIN customer_order o ON o.order_id = d.order_id
WHERE d.delivery_status NOT IN ('DELIVERED','RETURNED')
ORDER BY d.expected_delivery_date;

-- Products and their attributes.
SELECT p.product_name, p.sku, a.attribute_name, pav.attribute_value
FROM product p
JOIN product_attribute_value pav ON pav.product_id = p.product_id
JOIN product_attribute a ON a.product_attribute_id = pav.product_attribute_id
ORDER BY p.product_name, a.attribute_name;

-- =============================================================
-- SECTION 12: VALIDATION / DATABASE SUMMARY
-- =============================================================

SELECT 'customer' AS table_name, COUNT(*) AS records FROM customer
UNION ALL SELECT 'category', COUNT(*) FROM category
UNION ALL SELECT 'product', COUNT(*) FROM product
UNION ALL SELECT 'inventory', COUNT(*) FROM inventory
UNION ALL SELECT 'customer_order', COUNT(*) FROM customer_order
UNION ALL SELECT 'order_item', COUNT(*) FROM order_item
UNION ALL SELECT 'payment', COUNT(*) FROM payment
UNION ALL SELECT 'delivery', COUNT(*) FROM delivery;

-- End of heywizzle_db.sql
