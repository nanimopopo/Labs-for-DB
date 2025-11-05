DROP TABLE IF EXISTS employees,departments,projects;
-- Create table: employees
CREATE TABLE employees (
 emp_id INT PRIMARY KEY,
 emp_name VARCHAR(50),
 dept_id INT,
 salary DECIMAL(10, 2)
);
-- Create table: departments
CREATE TABLE departments (
 dept_id INT PRIMARY KEY,
 dept_name VARCHAR(50),
 location VARCHAR(50)
);
-- Create table: projects
CREATE TABLE projects (
 project_id INT PRIMARY KEY,
 project_name VARCHAR(50),
 dept_id INT,
 budget DECIMAL(10, 2)
);

-- Insert data into employees
INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 102, 60000),
(3, 'Mike Johnson', 101, 55000),
(4, 'Sarah Williams', 103, 65000),
(5, 'Tom Brown', NULL, 45000);
-- Insert data into departments
INSERT INTO departments (dept_id, dept_name, location) VALUES
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Finance', 'Building C'),
(104, 'Marketing', 'Building D');
-- Insert data into projects
INSERT INTO projects (project_id, project_name, dept_id,
budget) VALUES
(1, 'Website Redesign', 101, 100000),
(2, 'Employee Training', 102, 50000),
(3, 'Budget Analysis', 103, 75000),
(4, 'Cloud Migration', 101, 150000),
(5, 'AI Research', NULL, 200000);

-- PART 2
--ex 2.1
SELECT e.emp_name,d.dept_name FROM employees e CROSS JOIN departments d;
--ex 2.2
SELECT employees.emp_name, departments.dept_name FROM employees,departments; -- a)
SELECT e.emp_name,d.dept_name FROM employees e INNER JOIN departments d ON TRUE; --b)
--ex 2.3
SELECT e.emp_name,p.project_name FROM employees e CROSS JOIN projects p;

-- PART 3
-- ex 3.1
SELECT e.emp_name, d.dept_name,d.location FROM employees e INNER JOIN departments d ON e.dept_id=d.dept_id;
-- ex 3.2
SELECT e.emp_name, d.dept_name,d.location FROM employees e INNER JOIN departments d USING (dept_id);

/*
SELECT emp_name, dept_name, location
FROM employees
INNER JOIN departments USING (dept_id);
 */

-- ex3.3
SELECT emp_name, dept_name, location
FROM employees
NATURAL INNER JOIN departments;

--ex 3.4
SELECT e.emp_name, d.dept_name, p.project_name FROM employees e INNER JOIN departments d ON e.emp_id=d.dept_id
    INNER JOIN projects p ON d.dept_id=p.dept_id;

--ex 4.1
SELECT e.emp_name,d.dept_name FROM employees e LEFT JOIN departments d ON e.dept_id=d.dept_id;
-- ex 4.2
SELECT e.emp_name,d.dept_name FROM employees e LEFT JOIN departments d USING (dept_id);
-- ex 4.3
SELECT e.emp_name,d.dept_name FROM employees e LEFT JOIN departments d USING (dept_id) WHERE d.dept_id IS NULL;
-- ex 4.4
SELECT d.dept_name, count(e.emp_id) as employee_count FROM departments d LEFT JOIN employees e ON e.dept_id=d.dept_id
group by d.dept_name
order by employee_count DESC;
--ex5.1
SELECT e.emp_name, d.dept_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;
--ex 5.2
SELECT e.emp_name, d.dept_name
FROM departments d
LEFT JOIN employees e ON e.dept_id = d.dept_id;
--ex 5.3
SELECT d.dept_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id
WHERE e.dept_id IS NULL;
--ex 6.1
SELECT e.emp_name,e.dept_id,d.dept_id,d.dept_name FROM employees e FULL JOIN departments d ON e.dept_id=d.dept_id;
-- ex 6.2
SELECT d.dept_name,p.project_name FROM departments d FULL JOIN projects p ON d.dept_id=p.dept_id;
-- ex 6.3
SELECT
 CASE
 WHEN e.emp_id IS NULL THEN 'Department without
employees'
 WHEN d.dept_id IS NULL THEN 'Employee without
department'
 ELSE 'Matched'
 END AS record_status,
 e.emp_name,
 d.dept_name
FROM employees e
FULL JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL OR d.dept_id IS NULL;
-- ex 7.1
SELECT e.emp_name, d.dept_name, e.salary, d.location
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id AND
d.location = 'Building A';
-- ex 7.2
SELECT e.emp_name, d.dept_name, e.salary, d.location
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';
-- ex 7.3
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id AND d.location = 'Building A';

SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';
--ex 8.1
SELECT
 d.dept_name,
 e.emp_name,
 e.salary,
 p.project_name,
 p.budget
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
LEFT JOIN projects p ON d.dept_id = p.dept_id
ORDER BY d.dept_name, e.emp_name;
--ex 8.2
-- Add manager_id column
ALTER TABLE employees ADD COLUMN manager_id INT;
-- Update with sample data
UPDATE employees SET manager_id = 3 WHERE emp_id = 1;
UPDATE employees SET manager_id = 3 WHERE emp_id = 2;
UPDATE employees SET manager_id = NULL WHERE emp_id = 3;
UPDATE employees SET manager_id = 3 WHERE emp_id = 4;
UPDATE employees SET manager_id = 3 WHERE emp_id = 5;
-- Self join query
SELECT
 e.emp_name AS employee,
 m.emp_name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.emp_id;
--ex 8.3
SELECT d.dept_name, AVG(e.salary) as avg_salary FROM employees e INNER JOIN departments d ON e.dept_id=d.dept_id
GROUP BY d.dept_id,d.dept_name
HAVING AVG(e.salary)>50000;

-- ADDITIONAL CHALLENGES
-- ex 1
SELECT * FROM employees e FULL OUTER JOIN departments d ON e.dept_id=d.dept_id;
-- ex 2
SELECT e.emp_name, d.dept_name, COUNT(p.project_id) as project_count
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
INNER JOIN projects p ON d.dept_id = p.dept_id
GROUP BY e.emp_id, e.emp_name, d.dept_name
HAVING COUNT(p.project_id) > 1;
-- ex 3
SELECT
    e1.emp_name AS employee,
    e2.emp_name AS manager,
    e3.emp_name AS senior_manager
FROM employees e1
LEFT JOIN employees e2 ON e1.manager_id = e2.emp_id
LEFT JOIN employees e3 ON e2.manager_id = e3.emp_id
ORDER BY e3.emp_name, e2.emp_name, e1.emp_name;
-- ex 4
SELECT
    e1.emp_name AS employee1,
    e2.emp_name AS employee2,
    d.dept_name
FROM employees e1
INNER JOIN employees e2 ON e1.dept_id = e2.dept_id AND e1.emp_id < e2.emp_id
INNER JOIN departments d ON e1.dept_id = d.dept_id
ORDER BY d.dept_name, e1.emp_name, e2.emp_name;