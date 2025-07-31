-- Run this script in DBeaver as SYS user
-- First create a connection in DBeaver as:
-- Username: SYS
-- Password: YourPassword123
-- Role: SYSDBA
-- Database: XEPDB1

-- Unlock and reset SYSTEM account
ALTER USER SYSTEM ACCOUNT UNLOCK;
ALTER USER SYSTEM IDENTIFIED BY YourPassword123;

-- Check if account is unlocked
SELECT username, account_status, lock_date 
FROM dba_users 
WHERE username = 'SYSTEM';

-- Grant necessary privileges to SYSTEM in PDB
GRANT CONNECT, RESOURCE TO SYSTEM;
GRANT UNLIMITED TABLESPACE TO SYSTEM;

SELECT 'SYSTEM account unlocked successfully!' as status FROM dual;