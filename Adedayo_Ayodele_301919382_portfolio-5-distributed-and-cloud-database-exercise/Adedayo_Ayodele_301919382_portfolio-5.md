# Heywizzle Limited — Portfolio 5: Distributed and Cloud Database Exercise

## 1. Introduction

Heywizzle Limited operates an e-commerce database that stores product, customer, order, payment, stock, and delivery information. As customer numbers, product records, and online transactions increase, a single database server may experience higher workloads and become a point of failure.

This portfolio examines how Heywizzle Limited could use distributed and cloud database technologies to improve database availability, scalability, and resilience while preserving accurate business transactions. It builds on the earlier portfolios, which use **MySQL** as the relational database platform.

This document presents a case-study design and deployment exercise. Configuration examples are proposed test configurations; they should only be described as implemented or tested after the relevant work has actually been carried out.

## 2. Aim and Objectives

### Aim

To design and evaluate a distributed/cloud database approach for Heywizzle Limited, demonstrating how replication, sharding, availability, consistency, and cloud deployment can support its e-commerce operations.

### Objectives

- Explain why a distributed or cloud database may be required by Heywizzle Limited.
- Design a primary-and-replica database arrangement.
- Examine how replication keeps database copies synchronised.
- Propose a suitable partitioning or sharding strategy.
- Explain availability, fault tolerance, and recovery.
- Evaluate consistency requirements for orders, payments, and stock.
- Identify practical deployment evidence that can demonstrate the proposed solution.

## 3. Case Study and Database Workload

| Database area | Example data | Important business operation |
|---|---|---|
| Products | Product ID, name, category, price, attributes | Browse and search the catalogue |
| Customers | Customer ID, name, email, contact details | Register and manage customer accounts |
| Orders | Order ID, customer ID, order date, status, total | Place and track orders |
| Order items | Order ID, product ID, quantity, unit price | Record products purchased |
| Payments | Payment ID, order ID, amount, payment status | Record payment outcomes |
| Stock | Product ID, available quantity | Reserve and update stock |
| Deliveries | Delivery ID, order ID, tracking status | Track fulfilment and delivery |

Product browsing and catalogue searches generate frequent reads. Checkout, payment updates, and stock reservations generate writes that must be accurate. Historical order reports may involve large datasets but do not normally require the same response time as checkout.

A suitable design should scale read-heavy workloads without weakening the consistency of critical transactions.

## 4. Proposed Distributed Database Architecture

### 4.1 Architecture overview

The proposed design uses a MySQL-compatible primary database and one or more read replicas. The primary handles transactional writes, while replicas can serve suitable read-only requests. The database is hosted in a private cloud network and accessed by the e-commerce application through a controlled connection.

```text
                 Customers / Web Browser
                           |
                           v
                  Heywizzle E-commerce
                       Application
                           |
                    Database Connection
                           |
                           v
                +----------------------+
                |   MySQL Primary      |
                |  Read and Write      |
                | Products, Customers  |
                | Orders, Payments     |
                | Stock, Deliveries    |
                +----------------------+
                           |
                    Replication Stream
                           |
              +------------+------------+
              |                         |
              v                         v
       +---------------+         +---------------+
       | Read Replica 1|         | Read Replica 2|
       | Catalogue reads|        | Reports/reads  |
       +---------------+         +---------------+

        Private cloud network, monitoring,
        automated backups and recovery
```

**Figure 1: Proposed primary-and-replica architecture for Heywizzle Limited.**

### 4.2 Roles of the database nodes

| Component | Responsibility |
|---|---|
| Primary database | Accepts inserts, updates, and deletes for business transactions |
| Read replica 1 | Serves suitable product catalogue and other read-heavy requests |
| Read replica 2 | Serves reporting or additional read workloads, if required |
| Backup/recovery service | Provides backup retention and restoration capability |
| Monitoring service | Tracks database health, resource usage, connections, and replication delay |

The application must distinguish read and write operations. Checkout, stock reservation, payment status changes, and other critical updates should use the primary database. Reads that can tolerate a short delay may use a replica.

## 5. Database Replication and Synchronisation

