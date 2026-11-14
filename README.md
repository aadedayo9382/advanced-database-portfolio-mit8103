# Heywizzle Limited – E-commerce Database Management System

### Name:Adedayo Ayodele
### Matric Number: 2026/A/MIT/0422
### Course: Advanced Database System (MIT 8103)
### Project Title: Design and Implementation of an E-commerce Database Management System
### Selected Organisation: Heywizzle Limited
### Github Link: https://github.com/aadedayo9382/advanced-database-portfolio-mit8103



## 1. Introduction and Selected Organisation
This project focuses on Heywizzle Limited, an e-commerce organisation that sells products to customers through an online platform. The organisation requires a reliable and scalable database system to manage its daily business operations, including product registration, customer information, order processing, payment management, inventory control and delivery tracking.
The project explores how database technologies and concepts supports Heywizzle Limited's operational and business requirements. The database design considers the relationships between customers, products, orders, payments, deliveries and other relevant business entities. It also examines how relational databases, query optimisation, transaction management, NoSQL technologies and distributed database architectures can improve data integrity, performance, flexibility and availability.
The five portfolios in this project progressively address the design, implementation and evaluation of database solutions for the organisation.

## 2. Summary of the Five Portfolio Activities
## Portfolio 1: Database Design and Modelling
The first portfolio focused on analysing Heywizzle Limited's business requirements and translating them into a structured relational database design.
The activity involved identifying the organisation's major data requirements, defining relevant entities and attributes, establishing primary and foreign keys, and modelling relationships using an Entity Relationship Diagram (ERD).
The design considered essential business entities such as customers, products, orders, order items, payments, deliveries and inventory. Normalisation principles, including First Normal Form (1NF), Second Normal Form (2NF) and Third Normal Form (3NF), were applied to minimise unnecessary data duplication and improve data consistency.
The resulting relational schema provides a foundation for storing and managing the organisation's e-commerce data while maintaining referential integrity through appropriate constraints and relationships.

## Key outcomes:
-	Identified and modelled the main business entities.
-	Developed an Entity Relationship Diagram.
-	Applied database normalisation principles.
-	Defined primary keys, foreign keys and integrity constraints.
-	Produced a relational database schema based on the case study.

## Portfolio 2: Query Processing and Optimisation
The second portfolio explored how database queries are processed and how their performance can be improved using MySQL.
Using the Heywizzle Limited database scenario, the activity examined SQL operations for retrieving and manipulating business data. Queries covered product information, customer records, orders, payments and inventory.
The portfolio also explored joins, aggregate functions, filtering, grouping and views to generate useful business information. Query execution plans and indexing were considered to understand how MySQL retrieves records and how suitable indexes can reduce unnecessary data scanning.
The exercise demonstrated the importance of writing efficient SQL queries and selecting appropriate indexing strategies, particularly as the organisation's customer, product and transaction records grow.

## Key outcomes: 
-	Developed SQL queries for common e-commerce operations.
-	Applied joins, filtering, grouping and aggregate functions.
-	Explored views for presenting business information.
-	Examined query execution plans using MySQL.
-	Investigated indexing and query optimisation techniques.

## Portfolio 3: Transactions and Concurrency
The third portfolio examined transaction management and concurrency control using MySQL. It focused on maintaining data accuracy and consistency when multiple users perform operations simultaneously.
For Heywizzle Limited, transaction management is particularly important when customers place orders, make payments or purchase products with limited stock availability.
The portfolio explored the ACID properties: Atomicity, Consistency, Isolation and Durability. It also considered transaction operations such as START TRANSACTION, COMMIT and ROLLBACK, alongside locking mechanisms and isolation levels.
A practical example involved stock reservation during order processing. The objective was to prevent multiple customers from successfully purchasing the same limited stock quantity. Concurrency scenarios, including simultaneous stock updates, locking behaviour and potential deadlocks, were also considered.

## Key outcomes: 
-	Examined ACID transaction properties.
-	Applied MySQL transaction control statements.
-	Explored commit and rollback operations.
-	Investigated isolation levels and locking mechanisms.
-	Considered concurrent stock reservation and deadlock handling.

