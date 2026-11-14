# Heywizzle Limited — Portfolio 5: Distributed and Cloud Database Exercise

## 1. Introduction

Heywizzle Limited is an e-commerce business that manages product information, customer accounts, orders, payments, stock levels, and delivery records. As the business grows, its database must support increasing traffic and data volumes while keeping information accurate and available.

This portfolio investigates how distributed and cloud-based database systems can support Heywizzle Limited's operations. It builds on the earlier portfolios, which use **MySQL** for the relational database, query processing and optimisation, and transaction/concurrency exercises.

The portfolio focuses on distributed database concepts, replication and synchronisation, partitioning and sharding, cloud deployment, availability, scalability, and fault tolerance. The examples are conceptual and illustrative; they do not imply that Heywizzle Limited has already deployed a production cloud database.

## 2. Aim and Objectives

### Aim

To evaluate how distributed and cloud database technologies can improve the scalability, availability, and resilience of Heywizzle Limited's e-commerce database.

### Objectives

- Explain distributed database concepts and their relevance to e-commerce.
- Explore database replication and synchronisation approaches.
- Examine partitioning and sharding strategies for growing datasets.
- Investigate cloud database deployment options.
- Evaluate availability, scalability, backup, recovery, and fault-tolerance considerations.
- Recommend a suitable database architecture for Heywizzle Limited.

## 3. Heywizzle Limited's Database Requirements

The database supports the following core entities and operations:

| Data area | Example information | Operational requirement |
|---|---|---|
| Products | Product ID, name, category, price, attributes | Fast product browsing and search |
| Customers | Customer ID, contact details, account information | Secure access and reliable updates |
| Orders | Order ID, customer, items, totals, status | Consistent order creation and updates |
| Payments | Payment ID, order, amount, payment status | Accurate and auditable payment records |
| Stock | Product ID, available quantity, reservations | Prevent overselling during concurrent purchases |
| Deliveries | Delivery ID, order, address, tracking status | Timely delivery updates |

The system needs to preserve transactional correctness, especially when an order is placed and stock is reserved. Replication and distribution must not introduce inconsistent stock counts, duplicate payments, or conflicting order statuses.

## 4. Distributed Database Concepts

A distributed database stores data across multiple computers or database nodes that communicate over a network. Depending on the architecture, the nodes may store copies of the same data or different portions of the dataset.

### 4.1 Centralised and distributed databases

A centralised database stores the primary dataset on one database server. It is straightforward to administer, but that server can become a performance bottleneck or a single point of failure.

A distributed database can spread data or database responsibilities across several nodes. This can improve read capacity, resilience, and geographic reach, but adds complexity around consistency, network failures, monitoring, and administration.

### 4.2 Common distributed database architectures

- **Primary-replica architecture:** One primary node accepts writes while one or more replicas serve reads or provide failover.
- **Multi-primary architecture:** Multiple nodes can accept writes. Conflict detection and resolution are required when changes overlap.
- **Shared-nothing architecture:** Each node has its own CPU, memory, and storage, with data distributed across nodes.
- **Federated database:** Multiple independent databases are presented through a common access layer while retaining some local autonomy.

For Heywizzle Limited, a primary database with read replicas is a practical starting point. It keeps order and stock writes controlled while allowing read-heavy product browsing and reporting workloads to scale.

## 5. Database Replication and Synchronisation

Replication copies database data from one node to another. It can improve read performance and help maintain service during a node failure. Replication is not a substitute for backups: accidental deletion or corruption can also be replicated.

### 5.1 Replication approaches

| Approach | Description | Potential use at Heywizzle |
|---|---|---|
| Synchronous replication | A write is acknowledged after required replica confirmation | Stronger durability for selected critical operations, subject to latency and configuration |
| Asynchronous replication | The primary acknowledges a write before replicas necessarily receive it | Read scaling and disaster-recovery replicas where some replication lag is acceptable |
| Semi-synchronous replication | The primary waits for confirmation from at least one replica, depending on configuration | A balance between durability and response time |

### 5.2 Replication and synchronisation considerations

Replication may be implemented using database-native mechanisms or managed cloud database services. Important considerations include:

- **Replication lag:** A replica may not immediately contain the latest committed changes.
- **Read-after-write behaviour:** A customer should see their newly placed order or updated account details without being misled by stale replica data.
- **Failover:** If the primary becomes unavailable, a replica may be promoted. Applications must reconnect safely.
- **Conflict handling:** Multi-primary systems need rules for resolving simultaneous updates.
- **Monitoring:** Replication health and lag should be monitored and alerts configured.