Replication copies database changes from a source database to one or more replica databases. It can improve read capacity and support recovery or failover arrangements.

### 5.1 Replication options

| Replication type | Explanation | Suitability for Heywizzle |
|---|---|---|
| Asynchronous | The primary commits without waiting for a replica to confirm the change | Suitable for catalogue reads and reporting where a small delay is acceptable |
| Semi-synchronous | The primary waits for acknowledgement from at least one replica, subject to configuration | May improve protection against losing recent transactions, with some latency cost |
| Synchronous | A transaction is acknowledged only after required replicas confirm it | Offers stronger synchronisation but can increase latency and make writes dependent on replica/network availability |

The exact replication modes and guarantees depend on the MySQL version and cloud service configuration. Managed services may implement replication and failover differently from manually configured MySQL servers.

### 5.2 Replication flow

1. A customer places an order through the Heywizzle application.
2. The application sends the order and stock updates to the primary database.
3. The primary commits the transaction.
4. The replication mechanism sends the changes to the replicas.
5. A replica applies the changes and becomes available for suitable read requests.
6. Monitoring checks replica health and replication delay.

### 5.3 Replication lag

With asynchronous replication, a replica may temporarily contain older data. For example, a customer may place an order and immediately open the order history page. If that page reads from a lagging replica, the new order might not appear straight away.

To reduce this risk:

- Read a newly created order from the primary after checkout.
- Route stock checks and other critical decisions to the primary.
- Use replicas for data that can tolerate eventual consistency.
- Monitor replication lag and stop routing suitable traffic to an unhealthy or delayed replica.
- Do not assume that a successful write to the primary means every replica has already applied it.

**Case-study decision:** Heywizzle should use the primary database for order, payment, and stock writes. Read replicas should be used for catalogue browsing and reporting only when their consistency requirements permit it.

## 6. Data Partitioning and Sharding

Partitioning divides a large table into smaller sections. Sharding distributes portions of a dataset across separate database servers or nodes. Sharding is a form of horizontal distribution and normally requires application-level or database-platform support to route queries to the correct shard.

### 6.1 Partitioning options

| Strategy | Description | Heywizzle example |
|---|---|---|
| Range | Divides rows according to ranges of values | Orders grouped by order date |
| List | Divides rows according to specified values | Records grouped by an agreed region code |
| Hash | Uses a hash function to distribute rows | Customer records distributed using customer ID |
| Horizontal | Separates rows into groups | Different ranges of orders stored in different partitions |
| Vertical | Separates columns into groups | Frequently accessed product details separated from large descriptive fields |

For historical orders, range partitioning by order date may make it easier to manage older records and support date-based queries. The design must take account of MySQL's rules for partitioning, indexes, keys, and foreign keys.

### 6.2 Proposed sharding approach

If customer and order data eventually becomes too large for one database cluster, Heywizzle could distribute customers and their orders across multiple shards.

```text
                 Heywizzle Application
                           |
                    Shard Router
                           |
             Hash(customer_id) mod 2
                    /          \
                   v            v
          +-------------+  +-------------+
          |   Shard 1   |  |   Shard 2   |
          | Customers   |  | Customers   |
          | Orders      |  | Orders      |
          | Order Items |  | Order Items |
          +-------------+  +-------------+
```

For example, the application could calculate a shard number from the customer ID and route that customer's order-related data to the selected shard. This is a conceptual example; the hash function, shard count, routing mechanism, and key management must be designed and tested before implementation.

Sharding considerations include:

- **Even distribution:** Avoid assigning most active customers to one shard.
- **Query routing:** The application must know which shard contains the requested data.
- **Cross-shard queries:** Reports covering all customers may need to query multiple shards.
- **Transactions:** A transaction spanning multiple shards is more difficult to coordinate.
- **Rebalancing:** Adding or removing shards may require moving existing records.
- **Uniqueness:** IDs must remain unique across the distributed system.

**Case-study decision:** Sharding is not necessary for the initial design. Heywizzle should first consider indexing, query optimisation, vertical scaling, read replicas, and table partitioning. Sharding should be introduced only when measured workload or storage requirements justify the added complexity.

