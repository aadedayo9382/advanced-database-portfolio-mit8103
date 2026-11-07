
# Portfolio 3: Transactions and Concurrency

**Heywizzle Limited – E-commerce Database Management System**

**Student:** Adedayo Ayodele  
**Matric Number:** 2026/A/MIT/0422  
**Course:** Advanced Database System (MIT 8103)  
**Portfolio:** 3 – Transactions and Concurrency  
**DBMS:** MySQL 8.0.18+ (InnoDB storage engine)  
**Database:** `heywizzle_db`

---

## 1. Introduction

Heywizzle Limited operates an e-commerce platform where customers browse products, place orders, make payments, and track deliveries. The database must remain accurate and reliable when customers and staff use the system simultaneously.

Concurrency is especially important when two or more customers attempt to purchase the remaining stock of the same product. Without suitable transaction controls, the system could accept orders that exceed available inventory, record incomplete orders, or leave order and stock records inconsistent.

This portfolio demonstrates transaction management and concurrency control using the actual `heywizzle_db` schema defined for Heywizzle Limited. The database uses MySQL 8.0.18+ and the InnoDB storage engine. The examples cover ACID properties, transaction processing, conditional stock updates, row-level locking, isolation levels, rollback, savepoints, and deadlock management.

The examples are aligned with the implemented tables and column names, particularly `product`, `inventory`, `customer`, `customer_address`, `customer_order`, `order_item`, `payment`, and `delivery`. The schema already defines foreign keys, unique constraints, check constraints, and supporting indexes.

## 2. Aim and Objectives

### Aim

To demonstrate how transactions and concurrency-control techniques protect the consistency, reliability, and integrity of Heywizzle Limited's e-commerce database when multiple operations occur simultaneously.

### Objectives

- Explain and apply the ACID properties.
- Group related database operations into transactions.
- Demonstrate `COMMIT`, `ROLLBACK`, and savepoints.
- Prevent overselling when customers order the same product concurrently.
- Explain MySQL isolation levels and InnoDB row-level locks.
- Identify and handle transaction conflicts and deadlocks.
- Demonstrate how transactions work with the actual Heywizzle database tables.
- Propose tests that demonstrate the effectiveness of the controls.

## 3. Transaction Management in the Heywizzle E-commerce Database

A database transaction is a logical unit of work consisting of one or more database operations. The operations should either all succeed or be rolled back so that the database does not retain a partial result.

In the Heywizzle database, an order workflow can involve:

1. Confirming that the customer exists and has an active account.
2. Confirming that the product exists and is active.
3. Checking and reserving sufficient stock in `inventory`.
4. Creating the order record in `customer_order`.
5. Creating one or more order-line records in `order_item`.
6. Recording a payment attempt in `payment`, where appropriate.
7. Committing the database transaction.

The database schema supports this workflow through the following relationships:

- `product.category_id` references `category.category_id`.
- `inventory.product_id` references `product.product_id`.
- `customer_address.customer_id` references `customer.customer_id`.
- `customer_order.customer_id` references `customer.customer_id`.
- `customer_order.shipping_address_id` references `customer_address.address_id`.
- `order_item.order_id` references `customer_order.order_id`.
- `order_item.product_id` references `product.product_id`.
- `payment.order_id` and `delivery.order_id` reference `customer_order.order_id`.

If an essential database operation fails, the application should issue `ROLLBACK`. All tables participating in a transaction must use a transactional storage engine such as InnoDB. The supplied SQL script creates the tables using InnoDB.

A payment provider operates outside MySQL. A database rollback cannot reverse a charge already completed by an external provider. Payment-provider calls therefore require a separate workflow, idempotency controls, and payment-status reconciliation.

## 4. ACID Properties

