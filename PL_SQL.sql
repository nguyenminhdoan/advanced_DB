-- ========================================
-- 2. CREATE SEQUENCES
-- ========================================

CREATE SEQUENCE emp_seq
    START WITH 1001
    INCREMENT BY 1
    NOCACHE;

CREATE SEQUENCE dept_seq
    START WITH 101
    INCREMENT BY 1
    NOCACHE;

CREATE SEQUENCE pos_seq
    START WITH 201
    INCREMENT BY 1
    NOCACHE;

CREATE SEQUENCE leave_seq
    START WITH 301
    INCREMENT BY 1
    NOCACHE;

CREATE SEQUENCE perf_seq
    START WITH 401
    INCREMENT BY 1
    NOCACHE;

CREATE SEQUENCE audit_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE;

-- ========================================
-- 3. CREATE INDEXES
-- ========================================

-- Index for employee email searches
CREATE INDEX idx_emp_email ON employees(email);

-- Index for employee name searches
CREATE INDEX idx_emp_name ON employees(lname, fname);

-- Index for leave request status searches
CREATE INDEX idx_leave_status ON leave_request(status, start_date);

-- Index for performance review searches
CREATE INDEX idx_perf_emp_date ON performance_review(emp_id, review_date);

-- Composite index for active employees
CREATE INDEX idx_emp_active_pos ON employees(is_active, position_id);

-- ========================================
-- 4. CREATE TRIGGERS
-- ========================================

-- Trigger 1: Auto-calculate overall score in performance reviews
CREATE OR REPLACE TRIGGER trg_calculate_overall_score
    BEFORE INSERT OR UPDATE ON performance_review
    FOR EACH ROW
BEGIN
    :NEW.overall_score := ROUND((:NEW.teamwork + :NEW.creativity + :NEW.knowledge) / 3, 1);
END;
/

-- Trigger 2: Audit trigger for employee changes
CREATE OR REPLACE TRIGGER trg_emp_audit
    AFTER INSERT OR UPDATE OR DELETE ON employees
    FOR EACH ROW
DECLARE
    v_operation VARCHAR2(10);
    v_old_vals VARCHAR2(4000);
    v_new_vals VARCHAR2(4000);
BEGIN
    IF INSERTING THEN
        v_operation := 'INSERT';
        v_new_vals := 'ID:' || :NEW.emp_id || ',Name:' || :NEW.fname || ' ' || :NEW.lname || ',Email:' || :NEW.email;
    ELSIF UPDATING THEN
        v_operation := 'UPDATE';
        v_old_vals := 'ID:' || :OLD.emp_id || ',Name:' || :OLD.fname || ' ' || :OLD.lname || ',Email:' || :OLD.email;
        v_new_vals := 'ID:' || :NEW.emp_id || ',Name:' || :NEW.fname || ' ' || :NEW.lname || ',Email:' || :NEW.email;
    ELSIF DELETING THEN
        v_operation := 'DELETE';
        v_old_vals := 'ID:' || :OLD.emp_id || ',Name:' || :OLD.fname || ' ' || :OLD.lname || ',Email:' || :OLD.email;
    END IF;
    
    INSERT INTO audit_log (log_id, table_name, operation, emp_id, old_values, new_values)
    VALUES (audit_seq.NEXTVAL, 'EMPLOYEES', v_operation, 
            NVL(:NEW.emp_id, :OLD.emp_id), v_old_vals, v_new_vals);
END;
/

-- ========================================
-- 5. CREATE PROCEDURES
-- ========================================

-- Procedure 1: Add new employee with exception handling
CREATE OR REPLACE PROCEDURE add_employee(
    p_position_id IN NUMBER,
    p_fname IN VARCHAR2,
    p_lname IN VARCHAR2,
    p_email IN VARCHAR2,
    p_phone IN VARCHAR2,
    p_supervisor_id IN NUMBER DEFAULT NULL,
    p_emp_id OUT NUMBER
) AS
    e_invalid_position EXCEPTION;
    e_invalid_supervisor EXCEPTION;
    v_pos_count NUMBER;
    v_sup_count NUMBER;
