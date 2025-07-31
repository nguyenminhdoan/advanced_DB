-- Check current user and schema
SELECT USER AS current_user FROM dual;

-- Show all schemas that have tables
SELECT DISTINCT owner 
FROM all_tables 
WHERE owner NOT IN ('SYS', 'SYSTEM', 'OUTLN', 'DIP', 'ORACLE_OCM', 'DBSNMP', 'APPQOSSYS', 'WMSYS', 'EXFSYS', 'CTXSYS', 'ANONYMOUS', 'XDB', 'XS$NULL', 'OJVMSYS', 'LBACSYS', 'APEX_040000', 'APEX_PUBLIC_USER', 'FLOWS_FILES', 'MDSYS', 'ORDSYS', 'ORDDATA', 'ORDPLUGINS', 'SYSMAN', 'SI_INFORMTN_SCHEMA')
ORDER BY owner;

-- Show your tables if they exist in current schema
SELECT table_name 
FROM user_tables 
ORDER BY table_name;

-- Show all tables that might be yours (look for HR-related names)
SELECT owner, table_name 
FROM all_tables 
WHERE table_name IN ('EMPLOYEES', 'DEPARTMENTS', 'POSITIONS', 'LEAVE_REQUESTS', 'PERFORMANCE_REVIEW', 'AUDIT_LOG')
ORDER BY owner, table_name;

-- Show all schemas and table counts
SELECT owner, COUNT(*) as table_count
FROM all_tables 
GROUP BY owner 
ORDER BY table_count DESC;