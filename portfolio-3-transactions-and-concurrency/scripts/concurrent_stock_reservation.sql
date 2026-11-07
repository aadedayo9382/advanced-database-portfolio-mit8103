USE heywizzle_db;

UPDATE inventory
SET quantity_on_hand = 1,
    version_no = 0
WHERE product_id = 3;

SELECT * FROM inventory WHERE product_id = 3;