## 7. Availability, Fault Tolerance, and Recovery

### 7.1 Availability

Availability describes whether the database service can respond to application requests when required. A database hosted on a single server may become unavailable if that server fails.

A cloud database can improve availability through redundant infrastructure, health monitoring, and automated failover. For example, a managed relational database may support a standby database in another availability zone. The exact behaviour depends on the selected service and deployment configuration.

### 7.2 Fault-tolerance scenarios

| Failure scenario | Possible impact | Proposed response |
|---|---|---|
| Primary database failure | Application cannot complete database operations | Promote or fail over to a suitable standby/replica and reconnect the application |
| Availability-zone outage | Database resources in the affected zone may be unavailable | Use a supported multi-zone deployment |
| Network interruption | Application loses database connectivity | Use bounded retries, connection timeouts, and health checks |
| Accidental data deletion | Business records may be lost or altered | Restore from backup or use point-in-time recovery |
| Replica failure | Read capacity is reduced | Stop sending reads to the failed replica and restore or replace it |
| Storage capacity reached | Writes may fail | Monitor storage and scale capacity before the limit is reached |

### 7.3 Backup and recovery

Replication is not a replacement for backup. If a user accidentally deletes an order on the primary, that deletion may also be replicated. Backups provide a separate recovery path.

Heywizzle should enable automated backups, select an appropriate retention period, enable point-in-time recovery if supported and required, restrict backup access, test restoration periodically, and document who can authorise recovery.

Two important recovery measurements are:

- **Recovery Point Objective (RPO):** The maximum acceptable amount of data loss measured in time.
- **Recovery Time Objective (RTO):** The maximum acceptable time to restore the service.

The business should agree suitable RPO and RTO values based on the impact of losing recent orders or being unable to process checkout. These values should be measured through recovery tests rather than assumed from a service description.

## 8. Consistency and Transactional Integrity

Consistency means that database operations preserve the rules and relationships defined for the data. For Heywizzle, order, payment, and stock information must remain reliable even when several customers make purchases at the same time.

### 8.1 Consistency requirements

| Operation | Required behaviour | Recommended database path |
|---|---|---|
| Product catalogue browsing | A small delay in displaying a product update may be acceptable | Read replica, where appropriate |
| Customer profile update | Customer should see the latest update | Primary for write and immediate confirmation |
| Order creation | Order and order items must be recorded consistently | Primary transaction |
| Stock reservation | Concurrent purchases must not oversell available stock | Primary transaction with conditional update |
| Payment status update | Status must be recorded accurately and duplicate processing prevented | Primary, with idempotent application workflow |
| Historical reporting | Slightly delayed data may be acceptable | Read replica or reporting database |

### 8.2 MySQL stock reservation example

The following SQL illustrates a conditional stock update. It assumes a `products` table with `product_id` and `stock_quantity` columns.

```sql
START TRANSACTION;

UPDATE products
SET stock_quantity = stock_quantity - 1
WHERE product_id = 101
  AND stock_quantity >= 1;

-- Application must check ROW_COUNT().
-- Continue creating the order only if exactly one row was updated.

COMMIT;
```

If no row is updated, the product may not exist or there may be insufficient stock. The application must handle this outcome and must not create a successful order for an item that was not reserved. If a later database operation in the checkout transaction fails, the application should roll back the transaction.

This is an illustrative SQL fragment, not a complete checkout implementation. Production code must also handle transaction errors, order-item insertion, unique identifiers, payment-provider responses, and safe retries. Payment-provider requests should use idempotency controls so a retry does not charge a customer twice.

### 8.3 Consistency trade-off

A primary-and-asynchronous-replica design improves read scalability but can return stale data from replicas. Using the primary for critical reads and writes reduces this risk. Stronger synchronisation can improve consistency guarantees but may increase response time and make writes dependent on network and replica availability.

For Heywizzle, transactional accuracy for stock, orders, and payments is more important than distributing every read across every database node.

## 9. Cloud Database Deployment Proposal

### 9.1 Recommended deployment option