BEGIN
    -- Validate position exists
    SELECT COUNT(*) INTO v_pos_count FROM position WHERE position_id = p_position_id;
    IF v_pos_count = 0 THEN
        RAISE e_invalid_position;
    END IF;
    
    -- Validate supervisor exists if provided
    IF p_supervisor_id IS NOT NULL THEN
        SELECT COUNT(*) INTO v_sup_count FROM employees 
        WHERE emp_id = p_supervisor_id AND is_active = 'Y';
        IF v_sup_count = 0 THEN
            RAISE e_invalid_supervisor;
        END IF;
    END IF;
    
    -- Insert new employee
    p_emp_id := emp_seq.NEXTVAL;
    INSERT INTO employees (emp_id, position_id, fname, lname, email, phone, supervisor_id)
    VALUES (p_emp_id, p_position_id, p_fname, p_lname, p_email, p_phone, p_supervisor_id);
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Employee added successfully with ID: ' || p_emp_id);
    
EXCEPTION
    WHEN e_invalid_position THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'Invalid position ID provided');
    WHEN e_invalid_supervisor THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20002, 'Invalid supervisor ID provided');
    WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20003, 'Email already exists in system');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20004, 'Error adding employee: ' || SQLERRM);
END;
/

-- Procedure 2: Process leave requests using cursor
CREATE OR REPLACE PROCEDURE process_pending_leaves(
    p_approver_id IN NUMBER,
    p_days_threshold IN NUMBER DEFAULT 30
) AS
    CURSOR c_leave_requests IS
        SELECT lr.leave_id, lr.emp_id, lr.start_date, lr.end_date,
               e.fname || ' ' || e.lname as emp_name,
               (lr.end_date - lr.start_date + 1) as leave_days
        FROM leave_request lr
        JOIN employees e ON lr.emp_id = e.emp_id
        WHERE lr.status = 'PENDING'
        ORDER BY lr.request_date;
    
    v_leave_rec c_leave_requests%ROWTYPE;
    v_processed_count NUMBER := 0;
    e_invalid_approver EXCEPTION;
    v_approver_count NUMBER;
BEGIN
    -- Validate approver
    SELECT COUNT(*) INTO v_approver_count FROM employees 
    WHERE emp_id = p_approver_id AND is_active = 'Y';
    
    IF v_approver_count = 0 THEN
        RAISE e_invalid_approver;
    END IF;
    
    -- Process leave requests
    OPEN c_leave_requests;
    LOOP
        FETCH c_leave_requests INTO v_leave_rec;
        EXIT WHEN c_leave_requests%NOTFOUND;
        
        -- Auto-approve leaves <= threshold days, others need manual review
        IF v_leave_rec.leave_days <= p_days_threshold THEN
            UPDATE leave_request 
            SET status = 'APPROVED', approved_by = p_approver_id
            WHERE leave_id = v_leave_rec.leave_id;
            
            v_processed_count := v_processed_count + 1;
            DBMS_OUTPUT.PUT_LINE('Approved leave for ' || v_leave_rec.emp_name || 
                               ' (' || v_leave_rec.leave_days || ' days)');
        END IF;
    END LOOP;
    CLOSE c_leave_requests;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Total leaves processed: ' || v_processed_count);
    
EXCEPTION
    WHEN e_invalid_approver THEN
        IF c_leave_requests%ISOPEN THEN CLOSE c_leave_requests; END IF;
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20005, 'Invalid approver ID');
    WHEN OTHERS THEN
        IF c_leave_requests%ISOPEN THEN CLOSE c_leave_requests; END IF;
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20006, 'Error processing leaves: ' || SQLERRM);
END;
/

-- ========================================
-- 6. CREATE FUNCTIONS
-- ========================================

-- Function 1: Calculate employee tenure in years
CREATE OR REPLACE FUNCTION get_employee_tenure(
    p_emp_id IN NUMBER
) RETURN NUMBER AS
    v_hire_date DATE;
    v_end_date DATE;
    v_tenure NUMBER;
    e_emp_not_found EXCEPTION;
BEGIN
    SELECT hire_date, end_date 
    INTO v_hire_date, v_end_date
    FROM employees 
    WHERE emp_id = p_emp_id;
    
    IF v_end_date IS NULL THEN
        v_tenure := ROUND((SYSDATE - v_hire_date) / 365.25, 2);
    ELSE
        v_tenure := ROUND((v_end_date - v_hire_date) / 365.25, 2);
    END IF;
    
    RETURN v_tenure;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE e_emp_not_found;
    WHEN e_emp_not_found THEN
        RAISE_APPLICATION_ERROR(-20007, 'Employee not found');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20008, 'Error calculating tenure: ' || SQLERRM);
END;
/

-- Function 2: Get department average salary
CREATE OR REPLACE FUNCTION get_dept_avg_salary(
    p_dept_id IN NUMBER
) RETURN NUMBER AS
    v_avg_salary NUMBER;
    e_dept_not_found EXCEPTION;
    v_dept_count NUMBER;
