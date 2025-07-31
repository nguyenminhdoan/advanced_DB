-- Run this ONLY if you're stuck in CDB$ROOT
-- Common users must start with C##

CREATE USER C##hr_admin IDENTIFIED BY hr_password123 CONTAINER = ALL;

GRANT CONNECT, RESOURCE TO C##hr_admin CONTAINER = ALL;
GRANT CREATE TABLE TO C##hr_admin CONTAINER = ALL;
GRANT CREATE SEQUENCE TO C##hr_admin CONTAINER = ALL;
GRANT CREATE TRIGGER TO C##hr_admin CONTAINER = ALL;
GRANT CREATE PROCEDURE TO C##hr_admin CONTAINER = ALL;
GRANT UNLIMITED TABLESPACE TO C##hr_admin CONTAINER = ALL;

SELECT 'Common user C##hr_admin created' as status FROM dual;