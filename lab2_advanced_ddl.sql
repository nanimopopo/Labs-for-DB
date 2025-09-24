-- Laboratory Work #2: Advanced DDL Operations

-- Part 1: Multiple Database Management

-- Task 1.1: Database Creation with Parameters
CREATE DATABASE university_main
    OWNER CURRENT_USER
    TEMPLATE template0
    ENCODING 'UTF8';

CREATE DATABASE university_archive
    CONNECTION LIMIT 50
    TEMPLATE template0;

CREATE DATABASE university_test
    IS_TEMPLATE true
    CONNECTION LIMIT 10;

-- Task 1.2: Tablespace Operations
CREATE TABLESPACE student_data
    LOCATION 'C:\data\students';

CREATE TABLESPACE course_data
    OWNER CURRENT_USER
    LOCATION 'C:\data\courses';

CREATE DATABASE university_distributed
    TABLESPACE student_data
    ENCODING 'UTF-8';

-- Part 2: Complex Table Creation

-- Task 2.1: University Management System
CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    phone CHAR(15),
    date_of_birth DATE,
    enrollment_date DATE,
    gpa NUMERIC(3, 2),
    is_active BOOLEAN,
    graduation_year SMALLINT
);

CREATE TABLE professors (
    professor_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    office_number VARCHAR(20),
    hire_date DATE,
    salary NUMERIC(10, 2),
    is_tenured BOOLEAN,
    years_experience INTEGER
);

CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    course_code CHAR(8) NOT NULL,
    course_title VARCHAR(100) NOT NULL,
    description TEXT,
    credits SMALLINT,
    max_enrollment INTEGER,
    course_fee NUMERIC(8, 2),
    is_online BOOLEAN,
    created_at TIMESTAMP
);

-- Task 2.2: Time-based and Specialized Tables
CREATE TABLE class_schedule (
    schedule_id SERIAL PRIMARY KEY,
    course_id INTEGER,
    professor_id INTEGER,
    classroom VARCHAR(20),
    class_date DATE,
    start_time TIME,
    end_time TIME,
    duration INTERVAL
);

CREATE TABLE student_records (
    record_id SERIAL PRIMARY KEY,
    student_id INTEGER,
    course_id INTEGER,
    semester VARCHAR(20),
    year INTEGER,
    grade CHAR(2),
    attendance_percentage NUMERIC(4, 1),
    submission_timestamp TIMESTAMPTZ,
    last_updated TIMESTAMPTZ
);

-- Part 3: Advanced ALTER TABLE Operations

-- Task 3.1: Modifying Existing Tables
ALTER TABLE students
ADD COLUMN middle_name VARCHAR(30),
ADD COLUMN student_status VARCHAR(20) DEFAULT 'ACTIVE',
ALTER COLUMN phone TYPE VARCHAR(20),
ALTER COLUMN gpa SET DEFAULT 0.00;

ALTER TABLE professors
ADD COLUMN department_code CHAR(5),
ADD COLUMN research_area TEXT,
ALTER COLUMN years_experience TYPE SMALLINT,
ALTER COLUMN is_tenured SET DEFAULT false,
ADD COLUMN last_promotion_date DATE;

ALTER TABLE courses
ADD COLUMN prerequisite_course_id INTEGER,
ADD COLUMN difficulty_level SMALLINT,
ALTER COLUMN course_code TYPE VARCHAR(10),
ALTER COLUMN credits SET DEFAULT 3,
ADD COLUMN lab_required BOOLEAN DEFAULT false;

-- Task 3.2: Column Management Operations
ALTER TABLE class_schedule
ADD COLUMN room_capacity INTEGER,
DROP COLUMN duration,
ADD COLUMN session_type VARCHAR(15),
ALTER COLUMN classroom TYPE VARCHAR(30),
ADD COLUMN equipment_needed TEXT;

ALTER TABLE student_records
ADD COLUMN extra_credit_points NUMERIC(3, 1) DEFAULT 0.0,
ALTER COLUMN grade TYPE VARCHAR(5),
ADD COLUMN final_exam_date DATE,
DROP COLUMN last_updated;

-- Part 4: Table Relationships and Management

-- Task 4.1: Additional Supporting Tables
CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL,
    department_code CHAR(5) NOT NULL,
    building VARCHAR(50),
    phone VARCHAR(15),
    budget NUMERIC(15, 2),
    established_year INTEGER
);

CREATE TABLE library_books (
    book_id SERIAL PRIMARY KEY,
    isbn CHAR(13) NOT NULL,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(100),
    publisher VARCHAR(100),
    publication_date DATE,
    price NUMERIC(8, 2),
    is_available BOOLEAN DEFAULT true,
    acquisition_timestamp TIMESTAMP
);

CREATE TABLE student_book_loans (
    loan_id SERIAL PRIMARY KEY,
    student_id INTEGER,
    book_id INTEGER,
    loan_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE,
    fine_amount NUMERIC(6, 2) DEFAULT 0.00,
    loan_status VARCHAR(20)
);

-- Task 4.2: Table Modifications for Integration
ALTER TABLE professors ADD COLUMN department_id INTEGER;
ALTER TABLE students ADD COLUMN advisor_id INTEGER;
ALTER TABLE courses ADD COLUMN department_id INTEGER;

CREATE TABLE grade_scale (
    grade_id SERIAL PRIMARY KEY,
    letter_grade CHAR(2) NOT NULL,
    min_percentage NUMERIC(5, 1),
    max_percentage NUMERIC(5, 1),
    gpa_points NUMERIC(3, 2) NOT NULL
);

CREATE TABLE semester_calendar (
    semester_id SERIAL PRIMARY KEY,
    semester_name VARCHAR(20) NOT NULL,
    academic_year INTEGER NOT NULL,
    start_date DATE,
    end_date DATE,
    registration_deadline TIMESTAMPTZ,
    is_current BOOLEAN DEFAULT false
);

-- Part 5: Table Deletion and Cleanup

-- Task 5.1: Conditional Table Operations
DROP TABLE IF EXISTS student_book_loans;
DROP TABLE IF EXISTS library_books;
DROP TABLE IF EXISTS grade_scale;

CREATE TABLE grade_scale (
    grade_id SERIAL PRIMARY KEY,
    letter_grade CHAR(2) NOT NULL,
    min_percentage NUMERIC(5, 1),
    max_percentage NUMERIC(5, 1),
    gpa_points NUMERIC(3, 2) NOT NULL,
    description TEXT
);

DROP TABLE semester_calendar CASCADE;

CREATE TABLE semester_calendar (
    semester_id SERIAL PRIMARY KEY,
    semester_name VARCHAR(20) NOT NULL,
    academic_year INTEGER NOT NULL,
    start_date DATE,
    end_date DATE,
    registration_deadline TIMESTAMPTZ,
    is_current BOOLEAN DEFAULT false
);

-- Task 5.2: Database Cleanup
DROP DATABASE IF EXISTS university_test;
DROP DATABASE IF EXISTS university_distributed;

CREATE DATABASE university_backup
    TEMPLATE university_main;