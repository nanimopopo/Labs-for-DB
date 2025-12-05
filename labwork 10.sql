DROP table accounts,products;

CREATE TABLE accounts (
 id SERIAL PRIMARY KEY,
 name VARCHAR(100) NOT NULL,
 balance DECIMAL(10, 2) DEFAULT 0.00
);
CREATE TABLE products (
 id SERIAL PRIMARY KEY,
 shop VARCHAR(100) NOT NULL,
 product VARCHAR(100) NOT NULL,
 price DECIMAL(10, 2) NOT NULL
);
-- Insert test data
INSERT INTO accounts (name, balance) VALUES
 ('Alice', 1000.00),
 ('Bob', 500.00),
 ('Wally', 750.00);
INSERT INTO products (shop, product, price) VALUES
 ('Joe''s Shop', 'Coke', 2.50),
 ('Joe''s Shop', 'Pepsi', 3.00);

-- TASK 1
BEGIN;
UPDATE accounts SET balance = balance - 100.00
 WHERE name = 'Alice';
UPDATE accounts SET balance = balance + 100.00
 WHERE name = 'Bob';
COMMIT;

SELECT * FROM accounts;
/* a) Alice's balance will be 900, Bob's will be 600
   b) To keep the principle of Atomicity, either whole statement is to be done or none. Since it's a money transfer operation
   c) Alice would have lost her 100 dollars as Bob wouldn't have received it*/


-- TASK 2
BEGIN;
UPDATE accounts SET balance = balance - 500.00
 WHERE name = 'Alice';
SELECT * FROM accounts WHERE name = 'Alice';
-- Oops! Wrong amount, let's undo
ROLLBACK;
SELECT * FROM accounts WHERE name = 'Alice';
/* a) Alice's balance was 400
   b) 900
   c) To undo the mistaken transaction. For example: undo the money transfer operation to the other user*/

-- TASK 3
BEGIN;
UPDATE accounts SET balance = balance - 100.00
 WHERE name = 'Alice';
SAVEPOINT my_savepoint;
UPDATE accounts SET balance = balance + 100.00
 WHERE name = 'Bob';
-- Oops, should transfer to Wally instead
ROLLBACK TO my_savepoint;
UPDATE accounts SET balance = balance + 100.00
 WHERE name = 'Wally';
COMMIT;


SELECT * FROM accounts;

/*  a) Alice's balance will remain at 800, Bob's will be 600, Wally's will be 850*
    b) Yes, Bob’s account was temporarily credited after the second UPDATE, but the ROLLBACK undid that change before COMMIT
    c) It allows partial rollback within a single transaction, preserving earlier valid work without needing to restart the entire transaction*/

-- TASK 4
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2 to make changes and COMMIT
-- Then re-run:
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;


/*BEGIN;
DELETE FROM products WHERE shop = 'Joe''s Shop';
INSERT INTO products (shop, product, price)
 VALUES ('Joe''s Shop', 'Fanta', 3.50);
COMMIT;   -    in second console*/

DROP table products;
CREATE TABLE products (
 id SERIAL PRIMARY KEY,
 shop VARCHAR(100) NOT NULL,
 product VARCHAR(100) NOT NULL,
 price DECIMAL(10, 2) NOT NULL
);
INSERT INTO products (shop, product, price) VALUES
 ('Joe''s Shop', 'Coke', 2.50),
 ('Joe''s Shop', 'Pepsi', 3.00);

BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2 to make changes and COMMIT
-- Then re-run:
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;

/*  a) It sees original products Coke and Pepsi. But after Terminal 2 commits, it sees only Fanta.
    b) It sees the same data in both SELECTs (Coke, Pepsi), because SERIALIZABLE isolation prevents seeing changes made by other transactions until terminal 1 itself commits.
    c) READ COMMITTED: Allows non-repeatable reads; a transaction sees committed changes from other transactions immediately.
       SERIALIZABLE: Prevents all concurrency anomalies; transactions are fully isolated as if executed sequentially.
    */
-- TASK 5
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT MAX(price), MIN(price) FROM products
 WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2
SELECT MAX(price), MIN(price) FROM products
 WHERE shop = 'Joe''s Shop';
COMMIT;


/*  a) No, because REPEATABLE READ prevents seeing new rows inserted after the first read (phantom rows).
    b) A phantom read occurs when a transaction re-executes a query and sees new rows that were inserted by another committed transaction.
    c) SERIALIZABLE prevents phantom reads.*/


-- TASK 6
DROP TABLE products;
CREATE TABLE products (
 id SERIAL PRIMARY KEY,
 shop VARCHAR(100) NOT NULL,
 product VARCHAR(100) NOT NULL,
 price DECIMAL(10, 2) NOT NULL
);
INSERT INTO products (shop, product, price) VALUES
('Joe''s Shop', 'Coke', 2.50),
('Joe''s Shop', 'Pepsi', 3.00),
('Joe''s Shop', 'Fanta', 3.50);

BEGIN TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2 to UPDATE but NOT commit
SELECT * FROM products WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2 to ROLLBACK
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;


-- INDEPENDENT EXERCISES
-- Ex 1
BEGIN;
UPDATE accounts SET balance=balance-200 WHERE name='Bob' and COALESCE(balance,0)>=200;
UPDATE accounts SET balance=balance+200 WHERE name='Wally';
COMMIT;

-- Ex 2
BEGIN;
INSERT INTO products(shop,product, price)
 VALUEs( 'New shop','Water', 1.50);
SAVEPOINT new_product_savepoint;

SELECT * FROM products WHERE shop='New shop';

UPDATE products SET price = 2.00 WHERE product = 'Water';
SAVEPOINT update_price_savepoint;

DELETE FROM products WHERE product='Water';
ROLLBACK TO new_product_savepoint;

COMMIT;

-- Ex 3
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT balance FROM accounts WHERE name = 'Alice';
-- Balance 800
UPDATE accounts SET balance = balance - 300 WHERE name = 'Alice';
-- Do not commit yet
COMMIT;


BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE ;
SELECT balance FROM accounts WHERE name = 'Wally';
-- Balance 850
UPDATE accounts SET balance = balance - 300 WHERE name = 'Wally';
UPDATE accounts SET balance=balance*2 WHERE name='Wally';
-- Balance 1100
-- Do not commit yet
COMMIT;



-- Ex 4
DROP TABLE products;
CREATE TABLE products (
 id SERIAL PRIMARY KEY,
 shop VARCHAR(100) NOT NULL,
 product VARCHAR(100) NOT NULL,
 price DECIMAL(10, 2) NOT NULL
);
INSERT INTO products (shop, product, price) VALUES
 ('Joe''s Shop', 'Coke', 2.50),
 ('Joe''s Shop', 'Pepsi', 3.00);
SELECT * FROM products;


BEGIN;
DELETE FROM products WHERE product='Pepsi';
INSERT INTO products(shop,product,price) VALUES ('Joe''s shop','water',1.00);
SELECT * FROM products;
COMMIT;
rollback;