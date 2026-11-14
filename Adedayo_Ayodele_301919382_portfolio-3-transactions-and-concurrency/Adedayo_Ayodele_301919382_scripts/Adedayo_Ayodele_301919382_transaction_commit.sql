USE heywizzle_db;

START TRANSACTION;

UPDATE inventory
SET quantity_on_hand = quantity_on_hand - 1
WHERE product_id = 1
  AND quantity_on_hand >= 1;

SET @stock_rows_updated = ROW_COUNT();

-- Continue only if the stock reservation succeeded.
-- If this is 0, execute ROLLBACK and do not create the order.

INSERT INTO customer_order (
    customer_id,
    order_status,
    total_amount
)
SELECT
    1002,
    'PENDING',
    p.price
FROM product AS p
WHERE p.product_id = 1
  AND @stock_rows_updated = 1;

SET @new_order_id = LAST_INSERT_ID();

INSERT INTO order_item (
    order_id,
    product_id,
    quantity,
    unit_price
)
SELECT
    @new_order_id,
    p.product_id,
    1,
    p.price
FROM product AS p
WHERE p.product_id = 1
  AND @stock_rows_updated = 1;

-- Review before committing.
SELECT @stock_rows_updated AS stock_rows_updated,
       @new_order_id AS new_order_id;

-- Commit only if stock_rows_updated = 1.
COMMIT;

SELECT * FROM inventory WHERE product_id = 1;
SELECT * FROM customer_order WHERE order_id = @new_order_id;
SELECT * FROM order_item WHERE order_id = @new_order_id;