BEGIN
    -- Check if department exists
    SELECT COUNT(*) INTO v_dept_count FROM department WHERE dp_id = p_dept_id;
    IF v_dept_count = 0 THEN
        RAISE e_dept_not_found;
    END IF;
    
    SELECT NVL(AVG(p.salary), 0)
    INTO v_avg_salary
    FROM employees e
    JOIN position p ON e.position_id = p.position_id
    WHERE p.dp_id = p_dept_id AND e.is_active = 'Y';
    
    RETURN ROUND(v_avg_salary, 2);
    
EXCEPTION
    WHEN e_dept_not_found THEN
        RAISE_APPLICATION_ERROR(-20009, 'Department not found');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20010, 'Error calculating average salary: ' || SQLERRM);
END;
/

-- ========================================
-- 7. CREATE PACKAGE
-- ========================================

CREATE OR REPLACE PACKAGE hr_management_pkg AS
    -- Global variables
    g_max_leave_days CONSTANT NUMBER := 30;
    g_min_performance_score CONSTANT NUMBER := 1;
    g_max_performance_score CONSTANT NUMBER := 10;
    
    -- Type definitions
    TYPE emp_record_type IS RECORD (
        emp_id employees.emp_id%TYPE,
        full_name VARCHAR2(101),
        position_title position.position_title%TYPE,
        salary position.salary%TYPE,
        tenure NUMBER
    );
    
    TYPE emp_table_type IS TABLE OF emp_record_type INDEX BY PLS_INTEGER;
    
    -- Public procedures and functions
    PROCEDURE get_department_employees(
        p_dept_id IN NUMBER,
        p_emp_list OUT emp_table_type
    );
    
    FUNCTION calculate_annual_leave_balance(
        p_emp_id IN NUMBER,
        p_year IN NUMBER DEFAULT EXTRACT(YEAR FROM SYSDATE)
    ) RETURN NUMBER;
    
    PROCEDURE generate_performance_report(
        p_dept_id IN NUMBER,
        p_year IN NUMBER DEFAULT EXTRACT(YEAR FROM SYSDATE)
    );
    
    FUNCTION get_top_performers(
        p_dept_id IN NUMBER DEFAULT NULL,
        p_limit IN NUMBER DEFAULT 5
    ) RETURN emp_table_type;
    
END hr_management_pkg;
/

