-- Alternative approach: Create user in the current container
-- Run as SYSTEM user in XEPDB1

-- Check current container
SELECT SYS_CONTEXT('USERENV', 'CON_NAME') as current_container FROM dual;

-- Create local user (works in PDB)
CREATE USER hruser IDENTIFIED BY hrpass123;

-- Grant privileges
GRANT CONNECT, RESOURCE TO hruser;
GRANT CREATE TABLE TO hruser;
GRANT CREATE SEQUENCE TO hruser;
GRANT CREATE TRIGGER TO hruser;
GRANT CREATE PROCEDURE TO hruser;
GRANT CREATE VIEW TO hruser;
GRANT UNLIMITED TABLESPACE TO hruser;

-- Verify user was created
SELECT username FROM all_users WHERE username = 'HRUSER';

SELECT 'HR User created successfully!' as status FROM dual;