| Property | Meaning | Application at Heywizzle Limited |
|---|---|---|
| Atomicity | All operations in a transaction succeed, or none are retained. | If stock reservation or order creation fails, the related database changes are rolled back. |
| Consistency | A transaction moves the database from one valid state to another. | Foreign keys ensure valid customer, product, and order relationships. Check constraints prevent negative stock and invalid order quantities or amounts. |
| Isolation | Concurrent transactions are controlled so that they do not improperly interfere. | Two customers cannot both successfully reserve the same last unit when stock is updated using a conditional update. |
| Durability | Once committed, changes persist, subject to DBMS durability configuration. | A committed order remains recorded after a database restart, subject to the server's durability configuration and storage reliability. |

### 4.1 Atomicity

Atomicity prevents partial completion. For example, an order should not be committed if its stock reservation failed. InnoDB provides transactional rollback for changes made within the transaction.

### 4.2 Consistency

Consistency is supported by the constraints already defined in the Heywizzle SQL schema. Examples include:

```sql
-- inventory table
CHECK (quantity_on_hand >= 0)

-- order_item table
CHECK (quantity > 0)
CHECK (unit_price >= 0 AND line_total >= 0)

-- customer_order table
CHECK (total_amount >= 0)

-- payment table
CHECK (amount >= 0)

-- product table
CHECK (price >= 0)
```

The schema also uses foreign keys to prevent invalid relationships. For example, an order item cannot reference a product that does not exist.

These constraints are already included in the supplied database definition. They do not need to be added again when that schema has been created successfully.

### 4.3 Isolation

Isolation controls how transactions interact when they access the same data concurrently. InnoDB supports `READ UNCOMMITTED`, `READ COMMITTED`, `REPEATABLE READ`, and `SERIALIZABLE`. The default MySQL isolation level is normally `REPEATABLE READ`, although the server or session configuration can be changed.

### 4.4 Durability

InnoDB uses redo logging and recovery mechanisms to support durability. A successful `COMMIT` confirms that MySQL accepted the transaction. Actual durability also depends on server configuration, storage reliability, and settings such as `innodb_flush_log_at_trx_commit`. Backups and tested recovery procedures remain necessary.

## 5. Transaction Example: Updating Stock

The Heywizzle `inventory` table contains the columns `product_id`, `quantity_on_hand`, `reorder_level`, and `last_stock_update`. The following example locks the inventory row, checks that at least two units are available, and deducts two units.

```sql
START TRANSACTION;

SELECT product_id, quantity_on_hand
FROM inventory
WHERE product_id = 1
FOR UPDATE;

UPDATE inventory
SET quantity_on_hand = quantity_on_hand - 2
WHERE product_id = 1
  AND quantity_on_hand >= 2;

SELECT ROW_COUNT() AS rows_updated;

-- The application must check rows_updated immediately.
-- If it is 1, the stock deduction succeeded.
-- If it is 0, the stock was insufficient or the product was not found.
-- COMMIT only after the application confirms success.
-- Otherwise, execute ROLLBACK.

ROLLBACK;
```

The final `ROLLBACK` deliberately cancels the demonstration change so that the sample inventory is preserved. In a real checkout operation, the application would commit only after all required order operations had succeeded.

`SELECT ... FOR UPDATE` is a locking read in InnoDB. The lock is held until `COMMIT` or `ROLLBACK`. The application should check `ROW_COUNT()` immediately after the `UPDATE`. A result of zero means the requested stock deduction did not take place.

The example uses `product_id = 1` to demonstrate the operation, consistent with the transaction example in the supplied SQL script. In application code, the product identifier should be obtained from the selected product rather than assumed.

## 6. Safe Concurrent Order Processing

### 6.1 The overselling problem

Assume a product has one unit remaining. Customer A and Customer B both attempt to purchase it. If both customers independently read the stock value and make decisions using that earlier value, both may proceed unless the database coordinates their updates. This race condition can result in two accepted orders for one unit.

The Heywizzle database stores available stock in `inventory.quantity_on_hand`, linked to a product through `inventory.product_id`.

### 6.2 Recommended approach: atomic conditional stock reservation

