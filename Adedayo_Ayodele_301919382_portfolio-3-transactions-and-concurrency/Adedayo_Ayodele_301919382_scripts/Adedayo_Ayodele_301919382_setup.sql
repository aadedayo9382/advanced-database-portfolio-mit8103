
USE heywizzle_db;

CREATE TABLE IF NOT EXISTS product (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    CONSTRAINT chk_product_price CHECK (price >= 0)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS inventory (
    product_id INT PRIMARY KEY,
    quantity_on_hand INT NOT NULL DEFAULT 0,
    version_no INT NOT NULL DEFAULT 0,
    CONSTRAINT fk_inventory_product
        FOREIGN KEY (product_id)
        REFERENCES product(product_id),
    CONSTRAINT chk_inventory_quantity
        CHECK (quantity_on_hand >= 0)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS customer_order (
    order_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    order_total DECIMAL(12,2) NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS order_item (
    order_item_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_order_item_order
        FOREIGN KEY (order_id)
        REFERENCES customer_order(order_id),
    CONSTRAINT fk_order_item_product
        FOREIGN KEY (product_id)
        REFERENCES product(product_id),
    CONSTRAINT chk_order_item_quantity
        CHECK (quantity > 0),
    CONSTRAINT chk_order_item_price
        CHECK (price >= 0)
) ENGINE = InnoDB;

INSERT INTO product (product_id, product_name, price)
VALUES
    (1, 'Wireless Mouse', 8500.00),
    (2, 'Keyboard', 15000.00),
    (3, 'USB Cable', 2500.00)
ON DUPLICATE KEY UPDATE
    product_name = VALUES(product_name),
    price = VALUES(price);

INSERT INTO inventory (product_id, quantity_on_hand)
VALUES
    (1, 5),
    (2, 5),
    (3, 1)
ON DUPLICATE KEY UPDATE
    quantity_on_hand = VALUES(quantity_on_hand);

SELECT * FROM product;
SELECT * FROM inventory;