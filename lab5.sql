--24B031931, Нуржанов Амирхан Ахметбекович


create table employees( -- TASK 1.1
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    age integer,
    CONSTRAINT age_range CHECK (age BETWEEN 18 and 65),
    salary numeric,
    CONSTRAINT salary_number CHECK(salary>0)
);

create table products_catalog( -- TASK 1.2
    product_id integer,
    product_name VARCHAR(255),
    regular_price numeric,
    discount_price numeric,
    CONSTRAINT valid_discount CHECK(regular_price>0
        and discount_price>0
        and discount_price<regular_price)
);

CREATE TABLE bookings(  -- TASK 1.3
    booking_id integer,
    check_in_date date,
    check_out_date date,
    num_guests integer,
    CONSTRAINT my_constraint CHECK(num_guests BETWEEN 1 AND 10
        AND check_out_date>check_in_date)
);

--TASK 1.4
INSERT INTO employees (age,salary) VALUES (19,2), (20,3);
INSERT INTO employees (age,salary) VALUES (8,2), (21,0); -- 8 doesn't fit into the age_range, 0 doesn't satisfy the condition of the salary number;

INSERT INTO products_catalog(regular_price,discount_price) VALUES (5,3),(6,2);
INSERT INTO products_catalog(regular_price,discount_price) VALUES (2,3),(5,0); -- violates valid_discount constraint with reg_price<dis_price, discount_price=0 violates the condition;

INSERT INTO bookings(num_guests,check_in_date,check_out_date) VALUES (2,'2020-01-01','2022-01-01'), (3,'2021-01-01','2023-01-01');
INSERT INTO bookings(num_guests,check_in_date,check_out_date) VALUES (0,'2020-01-01','2022-01-01'), (3,'2024-01-01','2023-01-01'); -- violates the constraint of number_guests being 0, check_in_date > check_out_date;

CREATE TABLE customers (  -- TASK 2.1
    customer_id INTEGER NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);

CREATE TABLE inventory (  --TASK 2.2
    item_id INTEGER NOT NULL,
    item_name TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity >= 0),
    unit_price NUMERIC NOT NULL CHECK (unit_price > 0),
    last_updated TIMESTAMP NOT NULL
);

--TASK 2.3

INSERT INTO customers (customer_id, email, phone, registration_date)
VALUES (1, 'john@example.com', '123-456-7890', '2024-01-15');

INSERT INTO inventory (item_id, item_name, quantity, unit_price, last_updated)
VALUES (1, 'Laptop', 10, 999.99, '2024-01-15 10:30:00');

INSERT INTO customers (customer_id, email, registration_date) -- attempt to insert records with NULL values in NOT NULL columns;
VALUES (2, NULL, '2024-01-16');

INSERT INTO inventory (item_id, item_name, quantity, unit_price)
VALUES (2, 'Mouse', 25, 29.99);

INSERT INTO customers (customer_id, email, phone, registration_date)
VALUES (3, 'jane@example.com', NULL, '2024-01-17');



CREATE TABLE users ( -- TASK 3.1
    user_id INTEGER,
    username TEXT UNIQUE,
    email TEXT UNIQUE,
    created_at TIMESTAMP
);

CREATE TABLE course_enrollments (  -- TASK 3.2
    enrollment_id INTEGER,
    student_id INTEGER,
    course_code TEXT,
    semester TEXT,
    UNIQUE (student_id, course_code, semester)
);


DROP TABLE users; -- TASK 3.3

CREATE TABLE users (
    user_id INTEGER,
    username TEXT,
    email TEXT,
    created_at TIMESTAMP,
    CONSTRAINT unique_username UNIQUE (username),
    CONSTRAINT unique_email UNIQUE (email)
);


INSERT INTO users (user_id, username, email, created_at)
VALUES (1, 'alice', 'alice@example.com', NOW());

INSERT INTO users (user_id, username, email, created_at)
VALUES (2, 'bob', 'bob@example.com', NOW());

INSERT INTO users (user_id, username, email, created_at)
VALUES (3, 'alice', 'charlie@example.com', NOW());

INSERT INTO users (user_id, username, email, created_at)
VALUES (4, 'diana', 'alice@example.com', NOW());



CREATE TABLE departments ( -- TASK 4.1
    dept_id INTEGER PRIMARY KEY,
    dept_name TEXT NOT NULL,
    location TEXT
);

INSERT INTO departments (dept_id, dept_name, location)
VALUES
    (1, 'Engineering', 'New York'),
    (2, 'Marketing', 'Chicago'),
    (3, 'Sales', 'Boston');

