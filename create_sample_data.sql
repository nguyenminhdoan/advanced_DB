-- ========================================
-- 8. INSERT SAMPLE DATA
-- ========================================

-- Insert departments
INSERT INTO department (dp_id, dp_name) VALUES (dept_seq.NEXTVAL, 'Human Resources');
INSERT INTO department (dp_id, dp_name) VALUES (dept_seq.NEXTVAL, 'Information Technology');
INSERT INTO department (dp_id, dp_name) VALUES (dept_seq.NEXTVAL, 'Finance');
INSERT INTO department (dp_id, dp_name) VALUES (dept_seq.NEXTVAL, 'Marketing');
INSERT INTO department (dp_id, dp_name) VALUES (dept_seq.NEXTVAL, 'Operations');

-- Insert positions
INSERT INTO position (position_id, position_title, salary, dp_id) VALUES (pos_seq.NEXTVAL, 'HR Manager', 85000, 101);
INSERT INTO position (position_id, position_title, salary, dp_id) VALUES (pos_seq.NEXTVAL, 'HR Specialist', 65000, 101);
INSERT INTO position (position_id, position_title, salary, dp_id) VALUES (pos_seq.NEXTVAL, 'IT Manager', 95000, 102);
INSERT INTO position (position_id, position_title, salary, dp_id) VALUES (pos_seq.NEXTVAL, 'Software Developer', 75000, 102);
INSERT INTO position (position_id, position_title, salary, dp_id) VALUES (pos_seq.NEXTVAL, 'System Administrator', 70000, 102);
INSERT INTO position (position_id, position_title, salary, dp_id) VALUES (pos_seq.NEXTVAL, 'Finance Manager', 90000, 103);
INSERT INTO position (position_id, position_title, salary, dp_id) VALUES (pos_seq.NEXTVAL, 'Accountant', 60000, 103);
INSERT INTO position (position_id, position_title, salary, dp_id) VALUES (pos_seq.NEXTVAL, 'Marketing Manager', 88000, 104);
INSERT INTO position (position_id, position_title, salary, dp_id) VALUES (pos_seq.NEXTVAL, 'Marketing Specialist', 55000, 104);
INSERT INTO position (position_id, position_title, salary, dp_id) VALUES (pos_seq.NEXTVAL, 'Operations Manager', 92000, 105);

-- Insert employees (managers first, then staff)
INSERT INTO employees (emp_id, position_id, fname, lname, email, phone, hire_date) 
VALUES (emp_seq.NEXTVAL, 201, 'Sarah', 'Johnson', 'sarah.johnson@company.com', '416-555-0101', DATE '2020-01-15');

INSERT INTO employees (emp_id, position_id, fname, lname, email, phone, hire_date) 
VALUES (emp_seq.NEXTVAL, 203, 'Michael', 'Chen', 'michael.chen@company.com', '416-555-0102', DATE '2019-03-20');

INSERT INTO employees (emp_id, position_id, fname, lname, email, phone, hire_date) 
VALUES (emp_seq.NEXTVAL, 206, 'Jennifer', 'Williams', 'jennifer.williams@company.com', '416-555-0103', DATE '2018-06-10');

INSERT INTO employees (emp_id, position_id, fname, lname, email, phone, hire_date) 
VALUES (emp_seq.NEXTVAL, 208, 'David', 'Brown', 'david.brown@company.com', '416-555-0104', DATE '2021-02-28');

INSERT INTO employees (emp_id, position_id, fname, lname, email, phone, hire_date) 
VALUES (emp_seq.NEXTVAL, 210, 'Lisa', 'Davis', 'lisa.davis@company.com', '416-555-0105', DATE '2019-11-05');

-- Insert staff with supervisors
INSERT INTO employees (emp_id, position_id, fname, lname, email, phone, hire_date, supervisor_id) 
VALUES (emp_seq.NEXTVAL, 202, 'Robert', 'Miller', 'robert.miller@company.com', '416-555-0106', DATE '2021-05-12', 1001);

INSERT INTO employees (emp_id, position_id, fname, lname, email, phone, hire_date, supervisor_id) 
VALUES (emp_seq.NEXTVAL, 204, 'Emily', 'Wilson', 'emily.wilson@company.com', '416-555-0107', DATE '2020-08-18', 1002);

