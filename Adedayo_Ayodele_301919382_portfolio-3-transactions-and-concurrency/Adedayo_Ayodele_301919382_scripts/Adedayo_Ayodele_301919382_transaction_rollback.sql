USE heywizzle_db;

START TRANSACTION;

UPDATE inventory
SET quantity_on_hand = quantity_on_hand - 1
WHERE product_id = 1
  AND quantity_on_hand >= 1;

-- Check that one inventory row was updated.
SELECT ROW_COUNT() AS rows_reserved;

INSERT INTO customer_order (
    customer_id,
    order_status,
    total_amount
)
VALUES (
    1001,
    'PENDING',
    8500.00
);

SET @test_order_id = LAST_INSERT_ID();

INSERT INTO order_item (
    order_id,
    product_id,
    quantity,
    unit_price
)
VALUES (
    @test_order_id,
    1,
    1,
    8500.00
);

-- Cancel the demonstration transaction.
ROLLBACK;

-- Confirm that inventory remains unchanged and the order was not saved.
SELECT * FROM inventory WHERE product_id = 1;

SELECT *
FROM customer_order
WHERE customer_id = 1001
ORDER BY order_id DESC;