INSERT INTO departments (dept_id, dept_name, location)
VALUES (1, 'HR', 'Seattle');

INSERT INTO departments (dept_id, dept_name, location)
VALUES (NULL, 'Finance', 'Austin');


CREATE TABLE student_courses ( -- TASK 4.2
    student_id INTEGER,
    course_id INTEGER,
    enrollment_date DATE,
    grade TEXT,
    PRIMARY KEY (student_id, course_id)
);

/* TASK 4.3
 1. Difference between UNIQUE and PRIMARY KEY

PRIMARY KEY automatically includes both UNIQUE and NOT NULL constraints. It uniquely identifies each row and cannot contain NULL values.

UNIQUE constraint ensures all values in a column are different, but allows NULL values (unless combined with NOT NULL).

A table can have only one PRIMARY KEY but multiple UNIQUE constraints.

PRIMARY KEY is used as the main reference for foreign key relationships, while UNIQUE is used for data integrity on non-primary attributes.

2. When to use single-column vs. composite PRIMARY KEY

Single-column PRIMARY KEY: Use when one attribute naturally and uniquely identifies each row. Examples: user_id.

Composite PRIMARY KEY: Use when the combination of multiple columns uniquely identifies each row. Examples: (student_id, course_id) in enrollments, (order_id, product_id) in order items, (flight_number, departure_date) for flights.

3. Why a table can have only one PRIMARY KEY but multiple UNIQUE constraints

PRIMARY KEY serves as the fundamental identifier for the entire table and is the default target for foreign key references. Having multiple PRIMARY KEYs would create ambiguity in database relationships and referencing.

UNIQUE constraints enforce business rules and data integrity on specific attributes without being the main identifier. A table can have multiple UNIQUE constraints to ensure uniqueness across different attributes like email, username, phone number, while maintaining one clear primary identification system.

This design follows the database normalization principle of having one definitive way to identify each record, while still allowing multiple business rules for data uniqueness.
 */


CREATE TABLE employees_dept (  -- TASK 5.1
    emp_id INTEGER PRIMARY KEY,
    emp_name TEXT NOT NULL,
    dept_id INTEGER REFERENCES departments(dept_id),
    hire_date DATE
);


INSERT INTO employees_dept (emp_id, emp_name, dept_id, hire_date)
VALUES
    (1, 'John', 1, '2023-01-15'),
    (2, 'Jimmy For', 2, '2023-02-20'),
    (3, 'Bobby Hill', 3, '2023-03-10');

INSERT INTO employees_dept (emp_id, emp_name, dept_id, hire_date)
VALUES (4, 'Invalid Dept', 99, '2023-04-01');


CREATE TABLE authors (  -- TASK 5.2
    author_id INTEGER PRIMARY KEY,
    author_name TEXT NOT NULL,
    country TEXT
);


CREATE TABLE publishers (
    publisher_id INTEGER PRIMARY KEY,
    publisher_name TEXT NOT NULL,
    city TEXT
);


CREATE TABLE books (
    book_id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    author_id INTEGER REFERENCES authors(author_id),
    publisher_id INTEGER REFERENCES publishers(publisher_id),
    publication_year INTEGER,
    isbn TEXT UNIQUE
);


INSERT INTO authors (author_id, author_name, country) VALUES
(1, 'J.K. Rowling', 'UK'),
(2, 'George Orwell', 'UK'),
(3, 'Stephen King', 'USA'),
(4, 'Agatha Christie', 'UK');

INSERT INTO publishers (publisher_id, publisher_name, city) VALUES
(1, 'Penguin Random House', 'New York'),
(2, 'HarperCollins', 'London'),
(3, 'Simon & Schuster', 'New York');

INSERT INTO books (book_id, title, author_id, publisher_id, publication_year, isbn) VALUES
(1, 'Harry Potter and the Philosopher''s Stone', 1, 2, 1997, '978-0747532743'),
(2, '1984', 2, 1, 1949, '978-0451524935'),
(3, 'The Shining', 3, 3, 1977, '978-0307743657'),
(4, 'Murder on the Orient Express', 4, 1, 1934, '978-0062693662');


CREATE TABLE categories (  -- TASK 5.3
    category_id INTEGER PRIMARY KEY,
    category_name TEXT NOT NULL
);

CREATE TABLE products_fk (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id INTEGER REFERENCES categories ON DELETE RESTRICT
);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    order_date DATE NOT NULL
);