INSERT INTO employees (emp_id, position_id, fname, lname, email, phone, hire_date, supervisor_id) 
VALUES (emp_seq.NEXTVAL, 205, 'James', 'Anderson', 'james.anderson@company.com', '416-555-0108', DATE '2022-01-10', 1002);

INSERT INTO employees (emp_id, position_id, fname, lname, email, phone, hire_date, supervisor_id) 
VALUES (emp_seq.NEXTVAL, 207, 'Amanda', 'Taylor', 'amanda.taylor@company.com', '416-555-0109', DATE '2021-09-15', 1003);

INSERT INTO employees (emp_id, position_id, fname, lname, email, phone, hire_date, supervisor_id) 
VALUES (emp_seq.NEXTVAL, 209, 'Christopher', 'Martinez', 'christopher.martinez@company.com', '416-555-0110', DATE '2020-12-03', 1004);

-- Additional employees
INSERT INTO employees (emp_id, position_id, fname, lname, email, phone, hire_date, supervisor_id) 
VALUES (emp_seq.NEXTVAL, 204, 'Jessica', 'Garcia', 'jessica.garcia@company.com', '416-555-0111', DATE '2021-07-22', 1002);

INSERT INTO employees (emp_id, position_id, fname, lname, email, phone, hire_date, supervisor_id) 
VALUES (emp_seq.NEXTVAL, 207, 'Daniel', 'Rodriguez', 'daniel.rodriguez@company.com', '416-555-0112', DATE '2022-03-14', 1003);

INSERT INTO employees (emp_id, position_id, fname, lname, email, phone, hire_date, supervisor_id) 
VALUES (emp_seq.NEXTVAL, 209, 'Rachel', 'Lee', 'rachel.lee@company.com', '416-555-0113', DATE '2021-11-08', 1004);

-- Update department managers
UPDATE department SET manager_id = 1001 WHERE dp_id = 101; -- HR
UPDATE department SET manager_id = 1002 WHERE dp_id = 102; -- IT
UPDATE department SET manager_id = 1003 WHERE dp_id = 103; -- Finance
UPDATE department SET manager_id = 1004 WHERE dp_id = 104; -- Marketing
UPDATE department SET manager_id = 1005 WHERE dp_id = 105; -- Operations

-- Insert leave requests
INSERT INTO leave_request (leave_id, emp_id, start_date, end_date, reason, status, approved_by) 
VALUES (leave_seq.NEXTVAL, 1006, DATE '2024-08-15', DATE '2024-08-19', 'Vacation', 'APPROVED', 1001);

INSERT INTO leave_request (leave_id, emp_id, start_date, end_date, reason, status, approved_by) 
VALUES (leave_seq.NEXTVAL, 1007, DATE '2024-07-22', DATE '2024-07-26', 'Personal time', 'APPROVED', 1002);

INSERT INTO leave_request (leave_id, emp_id, start_date, end_date, reason, status) 
VALUES (leave_seq.NEXTVAL, 1008, DATE '2024-09-10', DATE '2024-09-12', 'Medical appointment', 'PENDING');

INSERT INTO leave_request (leave_id, emp_id, start_date, end_date, reason, status, approved_by) 
VALUES (leave_seq.NEXTVAL, 1009, DATE '2024-06-05', DATE '2024-06-07', 'Family event', 'APPROVED', 1003);

INSERT INTO leave_request (leave_id, emp_id, start_date, end_date, reason, status) 
VALUES (leave_seq.NEXTVAL, 1010, DATE '2024-08-28', DATE '2024-08-30', 'Conference attendance', 'PENDING');

INSERT INTO leave_request (leave_id, emp_id, start_date, end_date, reason, status, approved_by) 
VALUES (leave_seq.NEXTVAL, 1011, DATE '2024-07-08', DATE '2024-07-12', 'Vacation', 'APPROVED', 1002);

INSERT INTO leave_request (leave_id, emp_id, start_date, end_date, reason, status) 
VALUES (leave_seq.NEXTVAL, 1012, DATE '2024-09-02', DATE '2024-09-06', 'Personal leave', 'PENDING');

-- Insert performance reviews
INSERT INTO performance_review (perf_id, emp_id, teamwork, creativity, knowledge, reviewer_id, comments) 
VALUES (perf_seq.NEXTVAL, 1006, 8, 7, 9, 1001, 'Excellent team player with strong technical skills');