A reliable approach is to use a conditional `UPDATE` inside the order transaction. InnoDB obtains the necessary row lock for the update. If another transaction attempts to update the same inventory row, it waits. After the first transaction completes, MySQL evaluates the waiting update against the current row value.

```sql
START TRANSACTION;

UPDATE inventory
SET quantity_on_hand = quantity_on_hand - 1
WHERE product_id = 1
  AND quantity_on_hand >= 1;

SELECT ROW_COUNT() AS rows_reserved;

-- Application decision:
-- If rows_reserved = 1, continue creating the order.
-- If rows_reserved = 0, execute ROLLBACK and report out of stock.
```

The application must check the result before proceeding. If exactly one row was updated, it can create the order and order item within the same transaction.

The following example uses the actual Heywizzle column names and valid enum values. It assumes the application has already validated the customer and product, obtained their IDs and the current product price, and generated a unique order reference.

```sql
-- Example values supplied by the application:
-- @customer_id
-- @product_id
-- @unit_price
-- @new_order_reference

INSERT INTO customer_order
    (customer_id, shipping_address_id, order_reference,
     total_amount, order_status)
VALUES
    (@customer_id, NULL, @new_order_reference,
     @unit_price, 'PENDING');

SET @new_order_id = LAST_INSERT_ID();

INSERT INTO order_item
    (order_id, product_id, quantity, unit_price, line_total)
VALUES
    (@new_order_id, @product_id, 1, @unit_price, @unit_price);

COMMIT;
```

In this example, `shipping_address_id` is set to `NULL` because the schema permits an order without a shipping address. If the customer has selected a saved address, the application should supply its valid `address_id`.

The order status must use the uppercase enum value `PENDING`, as defined in the `customer_order` table. The order reference must be unique because the schema defines `uq_order_reference`.

`LAST_INSERT_ID()` returns the generated `order_id` for the current database connection. In application code, the insert ID returned by the database driver can be used instead. Parameterised SQL statements should be used for values supplied by users or the application.

If either insert fails, the application must execute `ROLLBACK`. Because the inventory update and order inserts belong to the same InnoDB transaction, the stock deduction is also undone.

```sql
ROLLBACK;
```

### 6.3 Example using the Heywizzle product SKU

The supplied sample data includes the product SKU `HWZ-ELEC-001` for Wireless Headphones. A product can be identified by its unique SKU rather than assuming that it has a particular generated `product_id`.

```sql
SELECT product_id, product_name, price
FROM product
WHERE sku = 'HWZ-ELEC-001'
  AND is_active = TRUE;
```

After retrieving the `product_id` and price, the application can use them in the conditional stock-reservation and order-creation transaction.

### 6.4 Alternative: row-level lock with SELECT ... FOR UPDATE

```sql
START TRANSACTION;

SELECT quantity_on_hand
FROM inventory
WHERE product_id = 1
FOR UPDATE;

-- The application checks the returned quantity.
-- If quantity_on_hand is sufficient, perform the update:

UPDATE inventory
SET quantity_on_hand = quantity_on_hand - 1
WHERE product_id = 1
  AND quantity_on_hand >= 1;

SELECT ROW_COUNT() AS rows_updated;

-- Continue only if exactly one row was updated.
-- Insert customer_order and order_item records here.
-- If stock is insufficient or an insert fails, ROLLBACK.

ROLLBACK;
```

This is a demonstration, so the transaction ends with `ROLLBACK` to preserve the sample data. In a real application, the transaction should be committed only after the application has confirmed that the stock update and all required order inserts succeeded.

`SELECT ... FOR UPDATE` locks the selected record against conflicting modifications until the transaction ends. The application must check the quantity after obtaining the lock. For multi-product orders, inventory rows should be processed in a consistent order, such as ascending `product_id`, to reduce deadlock risk.

## 7. COMMIT, ROLLBACK, and Savepoints