A managed MySQL-compatible relational database is recommended as the starting point. It retains compatibility with the MySQL database used in earlier portfolios while reducing the amount of database infrastructure Heywizzle must manage.

An example implementation could use **Amazon RDS for MySQL**. Other managed MySQL-compatible services could also be evaluated.

### 9.2 Proposed deployment steps

1. Create or select a cloud account and deployment region.
2. Create a private virtual network and database subnets.
3. Provision a managed MySQL database instance.
4. Restrict database access to the application environment and authorised administrators.
5. Create the Heywizzle database and apply the existing relational schema.
6. Configure automated backups and suitable retention.
7. Configure high availability, such as a supported Multi-AZ deployment, if required by the service objectives and budget.
8. Configure a read replica if read traffic justifies it.
9. Store database credentials in a secure secrets-management service.
10. Configure application connection settings and test connectivity.
11. Enable monitoring and alerts for CPU, storage, connections, query performance, and replica lag.
12. Test backup restoration and the failover procedure.

### 9.3 Illustrative cloud deployment layout

```text
                    Internet
                       |
                Web Application
                       |
              Application/API Layer
                       |
             Private Network Connection
                       |
             +---------------------+
             | Managed MySQL       |
             | Primary Database    |
             +---------------------+
                       |
                 Replication
                       |
             +---------------------+
             | Read Replica        |
             +---------------------+

             Cloud monitoring
             Automated backups
             Recovery procedures
             Secure credentials
```

**Figure 2: Illustrative cloud deployment for Heywizzle Limited.**

The database should not be publicly accessible unless there is a specific, justified requirement and appropriate security controls. Application-to-database traffic should use encrypted connections where supported.

## 10. Deployment and Testing Evidence

The assessment requires a distributed/cloud database discussion or setup based on the same case study. The following evidence can be collected from an actual test deployment or clearly labelled as a proposed design.

| Evidence item | What to demonstrate | Suggested evidence |
|---|---|---|
| Cloud database deployment | A MySQL-compatible database has been provisioned, or a deployment plan has been documented | Cloud console screenshot or annotated architecture |
| Database connectivity | Application or MySQL client can connect | Sanitised connection test output |
| Replication | Changes on the primary appear on a replica | Primary and replica query results with timestamps |
| Sharding/partitioning | A partition or shard strategy has been designed or tested | SQL definition, routing example, or design diagram |
| Availability | How the service responds to a node or zone failure | Failover test notes or documented service configuration |
| Consistency | Critical order and stock operations preserve business rules | Transaction test results |
| Backup and recovery | A backup can be restored or a recovery procedure is documented | Restore test output or recovery plan |
| Security | Database access is restricted and credentials are protected | Sanitised network/security configuration |

### 10.1 Suggested replication demonstration

If two MySQL instances are available in a safe test environment:

1. Configure one instance as the source/primary and the second as a replica, following the instructions for the selected MySQL version.
2. Configure the required replication user and secure connection.
3. Start replication and verify its status using the replication status command appropriate to the MySQL version.
4. Insert a clearly identifiable test product on the primary.
5. Query the replica and confirm whether the record has arrived.
6. Record any replication delay and explain whether the replication mode is synchronous or asynchronous.
7. Remove the test data after completing the exercise, if appropriate.

Example test query:

```sql
INSERT INTO products
    (product_id, product_name, stock_quantity)
VALUES
    (99001, 'Replication Test Product', 10);

SELECT product_id, product_name, stock_quantity
FROM products
WHERE product_id = 99001;
```

Use column names and data types that match the actual Heywizzle schema. Do not run this example against production data. The appearance of the test record on a replica is evidence of replication only after the replication setup and test have actually been performed.

### 10.2 Suggested partitioning demonstration

The following is a conceptual MySQL example for a separate test table. MySQL partitioning has engine-specific restrictions, and the partitioning key must satisfy the relevant rules for primary and unique keys. Test the definition against the MySQL version being used before claiming it works.

