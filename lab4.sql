DROP TABLE IF EXISTS employees, projects, assignments;
CREATE TABLE employees (
 employee_id SERIAL PRIMARY KEY,
 first_name VARCHAR(50),
 last_name VARCHAR(50),
 department VARCHAR(50),
 salary NUMERIC(10,2),
 hire_date DATE,
 manager_id INTEGER,
 email VARCHAR(100)
);
CREATE TABLE projects (
 project_id SERIAL PRIMARY KEY,
 project_name VARCHAR(100),
 budget NUMERIC(12,2),
 start_date DATE,
 end_date DATE,
 status VARCHAR(20)
);
CREATE TABLE assignments (
 assignment_id SERIAL PRIMARY KEY,
 employee_id INTEGER REFERENCES employees(employee_id),
 project_id INTEGER REFERENCES projects(project_id),
 hours_worked NUMERIC(5,1),
 assignment_date DATE
);

INSERT INTO employees (first_name, last_name, department,
salary, hire_date, manager_id, email) VALUES
('John', 'Smith', 'IT', 75000, '2020-01-15', NULL,
'john.smith@company.com'),
('Sarah', 'Johnson', 'IT', 65000, '2020-03-20', 1,
'sarah.j@company.com'),
('Michael', 'Brown', 'Sales', 55000, '2019-06-10', NULL,
'mbrown@company.com'),
('Emily', 'Davis', 'HR', 60000, '2021-02-01', NULL,
'emily.davis@company.com'),
('Robert', 'Wilson', 'IT', 70000, '2020-08-15', 1, NULL),
('Lisa', 'Anderson', 'Sales', 58000, '2021-05-20', 3,
'lisa.a@company.com');
INSERT INTO projects (project_name, budget, start_date,
end_date, status) VALUES
('Website Redesign', 150000, '2024-01-01', '2024-06-30',
'Active'),
('CRM Implementation', 200000, '2024-02-15', '2024-12-31',
'Active'),
('Marketing Campaign', 80000, '2024-03-01', '2024-05-31',
'Completed'),
('Database Migration', 120000, '2024-01-10', NULL, 'Active');
INSERT INTO assignments (employee_id, project_id,
hours_worked, assignment_date) VALUES
(1, 1, 120.5, '2024-01-15'),
(2, 1, 95.0, '2024-01-20'),
(1, 4, 80.0, '2024-02-01'),
(3, 3, 60.0, '2024-03-05'),
(5, 2, 110.0, '2024-02-20'),
(6, 3, 75.5, '2024-03-10');

SELECT first_name || ' ' || last_name as full_name, department, salary FROM employees; -- task 1.1
SELECT DISTINCT employees.department from employees; -- task 1.2
SELECT project_name, budget from projects; -- task 1.3
ALTER TABLE projects ADD budget_category VARCHAR(255) DEFAULT null;
UPDATE projects SET budget_category=CASE 
WHEN budget>150000 THEN 'Large'
WHEN budget BETWEEN 100000 AND 150000 THEN 'Medium'
ELSE 'Small' END;

SELECT first_name || ' ' || last_name as full_name, COALESCE (email, 'No email provided') as employee_email FROM employees; -- task 1.4
--part 2
SELECT first_name || ' ' || last_name as full_name, hire_date FROM employees WHERE hire_date>'2020-01-01'; -- task 2.1
SELECT first_name || ' ' || last_name as full_name, salary FROM employees WHERE salary BETWEEN 60000 and 70000; -- task 2.2
SELECT last_name FROM employees WHERE last_name LIKE 'S%' OR last_name LIKE 'J%'; -- task 2.3
SELECT first_name || ' ' || last_name as full_name, department, manager_id FROM employees WHERE manager_id IS NOT NULL and department='IT'; -- task 2.4
--part 3
SELECT -- task 3.1
UPPER(first_name || ' ' || last_name) AS uppercase_name,
LENGTH(last_name) AS last_name_length,
SUBSTRING(email FROM 1 FOR 3) AS email_prefix
FROM employees;