For example, product catalogue pages may tolerate small replica delays. However, stock reservation and payment confirmation should use a transactionally consistent write path rather than relying on a potentially stale read replica.

## 6. Data Partitioning and Sharding

Partitioning divides a dataset into smaller logical or physical parts. Sharding commonly refers to distributing those parts across different database servers or nodes.

### 6.1 Partitioning strategies

| Strategy | How it works | Heywizzle example |
|---|---|---|
| Range partitioning | Records are grouped by ranges of a key | Orders partitioned by order date |
| List partitioning | Records are grouped by specified values | Orders grouped by region or order status, where appropriate |
| Hash partitioning | A hash function assigns records to partitions | Customer or order records distributed by ID |
| Horizontal partitioning | Different rows are stored in different partitions | Orders divided by date or customer range |
| Vertical partitioning | Different columns or groups of columns are separated | Frequently used product fields separated from large descriptions or media metadata |

### 6.2 Possible sharding key

A possible sharding key for order data is `order_id` or a customer-related identifier. The choice affects query routing and workload distribution.

A good sharding key should:

- Distribute writes and storage reasonably evenly.
- Avoid creating a heavily overloaded shard.
- Support common application queries.
- Minimise cross-shard transactions and joins.
- Be stable and difficult to change.

Sharding introduces operational complexity. Rebalancing data, maintaining global uniqueness, backing up multiple shards, and executing cross-shard queries all require careful planning. It should be considered when a single database instance and its read replicas no longer meet the required workload.

## 7. Cloud Database Deployment

A cloud database is hosted on cloud infrastructure and can be provisioned, monitored, backed up, and scaled through cloud services. A managed relational database service can reduce the operational burden of maintaining database servers.

### 7.1 Deployment options

| Option | Advantages | Considerations |
|---|---|---|
| Self-managed MySQL on a cloud virtual machine | High configuration control; familiar MySQL environment | The business manages patching, backups, failover, monitoring, and server maintenance |
| Managed MySQL-compatible relational database | Managed backups, maintenance options, monitoring, and deployment features | Service limits, pricing, configuration, and provider-specific behaviour must be reviewed |
| Cloud-native distributed relational database | Can offer automated distribution and high availability | May involve greater cost, migration effort, or compatibility differences |
| Database-as-a-Service with read replicas | Easier read scaling and managed replica lifecycle | Replica lag and read/write routing still need application consideration |

### 7.2 Example cloud deployment

An illustrative deployment using a managed MySQL-compatible service could include:

1. Deploy the database in a private network rather than exposing it directly to the public internet.
2. Configure the application to connect through a controlled database endpoint.
3. Use high-availability deployment across separate availability zones where supported and appropriate.
4. Enable automated backups and define a retention period.
5. Add read replicas for suitable read-heavy workloads.
6. Store credentials securely and rotate them according to policy.
7. Monitor database connections, CPU, storage, query latency, replication lag, and failover events.
8. Test restoration and failover procedures.

The exact cloud provider and service should be selected based on compatibility, availability requirements, budget, regional support, and operational skills.

## 8. Availability, Scalability, and Fault Tolerance

### 8.1 Availability

Availability is the ability of the database service to respond to valid requests when required. High availability may be supported by redundant database nodes, health checks, automated failover, and deployment across availability zones.

### 8.2 Scalability

- **Vertical scaling:** Increase the CPU, memory, or storage capacity of a database instance.
- **Horizontal read scaling:** Add replicas to distribute read traffic.
- **Horizontal write scaling:** Distribute writes across shards or nodes, usually with additional application and data-management complexity.

For Heywizzle, vertical scaling and read replicas are likely to be simpler initial options than sharding.

### 8.3 Fault tolerance

Fault tolerance is the ability to continue operating, or recover within an acceptable period, after a component fails. Potential failures include database instance failure, availability-zone outage, network interruption, accidental deletion, and data corruption.

A resilient design should combine:

- Multi-zone database deployment or equivalent redundancy.
- Automated failover where supported.
- Automated backups and point-in-time recovery.
- Periodic restore tests.
- Application retry logic with bounded retries and idempotency.
- Monitoring, alerting, and documented recovery procedures.

**Important distinction:** High availability helps reduce service interruption. Backups help recover data. Replication can support availability and read scaling, but by itself does not protect against every form of data loss.

## 9. Consistency and Transactional Integrity

Heywizzle's order workflow requires related updates to be handled reliably. For example, creating an order and reserving stock should be coordinated so that two customers cannot successfully purchase the same final unit.

A simplified MySQL transaction could be:

```sql
START TRANSACTION;

-- Reserve stock only if sufficient quantity remains.
UPDATE products
SET stock_quantity = stock_quantity - 1
WHERE product_id = 101
  AND stock_quantity >= 1;

-- The application must verify that exactly one row was updated.
-- It should create the order and order-item records only when
-- the stock reservation succeeds.

COMMIT;
```

This is an illustrative fragment, not a complete checkout implementation. The application must check the affected-row count, handle failures with `ROLLBACK`, and ensure order creation, stock reservation, and payment processing follow a safe workflow. Payment-provider calls are normally handled with an idempotent application workflow rather than held inside a long-running database transaction.

In a distributed environment, the design should also consider:

- Whether a transaction is confined to one database node or crosses shards.
- Whether reads are served from the primary or a replica.
- How retries avoid duplicate orders or payments.
- How the application responds when a commit succeeds but the connection drops before the response is received.

## 10. Security and Data Protection

A cloud database deployment should include the following controls:

- Private network access and restrictive firewall/security-group rules.
- Encryption in transit using TLS and encryption at rest.
- Least-privilege database accounts for application and administration tasks.
- Secure credential storage; credentials should not be committed to source control.
- Auditing and monitoring of privileged access and important database events.
- Backup retention and recovery controls appropriate to business requirements.
- Protection of customer and payment-related data in accordance with applicable legal and organisational requirements.

Payment card details should be handled by a compliant payment provider where possible; Heywizzle should avoid storing sensitive card data unless it has a justified, compliant design.

## 11. Evaluation of Cloud Database Solutions for Heywizzle Limited

A managed MySQL-compatible relational database is a strong candidate because the existing coursework database is based on MySQL and the core operations depend on relational integrity and transactions.

### Benefits

- Reduced responsibility for database server maintenance.
- Managed backup and monitoring capabilities, depending on the service.
- Options for high availability and read replicas.
- Ability to scale compute and storage as demand increases.
- Familiar SQL and relational data modelling.

### Limitations and risks

- Managed services may cost more than a small self-managed server.
- Provider-specific features can increase migration complexity.
- Replicas can return stale data if replication is asynchronous.
- Failover may interrupt active connections.
- Sharding and distributed transactions add significant complexity.
- Cloud access, credentials, configuration, and backups must be secured.

### Recommendation

Heywizzle Limited should begin with a managed MySQL-compatible relational database configured for private access, automated backups, monitoring, and high availability appropriate to its service requirements. The primary database should handle transactional writes for orders, payments, and stock reservations. Read replicas can be introduced for catalogue browsing and reporting where eventual consistency is acceptable.

The business should adopt partitioning when table size or query performance justifies it, and consider sharding only after monitoring shows that vertical scaling and read replicas are insufficient. This staged approach preserves the benefits of MySQL while avoiding premature distributed-system complexity.

## 12. Practical Exercise and Evidence

The following activities can be used to demonstrate the portfolio. They should be completed in a test environment, not against live customer or payment data.

- [ ] Draw a diagram showing the application, primary database, replica(s), and cloud network.
- [ ] Explain which Heywizzle operations use the primary and which may use replicas.
- [ ] Compare synchronous and asynchronous replication in terms of consistency, latency, and availability.
- [ ] Choose a partitioning strategy for historical orders and justify the key.
- [ ] Identify a possible sharding key and discuss its limitations.
- [ ] Compare self-managed MySQL with a managed MySQL-compatible service.
- [ ] Describe a failover scenario and how the application reconnects.
- [ ] Define a backup and restore test, including a recovery objective.
- [ ] Record the results of a test or simulation, including any limitations.

### Suggested evidence

1. Distributed database architecture diagram.
2. Replication and synchronisation comparison table.
3. Partitioning/sharding design and rationale.
4. Cloud deployment configuration or annotated deployment plan.
5. Backup, recovery, and failover test notes.
6. Evaluation and recommendation for Heywizzle Limited.

## 13. Conclusion

This portfolio has explored how distributed and cloud database technologies can support Heywizzle Limited as its e-commerce operations grow. Replication can improve read capacity and resilience, while partitioning and sharding can help manage larger datasets and workloads. Cloud database services can reduce infrastructure-management effort and provide capabilities for backups, monitoring, scaling, and high availability.

However, distribution introduces challenges involving consistency, replication lag, failover, network failures, and operational complexity. For Heywizzle Limited, a managed MySQL-compatible relational database with private networking, robust backups, and suitable high availability is a practical initial solution. Read replicas and partitioning can be added as demand grows, with sharding reserved for a demonstrated need.



