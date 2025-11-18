-- Create tables
CREATE TABLE departments (
 dept_id INT PRIMARY KEY,
 dept_name VARCHAR(50),
 location VARCHAR(50)
);
CREATE TABLE employees (
 emp_id INT PRIMARY KEY,
 emp_name VARCHAR(100),
 dept_id INT,
 salary DECIMAL(10,2),
 FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);
CREATE TABLE projects (
 proj_id INT PRIMARY KEY,
 proj_name VARCHAR(100),
 budget DECIMAL(12,2),
 dept_id INT,
 FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);
-- Insert sample data
INSERT INTO departments VALUES
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Operations', 'Building C');
INSERT INTO employees VALUES
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 101, 55000),
(3, 'Mike Johnson', 102, 48000),
(4, 'Sarah Williams', 102, 52000),
(5, 'Tom Brown', 103, 60000);
INSERT INTO projects VALUES
(201, 'Website Redesign', 75000, 101),
(202, 'Database Migration', 120000, 101),
(203, 'HR System Upgrade', 50000, 102);

-- PART 2
-- ex 2.1
CREATE INDEX emp_salary_idx ON employees(salary);

SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees'; -- 2 indexes
-- ex 2.2
CREATE INDEX emp_dept_idx ON employees(dept_id);

SELECT * FROM employees WHERE dept_id = 101; /* its beneficial since FKs are frequently used in JOIN statements, speeding up those queries
    and they help enforce referential integrity more efficiently*/
-- ex 2.3
SELECT
 tablename,
 indexname,
 indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname; /* automatically created indexes are departments_pkey, employees_pkey, projects_pkey */

-- PART 3
-- ex 3.1
CREATE INDEX emp_dept_salary_idx ON employees(dept_id, salary);

SELECT emp_name, salary
FROM employees
WHERE dept_id = 101 AND salary > 52000; /*no, this index would not be useful for a query that only filters by salary
                                          because the index is organized by (dept_id, salary). Without dept_id in the WHERE clause,
                                          SQL cannot effectively use the leading part of the index */
-- ex 3.2
CREATE INDEX emp_salary_dept_idx ON employees(salary, dept_id);

-- Query 1: Filters by dept_id first
SELECT * FROM employees WHERE dept_id = 102 AND salary > 50000;
-- Query 2: Filters by salary first
SELECT * FROM employees WHERE salary > 50000 AND dept_id = 102;
/* Yes, the order of columns in a multicolumn index matters. The index is most effective when the query uses the leftmost columns in the index.
emp_dept_salary_idx is better for Query 1, while emp_salary_dept_idx is better for Query 2.*/

-- ex 4.1
ALTER TABLE employees ADD COLUMN email VARCHAR(100);
UPDATE employees SET email = 'john.smith@company.com' WHERE emp_id = 1;
UPDATE employees SET email = 'jane.doe@company.com' WHERE emp_id = 2;
UPDATE employees SET email = 'mike.johnson@company.com' WHERE emp_id = 3;
UPDATE employees SET email = 'sarah.williams@company.com' WHERE emp_id = 4;
UPDATE employees SET email = 'tom.brown@company.com' WHERE emp_id = 5;

CREATE UNIQUE INDEX emp_email_unique_idx ON employees(email);

INSERT INTO employees (emp_id, emp_name, dept_id, salary, email)
VALUES (6, 'New Employee', 101, 55000, 'john.smith@company.com');
/*repeating key value violates the unique condition of "emp_email_unique_idx"
  Description: Key "(email)=(john.smith@company.com)" already exists */

-- ex 4.2
ALTER TABLE employees ADD COLUMN phone VARCHAR(20) UNIQUE;

SELECT indexname, indexdef FROM pg_indexes WHERE tablename='employees' AND indexname LIKE '%phone%';
/* yes, it created a UNIQUE INDEX employees_phone_key using btree(phone) */

-- ex 5.1
CREATE INDEX emp_salary_desc_idx ON employees(salary DESC);
SELECT emp_name, salary
FROM employees
ORDER BY salary DESC; /* Indexes help ORDER BY statements by reducing the time and improving performances of queries
                         by retrieving data from the index itself without needing to access the main data. Especially,
                         when the index's parameters of the sorting order and columns matches with the ORDER BY, avoiding the need
                         for sorting an entire data set. This index in particular fits the second described case*/
-- ex 5.2
CREATE INDEX proj_budget_nulls_first_idx ON projects(budget NULLS FIRST);

SELECT proj_name, budget
FROM projects
ORDER BY budget NULLS FIRST;
-- ex 6.1
DROP INDEX emp_name_lower_idx;
CREATE INDEX emp_name_lower_idx ON employees(LOWER(emp_name));