### 7.1 COMMIT

`COMMIT` makes successful changes in the current transaction permanent.

```sql
START TRANSACTION;

UPDATE inventory
SET quantity_on_hand = quantity_on_hand - 1
WHERE product_id = 1
  AND quantity_on_hand >= 1;

SELECT ROW_COUNT() AS rows_updated;

-- The application must verify that exactly one row was updated.
-- If successful and all required operations are complete:
COMMIT;
```

### 7.2 ROLLBACK

`ROLLBACK` cancels changes made in the current uncommitted transaction.

```sql
START TRANSACTION;

UPDATE inventory
SET quantity_on_hand = quantity_on_hand - 1
WHERE product_id = 1
  AND quantity_on_hand >= 1;

-- Suppose a later order validation or insert fails:
ROLLBACK;
```

After rollback, the inventory quantity returns to its prior committed value, provided the table uses InnoDB and the changes were part of the same transaction.

### 7.3 Savepoints

A savepoint allows part of a transaction to be rolled back while retaining earlier work.

```sql
START TRANSACTION;

-- Required order operations go here.

SAVEPOINT optional_step;

-- Attempt an optional operation.
-- If it fails:
ROLLBACK TO SAVEPOINT optional_step;

-- Continue only if business rules permit.
COMMIT;
```

A savepoint should not be used to conceal the failure of an essential operation such as stock reservation or order creation. A savepoint does not commit the transaction.

## 8. Isolation Levels

| Isolation level | General behaviour in InnoDB | Example concern |
|---|---|---|
| `READ UNCOMMITTED` | Allows reads that may include uncommitted changes from other transactions. | Dirty reads are possible; generally unsuitable for order processing. |
| `READ COMMITTED` | Each consistent read gets a fresh snapshot of committed data. | Repeated reads in one transaction may return different committed values. |
| `REPEATABLE READ` | The normal MySQL default; consistent reads in a transaction use a stable snapshot. | Locking reads and writes still acquire locks. Applications must understand the difference between snapshot reads and current reads. |
| `SERIALIZABLE` | Provides stricter isolation. InnoDB may convert plain `SELECT` statements to locking reads when autocommit is disabled. | More blocking and deadlocks may occur; applications must handle transaction failures. |

The default MySQL isolation level is normally `REPEATABLE READ`. For stock reservation, a conditional `UPDATE` or `SELECT ... FOR UPDATE` is generally more appropriate than relying only on a consistent, non-locking `SELECT`.

The isolation level can be changed for the next transaction:

```sql
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
START TRANSACTION;

-- Read and modify related records here.

COMMIT;
```

`SET TRANSACTION` changes the isolation level for the next transaction when used without `SESSION` or `GLOBAL`. The statement must be issued before the transaction starts. Applications should handle deadlocks and other transaction errors, and retry the entire transaction when a retry is safe.

## 9. Locking Mechanisms

### 9.1 Row-level locks

InnoDB supports row-level locking for transactional data. `SELECT ... FOR UPDATE` is used when a transaction intends to modify selected rows. Locks are generally held until the transaction commits or rolls back.

The Heywizzle database has indexes and unique keys that support common lookups. For example, `inventory.product_id` is unique, and `product.sku` is unique. These help the database locate individual product and inventory records efficiently.

### 9.2 Table-level locks

MySQL supports explicit table locks through `LOCK TABLES`, but these are generally not the preferred mechanism for normal InnoDB checkout operations. Table-level locking can restrict concurrent access and reduce throughput. InnoDB row-level locking is normally more suitable for inventory updates.

### 9.3 Optimistic concurrency control

Optimistic concurrency control allows an application to detect whether a record has changed since it was read. The current Heywizzle schema does not contain a version column in `inventory`. Therefore, the following is an optional schema extension, not a query that can be run against the supplied schema until the column has been added.