## Portfolio 4: NoSQL and Advanced Data Models
The fourth portfolio explored NoSQL databases and advanced data modelling techniques, focusing on the flexibility required by modern e-commerce platforms.
Unlike traditional relational databases, document-oriented databases can store records with varying structures. This is useful for Heywizzle Limited because different product categories may have different attributes. For example, electronic products may require specifications such as processor type and memory capacity, while clothing products may require size, colour and material.
The portfolio examined document-oriented data models, flexible product document structures and key-value database concepts. It also compared relational and NoSQL approaches, considering their strengths, limitations and suitability for different business requirements.
The discussion highlighted how a relational database can remain suitable for structured transactional information, while a document database such as MongoDB can support flexible product catalogues and category-specific attributes.

## Key outcomes: 
-	Explored document-oriented database concepts.
-	Examined flexible product document structures.
-	Considered key-value and other NoSQL data models.
-	Compared relational and NoSQL database approaches.
-	Evaluated the suitability of different data models for e-commerce operations.

## Portfolio 5: Distributed and Cloud Databases
The fifth portfolio examined how distributed and cloud database technologies could support the growth of Heywizzle Limited.
As the organisation expands, its database may need to support increased customer traffic, larger product catalogues and higher transaction volumes. A single database server may eventually become a performance or availability limitation.
The portfolio explored database replication, sharding, availability, consistency and cloud deployment. It considered a primary database with read replicas to distribute read workloads, while write operations remain coordinated through the primary database.
It also examined how sharding or partitioning could distribute large datasets, and how cloud database services such as Amazon Relational Database Service (Amazon RDS) for MySQL could support managed database deployment, backups and availability.
The activity considered important operational factors such as replication lag, recovery objectives, fault tolerance and the trade-offs between consistency, availability and performance.

## Key outcomes: 
-	Examined distributed database architecture.
-	Explored primary and read-replica replication.
-	Considered sharding and data partitioning.
-	Evaluated availability, consistency and fault tolerance.
-	Investigated cloud database deployment using Amazon RDS for MySQL.

## 3. GitHub Repository and Practical Evidence
The source code, SQL scripts, screenshot, database designs and portfolio documentation are available through the project's GitHub repository.
GitHub Repository: https://github.com/aadedayo9382/advanced-database-portfolio-mit8103

## 4. Test Tools
The following tools were used to carry out various tests described in the project 
- 1.	PhpMyAdmin (Embedded XAMMP): This was used to carry out all Mysql related tests
- 2.	MongoDB (https://cloud.mongodb.com/): This was used to carry out all NoSql related tests
- 3.	Snipping Tool: This was used to take screenshots for the different tests

## 5. Individual Reflection
Working on the five portfolios has improved my understanding of how database systems support real-world business operations. Using Heywizzle Limited as the case study helped me connect database concepts with practical e-commerce requirements.
The database design activity demonstrated the importance of understanding business requirements before creating database tables. Developing the relational model and applying normalisation principles helped me appreciate how good database design reduces duplication and maintains data integrity.
The query optimisation portfolio improved my understanding of how database performance can be affected by query structure, indexing and execution plans. I also gained a better appreciation of the importance of writing efficient queries as the volume of business data increases.
The NoSQL portfolio broadened my understanding of alternative database models and demonstrated why flexible document structures can be useful when product attributes differ across categories. Finally, the distributed database portfolio introduced important considerations around scalability, replication, availability and cloud deployment.
Overall, the activities strengthened my understanding of database design, implementation, optimisation and deployment. They also helped me recognise that selecting a database solution requires balancing performance, consistency, flexibility, availability, cost and future scalability.

## 5. References
The following technical documentation provides supporting information for the portfolio activities:
- 1.	Oracle. MySQL 8.4 Reference Manual. https://dev.mysql.com/doc/refman/8.4/en/
- 2.	Oracle. MySQL Optimisation. https://dev.mysql.com/doc/refman/8.4/en/optimization.html
- 3.	Oracle. MySQL InnoDB Transaction Model. https://dev.mysql.com/doc/refman/8.4/en/innodb-transaction-model.html
- 4.	MongoDB. MongoDB Manual – Documents. https://www.mongodb.com/docs/manual/core/document/
- 5.	MongoDB. Data Modelling. https://www.mongodb.com/docs/manual/data-modeling/
- 6.	Amazon Web Services. Amazon RDS for MySQL. https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_MySQL.html
- 7.	Amazon Web Services. Working with MySQL Read Replicas. https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_ReadRepl.html


## 6. Declaration of AI Tool Usage
AI tools, including ChatGPT, were used as supporting resources during the preparation of this portfolio. Their assistance included explaining database concepts, organising documentation, improving technical explanations and reviewing the structure and clarity of written content.