SELECT * FROM employees WHERE LOWER(emp_name) = 'john smith';
/*Without the index for case-insensitive tests, the program would be forced to perform a full table scan by applying
  the LOWER function to each emp_name value and compare them to the condition in the query, which is significantly slower than
  just using readied values from the index*/

-- ex 6.2
ALTER TABLE employees ADD COLUMN hire_date DATE;

UPDATE employees SET hire_date = '2020-01-15' WHERE emp_id = 1;
UPDATE employees SET hire_date = '2019-06-20' WHERE emp_id = 2;
UPDATE employees SET hire_date = '2021-03-10' WHERE emp_id = 3;
UPDATE employees SET hire_date = '2020-11-05' WHERE emp_id = 4;
UPDATE employees SET hire_date = '2018-08-25' WHERE emp_id = 5;

CREATE INDEX emp_hire_year_idx ON employees(EXTRACT(YEAR FROM hire_date));

SELECT emp_name, hire_date
FROM employees
WHERE EXTRACT(YEAR FROM hire_date) = 2020;

-- ex 7.1
ALTER INDEX emp_salary_idx RENAME TO employees_salary_index;
SELECT indexname FROM pg_indexes WHERE tablename = 'employees';
-- ex 7.2
DROP INDEX emp_salary_dept_idx;
/* After an index is created, the system has to keep it	synchronized with the table.
This adds overhead to data manipulation operations. Therefore, unused indexes should be discarded of.
 */

 -- ex 7.3
REINDEX INDEX employees_salary_index;

-- ex 8.1
SELECT e.emp_name, e.salary, d.dept_name
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 50000
ORDER BY e.salary DESC;

drop index user_emp_salary_idx;
--CREATE INDEX user_emp_salary_idx ON employees(salary DESC) WHERE salary>50000;
CREATE INDEX emp_salary_filter_idx ON employees(salary) WHERE salary > 50000; -- FOR WHERE
CREATE INDEX emp_dept_idx ON employees(dept_id); -- FOR JOIN
CREATE INDEX emp_salary_desc_idx ON employees(salary DESC); -- FOR ORDER BY

-- ex 8.2
CREATE INDEX high_budget_projects_idx ON projects(budget) WHERE budget>80000;

SELECT proj_name, budget
FROM projects
WHERE budget > 80000;
/* Partial indexes reduce the overhead to DML operations, smaller in storage, only processes a small subset of data that is
   filtered through WHERE statement, which is more optimal for such sizes*/

-- ex 8.3
EXPLAIN SELECT * FROM employees WHERE salary > 52000;
/* Shows sequential scan, it might tell us that the program decided that Seq scan would be more beneficial to use
   (perhaps due to the fact that the table is small*/

-- ex 9.1
CREATE INDEX dept_name_hash_idx ON departments USING HASH (dept_name);
SELECT * FROM departments WHERE dept_name = 'IT';
/* Hash index is to be used when only simple equality = comparisons in indexed columns are used; we don't require sorting,range searching*/
-- ex 9.2
CREATE INDEX proj_name_btree_idx ON projects(proj_name);

CREATE INDEX proj_name_hash_idx ON projects USING HASH (proj_name)
-- Equality search (both can be used)
SELECT * FROM projects WHERE proj_name = 'Website Redesign';
-- Range search (only B-tree can be used)
SELECT * FROM projects WHERE proj_name > 'Database';

-- ex 10.1
SELECT
 schemaname,
 tablename,
 indexname,
 pg_size_pretty(pg_relation_size(indexname::regclass)) as index_size
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;
/* dept_name_hash_idx and proj_name_hash_idx due to potential long string values that hash indexes store the hash value for.
   They are less efficient at compressing text data, since they store the entire hash value; potential hash collisions*/

-- ex 10.2
DROP INDEX IF EXISTS proj_name_hash_idx;
-- ex 10.3
CREATE VIEW index_documentation AS
SELECT
 tablename,
 indexname,
 indexdef,
 'Improves salary-based queries' as purpose
FROM pg_indexes
WHERE schemaname = 'public'
 AND indexname LIKE '%salary%';
SELECT * FROM index_documentation;

-- SUMMARY QUESTIONS
/*
1. B-tree.
2. Columns frequently used in WHERE, ORDER BY clauses, JOIN conditions
Frequently used queries on a specific data set
Huge data table, to increase performance and decrease run time of queries.
3. When only simple DML operations are performed
Tables that are frequently updated but rarely queried (system has to keep indexes in sync with the table)
When you want to maintain minimal overhead on data manipulations operations.
4. Indexes must be updated to reflect the changes.
5. By using the EXPLAIN command before the query to see the execution plan.
*/