```sql
-- Optional extension: run only if this feature is required.
ALTER TABLE inventory
ADD COLUMN version_number BIGINT NOT NULL DEFAULT 0;

-- Example optimistic update after the column has been added:
UPDATE inventory
SET quantity_on_hand = quantity_on_hand - 1,
    version_number = version_number + 1
WHERE product_id = 1
  AND version_number = 5
  AND quantity_on_hand >= 1;

SELECT ROW_COUNT() AS rows_updated;
```

If no row is updated, another transaction may have changed the row, the supplied version may be stale, or stock may be insufficient. The application should re-read the record and decide whether to retry. This approach requires the optional `version_number` column and a defined retry policy. The standard conditional-update approach in Section 6 does not require this extension.

## 10. Deadlocks

A deadlock occurs when transactions each hold a lock that another transaction needs, creating a cycle in which none can proceed.

### 10.1 Example

- Transaction A locks the inventory row for Product 1, then requests the inventory row for Product 2.
- Transaction B locks the inventory row for Product 2, then requests the inventory row for Product 1.
- Each transaction waits for the other to release its lock.

InnoDB detects deadlocks and normally rolls back one of the transactions. The application should handle the error and, where appropriate, retry the entire transaction.

### 10.2 Deadlock prevention and recovery

1. Acquire inventory locks in a consistent order, such as ascending `product_id`.
2. Keep transactions short.
3. Avoid user interaction while locks are held.
4. Update only necessary rows.
5. Use suitable indexes for the conditions in locking and update statements.
6. Handle deadlock errors and retry the entire transaction when safe.

A deadlock victim commonly receives MySQL error 1213 (`SQLSTATE 40001`). A lock-wait timeout is a different condition, commonly error 1205. Applications should distinguish these cases, roll back as required, and use a bounded retry policy with a short delay. External payment-provider operations must not be blindly repeated.

## 11. Practical Testing Plan

Tests can be performed using two separate MySQL client sessions or database connections. Use a test database and confirm that the relevant tables use InnoDB. The supplied SQL file creates the tables using InnoDB.

| Test | Procedure | Expected result |
|---|---|---|
| Test 1: Commit | Begin a transaction, make a valid stock change, and commit. | The change remains visible to a new transaction. |
| Test 2: Rollback | Begin a transaction, change stock, and roll back. | Stock returns to its prior committed value. |
| Test 3: Insufficient stock | Reserve more units than are available using a conditional update. | `ROW_COUNT()` is zero; no order is committed. |
| Test 4: Concurrent last-unit purchase | Set test stock to one and have two sessions reserve one unit concurrently. | Only one reservation succeeds; stock is not negative. |
| Test 5: Row lock | Session A selects an inventory row `FOR UPDATE`; Session B updates that row. | Session B waits until Session A commits or rolls back. |
| Test 6: Deadlock | Two sessions lock two inventory rows in opposite order. | InnoDB detects the deadlock and rolls back one transaction. |
| Test 7: Serializable conflict | Run conflicting transactions at `SERIALIZABLE`. | Operations may block or fail; the application handles the error and retries where appropriate. |

### 11.1 Two-session last-unit test

Run this experiment in a test database. Reset the test stock before the experiment and ensure no other process is modifying the selected product. The example uses `product_id = 1`, matching the demonstration identifier used in the supplied SQL script.

#### Preparation

```sql
UPDATE inventory
SET quantity_on_hand = 1
WHERE product_id = 1;
```

#### Session A

```sql
START TRANSACTION;

UPDATE inventory
SET quantity_on_hand = quantity_on_hand - 1
WHERE product_id = 1
  AND quantity_on_hand >= 1;

SELECT ROW_COUNT() AS rows_reserved;

-- Leave the transaction open temporarily.
```

#### Session B, while Session A is still open

```sql
START TRANSACTION;

UPDATE inventory
SET quantity_on_hand = quantity_on_hand - 1
WHERE product_id = 1
  AND quantity_on_hand >= 1;

SELECT ROW_COUNT() AS rows_reserved;
```