CREATE OR REPLACE PACKAGE BODY hr_management_pkg AS
    -- Private variables
    v_report_generated_date DATE;
    
    -- Private function
    FUNCTION get_employee_full_name(p_emp_id IN NUMBER) RETURN VARCHAR2 AS
        v_full_name VARCHAR2(101);
    BEGIN
        SELECT fname || ' ' || lname INTO v_full_name
        FROM employees WHERE emp_id = p_emp_id;
        RETURN v_full_name;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'Unknown Employee';
    END;
    
    -- Public procedure implementation
    PROCEDURE get_department_employees(
        p_dept_id IN NUMBER,
        p_emp_list OUT emp_table_type
    ) AS
        CURSOR c_dept_emp IS
            SELECT e.emp_id, e.fname || ' ' || e.lname as full_name,
                   pos.position_title, pos.salary
            FROM employees e
            JOIN position pos ON e.position_id = pos.position_id
            WHERE pos.dp_id = p_dept_id AND e.is_active = 'Y'
            ORDER BY e.lname, e.fname;
        
        v_index PLS_INTEGER := 1;
    BEGIN
        FOR emp_rec IN c_dept_emp LOOP
            p_emp_list(v_index).emp_id := emp_rec.emp_id;
            p_emp_list(v_index).full_name := emp_rec.full_name;
            p_emp_list(v_index).position_title := emp_rec.position_title;
            p_emp_list(v_index).salary := emp_rec.salary;
            p_emp_list(v_index).tenure := get_employee_tenure(emp_rec.emp_id);
            v_index := v_index + 1;
        END LOOP;
    END;
    
    -- Public function implementation
    FUNCTION calculate_annual_leave_balance(
        p_emp_id IN NUMBER,
        p_year IN NUMBER DEFAULT EXTRACT(YEAR FROM SYSDATE)
    ) RETURN NUMBER AS
        v_total_taken NUMBER := 0;
        v_annual_entitlement NUMBER := 25; -- Base annual leave days
        v_tenure NUMBER;
    BEGIN
        -- Calculate total leave taken in the year
        SELECT NVL(SUM(end_date - start_date + 1), 0)
        INTO v_total_taken
        FROM leave_request
        WHERE emp_id = p_emp_id 
        AND status = 'APPROVED'
        AND EXTRACT(YEAR FROM start_date) = p_year;
        
        -- Adjust entitlement based on tenure
        v_tenure := get_employee_tenure(p_emp_id);
        IF v_tenure >= 5 THEN
            v_annual_entitlement := v_annual_entitlement + 5;
        END IF;
        
        RETURN v_annual_entitlement - v_total_taken;
    END;
    
    -- Public procedure implementation
    PROCEDURE generate_performance_report(
        p_dept_id IN NUMBER,
        p_year IN NUMBER DEFAULT EXTRACT(YEAR FROM SYSDATE)
    ) AS
        CURSOR c_perf_data IS
            SELECT e.emp_id, e.fname || ' ' || e.lname as emp_name,
                   AVG(pr.overall_score) as avg_score,
                   COUNT(pr.perf_id) as review_count
            FROM employees e
            JOIN position pos ON e.position_id = pos.position_id
            LEFT JOIN performance_review pr ON e.emp_id = pr.emp_id
                AND EXTRACT(YEAR FROM pr.review_date) = p_year
            WHERE pos.dp_id = p_dept_id AND e.is_active = 'Y'
            GROUP BY e.emp_id, e.fname, e.lname
            ORDER BY avg_score DESC NULLS LAST;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('=== PERFORMANCE REPORT FOR DEPARTMENT ' || p_dept_id || ' - YEAR ' || p_year || ' ===');
        DBMS_OUTPUT.PUT_LINE('Generated on: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));
        DBMS_OUTPUT.PUT_LINE('');
        
        FOR perf_rec IN c_perf_data LOOP
            DBMS_OUTPUT.PUT_LINE('Employee: ' || perf_rec.emp_name);
            DBMS_OUTPUT.PUT_LINE('Average Score: ' || NVL(TO_CHAR(perf_rec.avg_score, '999.9'), 'No Reviews Yet'));
            DBMS_OUTPUT.PUT_LINE('Number of Reviews: ' || perf_rec.review_count);
            DBMS_OUTPUT.PUT_LINE('---');
        END LOOP;
        
        v_report_generated_date := SYSDATE;
    END;
    
    -- Public function implementation
    FUNCTION get_top_performers(
        p_dept_id IN NUMBER DEFAULT NULL,
        p_limit IN NUMBER DEFAULT 5
    ) RETURN emp_table_type AS
        v_emp_list emp_table_type;
        v_sql VARCHAR2(4000);
        v_index PLS_INTEGER := 1;
        
        TYPE ref_cursor IS REF CURSOR;
        c_top_perf ref_cursor;
        
        v_emp_id employees.emp_id%TYPE;
        v_full_name VARCHAR2(101);
        v_position_title position.position_title%TYPE;
        v_salary position.salary%TYPE;
        v_avg_score NUMBER;
    BEGIN
        v_sql := 'SELECT e.emp_id, e.fname || '' '' || e.lname, pos.position_title, pos.salary, AVG(pr.overall_score)
                  FROM employees e
                  JOIN position pos ON e.position_id = pos.position_id
                  JOIN performance_review pr ON e.emp_id = pr.emp_id
                  WHERE e.is_active = ''Y''';
        
        IF p_dept_id IS NOT NULL THEN
            v_sql := v_sql || ' AND pos.dp_id = ' || p_dept_id;
        END IF;
        
        v_sql := v_sql || ' GROUP BY e.emp_id, e.fname, e.lname, pos.position_title, pos.salary
                           ORDER BY AVG(pr.overall_score) DESC';
        
        OPEN c_top_perf FOR v_sql;
        
        LOOP
            FETCH c_top_perf INTO v_emp_id, v_full_name, v_position_title, v_salary, v_avg_score;
            EXIT WHEN c_top_perf%NOTFOUND OR v_index > p_limit;
            
            v_emp_list(v_index).emp_id := v_emp_id;
            v_emp_list(v_index).full_name := v_full_name;
            v_emp_list(v_index).position_title := v_position_title;
            v_emp_list(v_index).salary := v_salary;
            v_emp_list(v_index).tenure := get_employee_tenure(v_emp_id);
            
            v_index := v_index + 1;
        END LOOP;
        
        CLOSE c_top_perf;
        RETURN v_emp_list;
    END;
    
END hr_management_pkg;
/
