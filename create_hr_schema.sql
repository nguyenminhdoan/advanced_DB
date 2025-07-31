-- Connect as SYSTEM user and run this script in DBeaver
-- Make sure you're connected to XEPDB1 (pluggable database)

-- Step 1: Create HR user/schema (local user in PDB)
CREATE USER hr_admin IDENTIFIED BY hr_password123 CONTAINER = CURRENT;

-- Step 2: Grant necessary privileges
GRANT CONNECT TO hr_admin;
GRANT RESOURCE TO hr_admin;
GRANT CREATE TABLE TO hr_admin;
GRANT CREATE SEQUENCE TO hr_admin;
GRANT CREATE TRIGGER TO hr_admin;
GRANT CREATE PROCEDURE TO hr_admin;
GRANT CREATE VIEW TO hr_admin;
GRANT UNLIMITED TABLESPACE TO hr_admin;

-- Step 3: Create tables in HR_ADMIN schema
-- Connect as HR_ADMIN user (create new connection) or use ALTER SESSION

-- For now, let's create the tables in HR_ADMIN schema
-- You'll need to reconnect as HR_ADMIN user or run: ALTER SESSION SET CURRENT_SCHEMA=HR_ADMIN;

-- Create the tables structure (run after connecting as HR_ADMIN)
/*
-- Table: departments
CREATE TABLE departments (
    dp_id NUMBER(4) PRIMARY KEY,
    dp_name VARCHAR2(50) NOT NULL,
    location VARCHAR2(100),
    manager_id NUMBER(6)
);

-- Table: positions  
CREATE TABLE positions (
    pos_id NUMBER(4) PRIMARY KEY,
    position_title VARCHAR2(100) NOT NULL,
    min_salary NUMBER(8,2),
    max_salary NUMBER(8,2),
    dp_id NUMBER(4) REFERENCES departments(dp_id)
);

-- Table: employees
CREATE TABLE employees (
    emp_id NUMBER(6) PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    email VARCHAR2(100) UNIQUE,
    phone VARCHAR2(20),
    hire_date DATE DEFAULT SYSDATE,
    pos_id NUMBER(4) REFERENCES positions(pos_id),
    salary NUMBER(8,2),
    supervisor_id NUMBER(6) REFERENCES employees(emp_id),
    status VARCHAR2(20) DEFAULT 'ACTIVE'
);

-- Table: leave_requests
CREATE TABLE leave_requests (
    leave_id NUMBER(6) PRIMARY KEY,
    emp_id NUMBER(6) REFERENCES employees(emp_id),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    reason VARCHAR2(500),
    status VARCHAR2(20) DEFAULT 'PENDING',
    approver_id NUMBER(6) REFERENCES employees(emp_id),
    request_date DATE DEFAULT SYSDATE
);

-- Table: performance_review
CREATE TABLE performance_review (
    perf_id NUMBER(6) PRIMARY KEY,
    emp_id NUMBER(6) REFERENCES employees(emp_id),
    review_date DATE DEFAULT SYSDATE,
    teamwork NUMBER(4,1) CHECK (teamwork BETWEEN 1 AND 10),
    creativity NUMBER(4,1) CHECK (creativity BETWEEN 1 AND 10),
    knowledge NUMBER(4,1) CHECK (knowledge BETWEEN 1 AND 10),
    overall_score NUMBER(4,1),
    reviewer_id NUMBER(6) REFERENCES employees(emp_id),
    comments VARCHAR2(1000)
);

-- Table: audit_log
CREATE TABLE audit_log (
    log_id NUMBER(10) PRIMARY KEY,
    table_name VARCHAR2(50) NOT NULL,
    operation VARCHAR2(20) NOT NULL,
    emp_id NUMBER(6),
    old_values CLOB,
    new_values CLOB,
    changed_by VARCHAR2(50) DEFAULT USER,
    change_date DATE DEFAULT SYSDATE
);

-- Create sequences
CREATE SEQUENCE seq_dept_id START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_pos_id START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_emp_id START WITH 1001 INCREMENT BY 1;
CREATE SEQUENCE seq_leave_id START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_perf_id START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_audit_id START WITH 1 INCREMENT BY 1;
*/

-- Step 4: Show connection information
SELECT 'HR Schema created successfully!' as status FROM dual;
SELECT 'Next: Connect as HR_ADMIN user with password: hr_password123' as next_step FROM dual;