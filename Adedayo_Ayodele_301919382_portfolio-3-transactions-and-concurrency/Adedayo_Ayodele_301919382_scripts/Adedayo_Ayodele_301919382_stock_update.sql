START TRANSACTION;

SELECT product_id, quantity_on_hand
FROM inventory
WHERE product_id = 1;

UPDATE inventory
SET quantity_on_hand = quantity_on_hand - 2
WHERE product_id = 1
AND quantity_on_hand >= 2;

SELECT ROW_COUNT() AS rows_updated;

ROLLBACK;