DROP TABLE employees, departments, projects,temp_employees;
DROP TABLE if exists employee_archive;
CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY, 
    first_name VARCHAR(255), 
    last_name VARCHAR(255), 
    department VARCHAR(255),
    salary INTEGER,
    hire_date DATE,
    status VARCHAR(255) DEFAULT 'Active');

CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(255),
    budget INTEGER,
    manager_id INTEGER
);

CREATE TABLE projects(
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(255) NOT NULL, 
    dept_id INTEGER,
    start_date DATE,
    end_date DATE,
    budget INTEGER
);


INSERT INTO employees (emp_id, first_name, last_name, department, salary,status)
VALUES (0,'Amir','Nurz','IT','500','Inactive');

INSERT INTO employees (first_name, last_name, department, salary,status)
VALUES ('John','Murz','HR',DEFAULT,DEFAULT);
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES('Chill','Guy','IT',65000,'2019-01-01');
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES('Cool','Guy','IT',81000,'2019-01-01');

INSERT INTO employees (department)
VALUES ('IT'), ('HOP'), ('BOB');

INSERT INTO employees (first_name, last_name, hire_date, salary)
VALUES ('David','Dan',CURRENT_DATE,50000*1.1);

CREATE TEMP TABLE temp_employees(
    emp_id SERIAL PRIMARY KEY, 
    first_name VARCHAR(255), 
    last_name VARCHAR(255), 
    department VARCHAR(255),
    salary INTEGER,
    hire_date DATE,
    status VARCHAR(255) DEFAULT 'Active');

INSERT INTO temp_employees (emp_id,first_name,last_name,department,salary,hire_date,status)
SELECT * FROM employees WHERE department='IT';

UPDATE employees SET salary=salary*1.1;
UPDATE employees SET status='Senior' WHERE salary>60000 and hire_date<'2020-01-01';

UPDATE employees SET department=CASE
WHEN salary>80000 THEN 'Management'
WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
ELSE 'Junior'
END;

UPDATE employees SET department=DEFAULT WHERE status='Inactive';

INSERT INTO departments (dept_name,budget) VALUES ('IT','5004');

UPDATE departments SET budget = (
    SELECT AVG(salary) * 1.2 
    FROM employees 
    WHERE department = 'Senior'
); 

INSERT INTO employees (first_name,department,salary) VALUES ('Jake', 'Sales', 9500);

UPDATE employees 
SET status='Terminated' WHERE first_name is NULL;

UPDATE employees 
SET salary = salary * 1.15, 
    status = 'Promoted' 
WHERE department = 'Sales';

DELETE FROM employees 
WHERE status = 'Terminated';

DELETE FROM employees 
WHERE salary<4000 and hire_date>'2023-01-01' and department IS NULL;

DELETE FROM departments 
WHERE dept_id NOT IN (
    SELECT DISTINCT dept_id
    FROM departments
    JOIN employees ON departments.dept_name = employees.department 
    WHERE employees.department IS NOT NULL
);

INSERT INTO projects (project_name,end_date) VALUES ('Microwave','2022-01-01'),('PC','2024-01-01'),('NOTE','2025-01-01');

DELETE FROM projects WHERE end_date<'2023-01-01' RETURNING *;

INSERT INTO employees (first_name,last_name,salary,department) 
VALUES ('Alex','Hirsh',NULL,NULL);

UPDATE employees SET department='Unassigned' WHERE department is NULL;

DELETE FROM employees WHERE department IS NULL or salary IS NULL;

INSERT INTO employees(first_name,last_name,status)
VALUES ('Bob','George','Newbie') RETURNING emp_id, first_name || ' ' || last_name as full_name;

INSERT INTO employees(first_name,department,salary)
VALUES ('Dino','IT',400),('Dio','IT',500);
INSERT INTO employees(first_name,hire_date)
VALUES ('Pop','2019-01-01'),('Lucy','2022-01-01');

UPDATE employees SET salary=salary+5000 WHERE department='IT' RETURNING emp_id, (salary-5000) as old_salary, salary as new_salary;

DELETE from employees WHERE hire_date<'2020-01-01' RETURNING *;

INSERT INTO employees (first_name,last_name) VALUES ('Tom','Danny');

INSERT INTO employees (first_name, last_name, department, salary)
SELECT 'Tom', 'Davis', 'Finance', 60000
WHERE NOT EXISTS (
    SELECT 1 FROM employees 
    WHERE first_name = 'Tom' AND last_name = 'Davis'
);

INSERT INTO departments (dept_name,budget)
VALUES ('Finance','110000');

UPDATE employees 
SET salary = CASE 
    WHEN (SELECT budget FROM departments WHERE departments.dept_name = employees.department) > 100000 
    THEN salary * 1.10 
    ELSE salary * 1.05  
END;

INSERT INTO employees (first_name, last_name, department, salary) VALUES
('Alice', 'Green', 'IT', 50000),
('Charlie', 'Black', 'HR', 45000),
('Diana', 'White', 'Finance', 70000),
('Edward', 'Gray', 'IT', 55000),
('Fiona', 'Blue', 'Sales', 48000);

UPDATE employees 
SET salary = salary * 1.1 
WHERE first_name IN ('Alice', 'Charlie', 'Diana', 'Edward', 'Fiona');

CREATE TABLE employee_archive AS 
SELECT * FROM employees WHERE status = 'Inactive';
DELETE FROM employees 
WHERE status = 'Inactive';

UPDATE projects 
SET end_date = end_date + INTERVAL '30 days'
WHERE budget > 50000 
AND dept_id IN (
    SELECT dept_id 
    FROM departments
    JOIN employees ON departments.dept_name = employees.department
    GROUP BY departments.dept_id
    HAVING COUNT(employees.emp_id) > 3
);