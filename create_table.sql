-- ========================================
-- HR MANAGEMENT SYSTEM - ORACLE DATABASE SCRIPT
-- COMP214 - Advanced Database Concepts
-- ========================================

-- Clean up existing objects (optional - for re-running script)
DROP TABLE performance_review CASCADE CONSTRAINTS;
DROP TABLE leave_request CASCADE CONSTRAINTS;
DROP TABLE employees CASCADE CONSTRAINTS;
DROP TABLE position CASCADE CONSTRAINTS;
DROP TABLE department CASCADE CONSTRAINTS;
DROP SEQUENCE emp_seq;
DROP SEQUENCE dept_seq;
DROP SEQUENCE pos_seq;
DROP SEQUENCE leave_seq;
DROP SEQUENCE perf_seq;
DROP PACKAGE hr_management_pkg;

-- ========================================
-- 1. CREATE TABLES WITH CONSTRAINTS
-- ========================================

-- Department Table
CREATE TABLE department (
    dp_id NUMBER(5) PRIMARY KEY,
    dp_name VARCHAR2(50) NOT NULL UNIQUE,
    manager_id NUMBER(5),
    created_date DATE DEFAULT SYSDATE,
    CONSTRAINT chk_dept_name CHECK (LENGTH(dp_name) >= 2)
);

-- Position Table
CREATE TABLE position (
    position_id NUMBER(5) PRIMARY KEY,
    position_title VARCHAR2(100) NOT NULL,
    salary NUMBER(10,2) NOT NULL,
    dp_id NUMBER(5),
    created_date DATE DEFAULT SYSDATE,
    CONSTRAINT chk_salary CHECK (salary > 0),
    CONSTRAINT fk_pos_dept FOREIGN KEY (dp_id) REFERENCES department(dp_id)
);

-- Employees Table
CREATE TABLE employees (
    emp_id NUMBER(5) PRIMARY KEY,
    position_id NUMBER(5) NOT NULL,
    fname VARCHAR2(50) NOT NULL,
    lname VARCHAR2(50) NOT NULL,
    email VARCHAR2(100) NOT NULL UNIQUE,
    phone VARCHAR2(15),
    hire_date DATE DEFAULT SYSDATE,
    end_date DATE,
    supervisor_id NUMBER(5),
    is_active CHAR(1) DEFAULT 'Y',
    created_date DATE DEFAULT SYSDATE,
    CONSTRAINT chk_email CHECK (email LIKE '%@%.%'),
    CONSTRAINT chk_hire_end_date CHECK (end_date IS NULL OR end_date >= hire_date),
    CONSTRAINT chk_is_active CHECK (is_active IN ('Y', 'N')),
    CONSTRAINT fk_emp_position FOREIGN KEY (position_id) REFERENCES position(position_id),
    CONSTRAINT fk_emp_supervisor FOREIGN KEY (supervisor_id) REFERENCES employees(emp_id)
);

-- Add foreign key constraint for department manager after employees table is created
ALTER TABLE department ADD CONSTRAINT fk_dept_manager FOREIGN KEY (manager_id) REFERENCES employees(emp_id);

-- Leave Request Table
CREATE TABLE leave_request (
    leave_id NUMBER(5) PRIMARY KEY,
    emp_id NUMBER(5) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    reason VARCHAR2(500),
    status VARCHAR2(20) DEFAULT 'PENDING',
    approved_by NUMBER(5),
    request_date DATE DEFAULT SYSDATE,
    CONSTRAINT chk_leave_dates CHECK (end_date >= start_date),
    CONSTRAINT chk_leave_status CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED')),
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_id) REFERENCES employees(emp_id),
    CONSTRAINT fk_leave_approver FOREIGN KEY (approved_by) REFERENCES employees(emp_id)
);

-- Performance Review Table
CREATE TABLE performance_review (
    perf_id NUMBER(5) PRIMARY KEY,
    emp_id NUMBER(5) NOT NULL,
    review_date DATE DEFAULT SYSDATE,
    teamwork NUMBER(2) NOT NULL,
    creativity NUMBER(2) NOT NULL,
    knowledge NUMBER(2) NOT NULL,
    overall_score NUMBER(3,1),
    reviewer_id NUMBER(5),
    comments VARCHAR2(1000),
    CONSTRAINT chk_teamwork CHECK (teamwork BETWEEN 1 AND 10),
    CONSTRAINT chk_creativity CHECK (creativity BETWEEN 1 AND 10),
    CONSTRAINT chk_knowledge CHECK (knowledge BETWEEN 1 AND 10),
    CONSTRAINT chk_overall_score CHECK (overall_score BETWEEN 1 AND 10),
    CONSTRAINT fk_perf_emp FOREIGN KEY (emp_id) REFERENCES employees(emp_id),
    CONSTRAINT fk_perf_reviewer FOREIGN KEY (reviewer_id) REFERENCES employees(emp_id)
);

-- Audit Log Table
CREATE TABLE audit_log (
    log_id NUMBER(10) PRIMARY KEY,
    table_name VARCHAR2(50),
    operation VARCHAR2(10),
    emp_id NUMBER(5),
    old_values VARCHAR2(4000),
    new_values VARCHAR2(4000),
    change_date DATE DEFAULT SYSDATE,
    changed_by VARCHAR2(50) DEFAULT USER
);