```sql
CREATE TABLE order_archive_test (
    order_id BIGINT NOT NULL,
    order_date DATE NOT NULL,
    customer_id BIGINT NOT NULL,
    order_total DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (order_id, order_date)
)
PARTITION BY RANGE (YEAR(order_date)) (
    PARTITION p_before_2025 VALUES LESS THAN (2025),
    PARTITION p_2025 VALUES LESS THAN (2026),
    PARTITION p_2026 VALUES LESS THAN (2027),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);
```

This demonstrates date-based range partitioning. It is a test design, not a replacement for the existing Heywizzle orders table. A production design should be validated against the real schema, query workload, retention requirements, and MySQL partitioning limitations.

### 10.3 Suggested consistency test

In a test database:

1. Set a product's stock quantity to one.
2. Attempt two concurrent stock reservations for that product.
3. Confirm that only one transaction successfully reserves the final unit.
4. Confirm that the stock quantity does not become negative.
5. Record the SQL statements, affected-row counts, and final stock value.

This test builds on the transaction and concurrency concepts covered in Portfolio 3.

### 10.4 Evidence recording template

Complete this table after carrying out the relevant tests:

| Test | Expected result | Actual result | Status |
|---|---|---|---|
| Database connection | Authorised client connects successfully | [Record result] | [Pass/Fail/Not tested] |
| Replication | Test record appears on replica | [Record result] | [Pass/Fail/Not tested] |
| Partitioning | Test table is created and queries return correct records | [Record result] | [Pass/Fail/Not tested] |
| Stock consistency | Only valid stock reservations succeed | [Record result] | [Pass/Fail/Not tested] |
| Backup restoration | Database is restored with expected data | [Record result] | [Pass/Fail/Not tested] |
| Availability/failover | Application recovers according to configured procedure | [Record result] | [Pass/Fail/Not tested] |

Do not mark a test as passed unless it has been executed and the result recorded. If a cloud environment is not available, label the architecture, SQL, and recovery steps as a proposed design or simulation.

## 11. Evaluation and Recommendation

| Approach | Main benefit | Main limitation | Recommendation |
|---|---|---|---|
| Single MySQL instance | Simple and familiar | Limited resilience and potential capacity bottleneck | Suitable for development or an early low-volume system |
| Managed MySQL with high availability | Managed operations and improved availability | Higher cost and provider-specific configuration | Recommended starting production approach |
| Primary with read replicas | Distributes read workloads | Replica lag and additional monitoring | Add when read traffic increases |
| Table partitioning | Helps manage selected large tables | Requires careful schema and query design | Consider for large historical order tables |
| Sharding | Distributes data and writes across nodes | More complex transactions, routing, and maintenance | Defer until justified by measured scale |

### Recommendation for Heywizzle Limited

Heywizzle should adopt a staged approach:

1. Continue using MySQL as the relational database platform.
2. For cloud hosting, use a managed MySQL-compatible database with private network access, encryption, monitoring, and automated backups.
3. Configure high availability based on agreed business recovery objectives and budget.
4. Keep order creation, payment status updates, and stock reservations on the primary transactional database.
5. Add read replicas for suitable catalogue and reporting workloads when required.
6. Consider date-based partitioning for large historical order tables after testing the actual schema and query patterns.
7. Introduce sharding only if monitoring shows that a single managed database cluster cannot meet storage or performance targets.
8. Regularly test backup restoration, failover, and application reconnection.

This approach provides a practical route to cloud adoption without introducing the complexity of a fully sharded distributed database before the business needs it.

## 12. Conclusion

This portfolio has examined how distributed and cloud database technologies can support Heywizzle Limited's e-commerce operations. A primary-and-replica architecture can separate transactional writes from suitable read workloads. Partitioning can help manage large tables, while sharding can distribute data across database nodes when the business reaches a scale that justifies it.

The design must also address replication lag, transaction consistency, database availability, failover, backups, and recovery. Order, payment, and stock operations require reliable transactional handling and should not depend on potentially stale replica data.

A managed MySQL-compatible cloud database with private access, backups, monitoring, and suitable high availability is the recommended starting point. Replicas and partitioning can be introduced as the workload grows, while sharding remains a later optimisation supported by measured evidence.