Session B should wait because both transactions are attempting to update the same inventory row.

#### Finish Session A

```sql
COMMIT;
```

After Session A commits, Session B proceeds and evaluates the condition against the current row value. Since the quantity is now zero, Session B updates zero rows.

#### Finish Session B

```sql
-- If ROW_COUNT() was zero, the reservation failed:
ROLLBACK;
```

**Expected outcome:** Exactly one transaction reserves the unit. The final stock is zero, and overselling is prevented. Capture the results from both sessions as portfolio evidence.

## 12. Application-Level Conflict Handling

A practical checkout workflow for the Heywizzle database is:

1. Begin an InnoDB transaction.
2. Validate the customer using `customer` and confirm that `account_status` is `ACTIVE`.
3. Validate the product using `product`, confirming that `is_active` is `TRUE`.
4. Attempt a conditional stock reservation in `inventory`.
5. Immediately check `ROW_COUNT()`.
6. If no inventory row was updated, roll back and report that the product is out of stock.
7. Insert the order into `customer_order`, using a unique `order_reference` and a valid `order_status` enum value such as `PENDING`.
8. Insert the purchased product or products into `order_item`, supplying `quantity`, `unit_price`, and `line_total`.
9. Record a database-side payment attempt in `payment` when appropriate, using a valid `payment_method` and `payment_status`.
10. Commit if all required database operations succeed.
11. If a database error occurs, roll back the transaction.
12. Retry only errors that are safe to retry, such as deadlocks, using a bounded retry policy.

The `customer_order.order_status` values are `PENDING`, `PROCESSING`, `SHIPPED`, `DELIVERED`, and `CANCELLED`. The `payment.payment_status` values are `PENDING`, `SUCCESSFUL`, `FAILED`, and `REFUNDED`. The application must use these defined values rather than lowercase or unsupported status strings.

For payment-provider integrations, use idempotency keys and reconcile payment outcomes. The `payment` table includes a unique `payment_reference`, which can help prevent duplicate payment-reference records. However, a database rollback cannot reverse a charge completed by an external provider. Payment processing should therefore be coordinated through explicit payment states and reliable reconciliation.

## 13. Security and Reliability Considerations

- Use parameterised SQL statements or prepared statements to reduce SQL injection risk.
- Grant the application only the database privileges it needs.
- Do not store raw payment-card details or plaintext passwords. The `customer` table stores `password_hash`, not a plaintext password.
- Ensure all tables involved in transactions use InnoDB.
- Keep transactions short to reduce lock duration.
- Monitor long-running transactions, lock waits, deadlocks, and failed retries.
- Maintain backups and test recovery procedures.
- Use a test database for concurrency experiments.
- Use the unique order, payment, SKU, and tracking references defined in the schema to help prevent duplicate records.
- Use appropriate indexes on columns used by transactional queries. The supplied schema includes indexes for inventory products, order dates and statuses, order items, and payment lookups.
- Use only the defined enum values for order, payment, delivery, and customer account statuses.

## 14. Conclusion

This portfolio examined how transactions and concurrency controls support reliable e-commerce operations at Heywizzle Limited using the actual `heywizzle_db` schema, MySQL 8.0.18+, and InnoDB. The database's existing foreign keys, unique constraints, check constraints, and indexes provide important foundations for data integrity.

ACID properties support dependable transaction processing. Conditional stock updates and row-level locks help prevent overselling, while `COMMIT`, `ROLLBACK`, and savepoints support controlled database changes. The portfolio also considered MySQL isolation levels, optional optimistic concurrency control, deadlocks, and a practical two-session test for simultaneous purchases.

By applying these techniques to the actual `inventory`, `customer_order`, `order_item`, and `payment` tables, Heywizzle Limited can process concurrent customer orders more safely while maintaining accurate stock and order records. This provides a foundation for implementing transaction-safe checkout operations in the wider e-commerce database system.