SELECT -- task 3.2
first_name || ' ' || last_name AS full_name,
salary AS annual_salary,
ROUND(salary / 12, 2) AS monthly_salary,
salary * 0.1 AS raise_amount
FROM employees;

SELECT FORMAT('Project: %s - Budget: $%s - Status: %s', project_name, budget, status) AS project_info FROM projects; --task 3.3

SELECT first_name || ' ' || last_name AS full_name, EXTRACT(YEAR FROM AGE(CURRENT_DATE, hire_date)) AS years_with_company FROM employees; -- task 3.4
--part 4
SELECT AVG(salary) as average_salary, department FROM employees GROUP BY department; -- task 4.1

SELECT -- task 4.2
    project_name,
    SUM(assignments.hours_worked) AS total_hours_worked
FROM projects
JOIN assignments ON projects.project_id = assignments.project_id
GROUP BY projects.project_id, projects.project_name;

SELECT COUNT(employee_id) as number_of_employees FROM employees GROUP BY department HAVING COUNT(employee_id)>1; -- task 4.3

SELECT MIN(salary) as min_salary, MAX(salary) as max_salary, SUM(salary) as total_payroll FROM employees; -- task 4.4
--part 5
SELECT employee_id,first_name || ' ' || last_name AS full_name, salary FROM employees WHERE salary>65000 -- task 5.1
UNION
SELECT employee_id,first_name || ' ' || last_name AS full_name, salary FROM employees WHERE hire_date>'2020-01-01';

SELECT employee_id,first_name || ' ' || last_name AS full_name, salary FROM employees WHERE salary>65000 -- task 5.2
INTERSECT
SELECT employee_id,first_name || ' ' || last_name AS full_name, salary FROM employees WHERE department='IT';

SELECT employee_id,first_name || ' ' || last_name AS full_name FROM employees -- task 5.3
EXCEPT
SELECT employees.employee_id,first_name || ' ' || last_name AS full_name FROM employees JOIN assignments ON employees.employee_id = assignments.employee_id;
--part 6
SELECT first_name || ' ' || last_name as full_name FROM employees -- part 6.1
WHERE EXISTS (
    SELECT 1
    FROM assignments
    WHERE assignments.employee_id = employees.employee_id
);

SELECT * FROM employees
WHERE employee_id IN (
SELECT DISTINCT assignments.employee_id FROM assignments JOIN projects ON assignments.project_id = projects.project_id WHERE projects.status='Active' -- part 6.2
);

SELECT * FROM employees 
WHERE salary > ANY (
SELECT salary FROM employees WHERE department='Sales' -- part 6.3
);

--part 7
SELECT -- part 7.1
    employees_table.first_name || ' ' || employees_table.last_name AS full_name,
    employees_table.department,
    ROUND(AVG(assign.hours_worked), 2) AS avg_hours_worked,
    employees_table.salary,
    (SELECT COUNT(*) + 1 
     FROM employees e2 
     WHERE e2.department = employees_table.department AND e2.salary > employees_table.salary) AS salary_rank_in_dept
FROM employees employees_table
LEFT JOIN assignments assign ON employees_table.employee_id = assign.employee_id
GROUP BY employees_table.employee_id, employees_table.first_name, employees_table.last_name, employees_table.department, employees_table.salary
ORDER BY employees_table.department, employees_table.salary DESC;

SELECT -- part 7.2
    p.project_name,
    SUM(a.hours_worked) AS total_hours,
    COUNT(DISTINCT a.employee_id) AS employee_count
FROM projects p
JOIN assignments a ON p.project_id = a.project_id
GROUP BY p.project_id, p.project_name
HAVING SUM(a.hours_worked) > 150;

SELECT -- part 7.3
    e.department,
    COUNT(*) AS total_employees,
    ROUND(AVG(e.salary), 2) AS average_salary,
    (SELECT first_name || ' ' || last_name 
     FROM employees 
     WHERE department = e.department 
     ORDER BY salary DESC 
     LIMIT 1) AS highest_paid_employee,
    GREATEST(MAX(e.salary), 0) AS department_max_salary,
    LEAST(MIN(e.salary), 1000000) AS department_min_salary
FROM employees e
GROUP BY e.department;