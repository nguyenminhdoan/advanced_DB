-- Run this script as SYSTEM user to copy data from SYSTEM schema to HR_ADMIN schema
-- Make sure HR_ADMIN schema and tables are created first

-- Step 1: Copy departments data
INSERT INTO hr_admin.departments 
SELECT * FROM system.departments;

-- Step 2: Copy positions data  
INSERT INTO hr_admin.positions 
SELECT * FROM system.positions;

-- Step 3: Copy employees data
INSERT INTO hr_admin.employees 
SELECT * FROM system.employees;

-- Step 4: Copy leave_requests data
INSERT INTO hr_admin.leave_requests 
SELECT * FROM system.leave_requests;

-- Step 5: Copy performance_review data
INSERT INTO hr_admin.performance_review 
SELECT * FROM system.performance_review;

-- Step 6: Copy audit_log data
INSERT INTO hr_admin.audit_log 
SELECT * FROM system.audit_log;

-- Commit the changes
COMMIT;

-- Verify data was copied
SELECT 'Departments: ' || COUNT(*) as count FROM hr_admin.departments
UNION ALL
SELECT 'Positions: ' || COUNT(*) FROM hr_admin.positions  
UNION ALL
SELECT 'Employees: ' || COUNT(*) FROM hr_admin.employees
UNION ALL
SELECT 'Leave Requests: ' || COUNT(*) FROM hr_admin.leave_requests
UNION ALL
SELECT 'Performance Reviews: ' || COUNT(*) FROM hr_admin.performance_review
UNION ALL
SELECT 'Audit Logs: ' || COUNT(*) FROM hr_admin.audit_log;