INSERT INTO performance_review (perf_id, emp_id, teamwork, creativity, knowledge, reviewer_id, comments) 
VALUES (perf_seq.NEXTVAL, 1007, 9, 8, 8, 1002, 'Outstanding problem-solving abilities and collaboration');

INSERT INTO performance_review (perf_id, emp_id, teamwork, creativity, knowledge, reviewer_id, comments) 
VALUES (perf_seq.NEXTVAL, 1008, 7, 6, 8, 1002, 'Good technical knowledge, room for improvement in innovation');

INSERT INTO performance_review (perf_id, emp_id, teamwork, creativity, knowledge, reviewer_id, comments) 
VALUES (perf_seq.NEXTVAL, 1009, 8, 9, 7, 1003, 'Very creative approach to financial analysis');

INSERT INTO performance_review (perf_id, emp_id, teamwork, creativity, knowledge, reviewer_id, comments) 
VALUES (perf_seq.NEXTVAL, 1010, 9, 8, 9, 1004, 'Exceptional marketing campaigns and team leadership');

INSERT INTO performance_review (perf_id, emp_id, teamwork, creativity, knowledge, reviewer_id, comments) 
VALUES (perf_seq.NEXTVAL, 1011, 8, 7, 8, 1002, 'Solid performer with consistent delivery');

INSERT INTO performance_review (perf_id, emp_id, teamwork, creativity, knowledge, reviewer_id, comments) 
VALUES (perf_seq.NEXTVAL, 1012, 7, 8, 6, 1003, 'Shows potential, needs more experience');

INSERT INTO performance_review (perf_id, emp_id, teamwork, creativity, knowledge, reviewer_id, comments) 
VALUES (perf_seq.NEXTVAL, 1013, 9, 9, 8, 1004, 'Creative and innovative marketing strategies');

-- Additional performance reviews for some employees (multiple reviews)
INSERT INTO performance_review (perf_id, emp_id, review_date, teamwork, creativity, knowledge, reviewer_id, comments) 
VALUES (perf_seq.NEXTVAL, 1007, DATE '2024-01-15', 8, 7, 8, 1002, 'Mid-year review - consistent performance');

INSERT INTO performance_review (perf_id, emp_id, review_date, teamwork, creativity, knowledge, reviewer_id, comments) 
VALUES (perf_seq.NEXTVAL, 1010, DATE '2024-02-20', 9, 9, 8, 1004, 'Quarterly review - exceeds expectations');

COMMIT;

-- ========================================
-- 9. SAMPLE TEST SCRIPTS
-- ========================================

-- Display all created objects
SELECT 'TABLES' as object_type, table_name as object_name FROM user_tables WHERE table_name IN ('EMPLOYEES','DEPARTMENT','POSITION','LEAVE_REQUEST','PERFORMANCE_REVIEW','AUDIT_LOG')
UNION ALL
SELECT 'SEQUENCES', sequence_name FROM user_sequences WHERE sequence_name LIKE '%_SEQ'
UNION ALL
SELECT 'INDEXES', index_name FROM user_indexes WHERE table_name IN ('EMPLOYEES','DEPARTMENT','POSITION','LEAVE_REQUEST','PERFORMANCE_REVIEW') AND index_name NOT LIKE 'SYS_%'
UNION ALL
SELECT 'TRIGGERS', trigger_name FROM user_triggers WHERE trigger_name LIKE 'TRG_%'
UNION ALL
SELECT 'PROCEDURES', object_name FROM user_objects WHERE object_type = 'PROCEDURE'
UNION ALL
SELECT 'FUNCTIONS', object_name FROM user_objects WHERE object_type = 'FUNCTION'
UNION ALL
SELECT 'PACKAGES', object_name FROM user_objects WHERE object_type = 'PACKAGE'
ORDER BY object_type, object_name;

-- Test sequences
SELECT 'Current sequence values:' as info FROM dual;
SELECT 'emp_seq: ' || emp_seq.CURRVAL as seq_value FROM dual;
SELECT 'dept_seq: ' || dept_seq.CURRVAL as seq_value FROM dual;
SELECT 'pos_seq: ' || pos_seq.CURRVAL as seq_value FROM dual;
SELECT 'leave_seq: ' || leave_seq.CURRVAL as seq_value FROM dual;
SELECT 'perf_seq: ' || perf_seq.CURRVAL as seq_value FROM dual;