CREATE TABLE order_items (
    item_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders ON DELETE CASCADE,
    product_id INTEGER REFERENCES products_fk,
    quantity INTEGER CHECK (quantity > 0)
);


INSERT INTO categories (category_id, category_name) VALUES
(1, 'Electronics'),
(2, 'Books'),
(3, 'Clothing');

INSERT INTO products_fk (product_id, product_name, category_id) VALUES
(1, 'Laptop', 1),
(2, 'Novel', 2),
(3, 'T-Shirt', 3);

INSERT INTO orders (order_id, order_date) VALUES
(1, '2024-01-15'),
(2, '2024-01-16');

INSERT INTO order_items (item_id, order_id, product_id, quantity) VALUES
(1, 1, 1, 1),
(2, 1, 2, 2),
(3, 2, 3, 3);


DELETE FROM categories WHERE category_id = 1;


SELECT * FROM order_items WHERE order_id = 1;
DELETE FROM orders WHERE order_id = 1;



SELECT * FROM order_items WHERE order_id = 1;





CREATE TABLE customers ( -- TASK 6.1
    customer_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);

CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC CHECK (price >= 0),
    stock_quantity INTEGER CHECK (stock_quantity >= 0)
);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER REFERENCES customers ON DELETE RESTRICT,
    order_date DATE NOT NULL,
    total_amount NUMERIC CHECK (total_amount >= 0),
    status TEXT CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled'))
);

CREATE TABLE order_details (
    order_detail_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders ON DELETE CASCADE,
    product_id INTEGER REFERENCES products ON DELETE RESTRICT,
    quantity INTEGER CHECK (quantity > 0),
    unit_price NUMERIC CHECK (unit_price >= 0)
);


INSERT INTO customers (customer_id, name, email, phone, registration_date) VALUES
(1, 'Alice Johnson', 'alice@email.com', '555-0101', '2024-01-01'),
(2, 'Bob Smith', 'bob@email.com', '555-0102', '2024-01-02'),
(3, 'Carol Davis', 'carol@email.com', '555-0103', '2024-01-03'),
(4, 'David Wilson', 'david@email.com', '555-0104', '2024-01-04'),
(5, 'Eva Brown', 'eva@email.com', '555-0105', '2024-01-05');

INSERT INTO products (product_id, name, description, price, stock_quantity) VALUES
(1, 'Smartphone', 'Latest smartphone model', 699.99, 50),
(2, 'Laptop', 'High-performance laptop', 1299.99, 25),
(3, 'Headphones', 'Wireless noise-cancelling', 199.99, 100),
(4, 'Tablet', '10-inch tablet', 399.99, 30),
(5, 'Smartwatch', 'Fitness tracking watch', 249.99, 75);

INSERT INTO orders (order_id, customer_id, order_date, total_amount, status) VALUES
(1, 1, '2024-01-10', 899.98, 'delivered'),
(2, 2, '2024-01-11', 1299.99, 'processing'),
(3, 3, '2024-01-12', 449.98, 'shipped'),
(4, 4, '2024-01-13', 199.99, 'pending'),
(5, 5, '2024-01-14', 1749.97, 'processing');

INSERT INTO order_details (order_detail_id, order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 1, 699.99),
(2, 1, 3, 1, 199.99),
(3, 2, 2, 1, 1299.99),
(4, 3, 4, 1, 399.99),
(5, 3, 5, 1, 249.99),
(6, 4, 3, 1, 199.99),
(7, 5, 2, 1, 1299.99),
(8, 5, 5, 1, 249.99),
(9, 5, 1, 1, 199.99);




INSERT INTO customers (customer_id, name, email, phone, registration_date)
VALUES (6, 'Duplicate Email', 'alice@email.com', '555-0106', '2024-01-06');


INSERT INTO products (product_id, name, description, price, stock_quantity)
VALUES (6, 'Invalid Product', 'Test product', -10.00, 5);


INSERT INTO orders (order_id, customer_id, order_date, total_amount, status)
VALUES (6, 1, '2024-01-15', 100.00, 'invalid_status');


INSERT INTO orders (order_id, customer_id, order_date, total_amount, status)
VALUES (7, 99, '2024-01-15', 100.00, 'pending');


SELECT * FROM order_details WHERE order_id = 1;
DELETE FROM orders WHERE order_id = 1;
SELECT * FROM order_details WHERE order_id = 1;


DELETE FROM customers WHERE customer_id = 2; 