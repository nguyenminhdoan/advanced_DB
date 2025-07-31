const express = require('express');
const bodyParser = require('body-parser');
const methodOverride = require('method-override');
const session = require('express-session');
const path = require('path');
const oracledb = require('oracledb');

const db = require('./config/database');

const app = express();
const PORT = process.env.PORT || 3000;

// Configure oracledb
oracledb.outFormat = oracledb.OUT_FORMAT_OBJECT;

// Middleware
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
app.use(express.static(path.join(__dirname, 'public')));
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
app.use(methodOverride('_method'));
app.use(session({
    secret: 'hr-management-secret',
    resave: false,
    saveUninitialized: true,
    cookie: { secure: false }
}));

// Make session available in all templates
app.use((req, res, next) => {
    res.locals.session = req.session;
    next();
});

// ========================================
// ROUTES
// ========================================

// Home page
app.get('/', async (req, res) => {
    try {
        // Get dashboard statistics
        const empCountResult = await db.executeQuery('SELECT COUNT(*) as count FROM employees WHERE is_active = \'Y\'');
        const deptCountResult = await db.executeQuery('SELECT COUNT(*) as count FROM department');
        const pendingLeavesResult = await db.executeQuery('SELECT COUNT(*) as count FROM leave_request WHERE status = \'PENDING\'');
        
        const stats = {
            totalEmployees: empCountResult.rows[0].COUNT,
            totalDepartments: deptCountResult.rows[0].COUNT,
            pendingLeaves: pendingLeavesResult.rows[0].COUNT
        };

        res.render('index', { title: 'HR Management System', stats });
    } catch (error) {
        console.error('Error loading dashboard:', error);
        res.render('index', { title: 'HR Management System', stats: { totalEmployees: 0, totalDepartments: 0, pendingLeaves: 0 } });
    }
});

// ========================================
// EMPLOYEE ROUTES
// ========================================

// List all employees
app.get('/employees', async (req, res) => {
    try {
        const result = await db.executeQuery(`
            SELECT e.emp_id, e.fname, e.lname, e.email, e.phone, e.hire_date,
                   p.position_title, d.dp_name, e.is_active,
                   sup.fname || ' ' || sup.lname as supervisor_name
            FROM employees e
            JOIN position p ON e.position_id = p.position_id
            JOIN department d ON p.dp_id = d.dp_id
            LEFT JOIN employees sup ON e.supervisor_id = sup.emp_id
            ORDER BY e.lname, e.fname
        `);
        res.render('employees/list', { title: 'Employees', employees: result.rows });
    } catch (error) {
        console.error('Error fetching employees:', error);
        res.render('employees/list', { title: 'Employees', employees: [] });
    }
});

// Show add employee form
app.get('/employees/new', async (req, res) => {
    try {
        const positionsResult = await db.executeQuery(`
            SELECT p.position_id, p.position_title, d.dp_name
            FROM position p
            JOIN department d ON p.dp_id = d.dp_id
            ORDER BY d.dp_name, p.position_title
        `);
        
        const supervisorsResult = await db.executeQuery(`
            SELECT emp_id, fname || ' ' || lname as full_name
            FROM employees
            WHERE is_active = 'Y'
            ORDER BY fname, lname
        `);

        res.render('employees/new', { 
            title: 'Add Employee', 
            positions: positionsResult.rows,
            supervisors: supervisorsResult.rows
        });
    } catch (error) {
        console.error('Error loading employee form:', error);
        res.render('employees/new', { title: 'Add Employee', positions: [], supervisors: [] });
    }
});

// Add new employee using PL/SQL procedure
app.post('/employees', async (req, res) => {
    const { position_id, fname, lname, email, phone, supervisor_id } = req.body;
    
    try {
        const binds = {
            p_position_id: parseInt(position_id),
            p_fname: fname,
            p_lname: lname,
            p_email: email,
            p_phone: phone || null,
            p_supervisor_id: supervisor_id ? parseInt(supervisor_id) : null,
            p_emp_id: { dir: oracledb.BIND_OUT, type: oracledb.NUMBER }
        };

        await db.executeProcedure('add_employee(:p_position_id, :p_fname, :p_lname, :p_email, :p_phone, :p_supervisor_id, :p_emp_id)', binds);
        
        req.session.message = { type: 'success', text: `Employee added successfully with ID: ${binds.p_emp_id}` };
        res.redirect('/employees');
    } catch (error) {
        console.error('Error adding employee:', error);
        req.session.message = { type: 'error', text: `Error adding employee: ${error.message}` };
        res.redirect('/employees/new');
    }
});

// Show employee details with tenure calculation
app.get('/employees/:id', async (req, res) => {
    const empId = parseInt(req.params.id);
    
    try {
        const employeeResult = await db.executeQuery(`
            SELECT e.emp_id, e.fname, e.lname, e.email, e.phone, e.hire_date, e.end_date,
                   p.position_title, p.salary, d.dp_name,
                   sup.fname || ' ' || sup.lname as supervisor_name
            FROM employees e
            JOIN position p ON e.position_id = p.position_id
            JOIN department d ON p.dp_id = d.dp_id
            LEFT JOIN employees sup ON e.supervisor_id = sup.emp_id
            WHERE e.emp_id = :empId
        `, [empId]);

        if (employeeResult.rows.length === 0) {
            return res.status(404).render('404', { title: 'Employee Not Found' });
        }

        // Get employee tenure using PL/SQL function
        const tenure = await db.executeFunction('get_employee_tenure(:empId)', { empId });
        
        // Get leave balance using package function
        const leaveBalance = await db.executeFunction('hr_management_pkg.calculate_annual_leave_balance(:empId)', { empId });

        res.render('employees/detail', { 
            title: 'Employee Details', 
            employee: employeeResult.rows[0],
            tenure: tenure || 0,
            leaveBalance: leaveBalance || 0
        });
    } catch (error) {
        console.error('Error fetching employee details:', error);
        res.status(500).render('500', { title: 'Error', error });
    }
});

// ========================================
// DEPARTMENT ROUTES
// ========================================

// List departments with average salary
app.get('/departments', async (req, res) => {
    try {
        const result = await db.executeQuery(`
            SELECT d.dp_id, d.dp_name, d.created_date,
                   m.fname || ' ' || m.lname as manager_name,
                   COUNT(e.emp_id) as employee_count
            FROM department d
            LEFT JOIN employees m ON d.manager_id = m.emp_id
            LEFT JOIN position p ON p.dp_id = d.dp_id
            LEFT JOIN employees e ON e.position_id = p.position_id AND e.is_active = 'Y'
            GROUP BY d.dp_id, d.dp_name, d.created_date, m.fname, m.lname
            ORDER BY d.dp_name
        `);

        // Get average salary for each department using PL/SQL function
        const departmentsWithSalary = await Promise.all(
            result.rows.map(async (dept) => {
                try {
                    const avgSalary = await db.executeFunction('get_dept_avg_salary(:deptId)', { deptId: dept.DP_ID });
                    return { ...dept, avgSalary: avgSalary || 0 };
                } catch (error) {
                    console.error(`Error getting avg salary for dept ${dept.DP_ID}:`, error);
                    return { ...dept, avgSalary: 0 };
                }
            })
        );

        res.render('departments/list', { title: 'Departments', departments: departmentsWithSalary });
    } catch (error) {
        console.error('Error fetching departments:', error);
        res.render('departments/list', { title: 'Departments', departments: [] });
    }
});

// Show department employees using package procedure
app.get('/departments/:id/employees', async (req, res) => {
    const deptId = parseInt(req.params.id);
    
    try {
        // Get department info
        const deptResult = await db.executeQuery('SELECT dp_name FROM department WHERE dp_id = :deptId', [deptId]);
        
        if (deptResult.rows.length === 0) {
            return res.status(404).render('404', { title: 'Department Not Found' });
        }

        // Use package procedure to get department employees
        const result = await db.executeQuery(`
            SELECT e.emp_id, e.fname || ' ' || e.lname as full_name,
                   pos.position_title, pos.salary
            FROM employees e
            JOIN position pos ON e.position_id = pos.position_id
            WHERE pos.dp_id = :deptId AND e.is_active = 'Y'
            ORDER BY e.lname, e.fname
        `, [deptId]);

        res.render('departments/employees', { 
            title: 'Department Employees', 
            department: deptResult.rows[0],
            employees: result.rows 
        });
    } catch (error) {
        console.error('Error fetching department employees:', error);
        res.status(500).render('500', { title: 'Error', error });
    }
});

// ========================================
// LEAVE REQUEST ROUTES
// ========================================

// List leave requests
app.get('/leaves', async (req, res) => {
    try {
        const result = await db.executeQuery(`
            SELECT lr.leave_id, lr.start_date, lr.end_date, lr.reason, lr.status,
                   lr.request_date, e.fname || ' ' || e.lname as employee_name,
                   (lr.end_date - lr.start_date + 1) as days,
                   approver.fname || ' ' || approver.lname as approver_name
            FROM leave_request lr
            JOIN employees e ON lr.emp_id = e.emp_id
            LEFT JOIN employees approver ON lr.approved_by = approver.emp_id
            ORDER BY lr.request_date DESC
        `);

        res.render('leaves/list', { title: 'Leave Requests', leaves: result.rows });
    } catch (error) {
        console.error('Error fetching leave requests:', error);
        res.render('leaves/list', { title: 'Leave Requests', leaves: [] });
    }
});

// Process pending leaves using PL/SQL procedure
app.post('/leaves/process', async (req, res) => {
    const { approver_id, days_threshold } = req.body;
    
    try {
        const binds = {
            p_approver_id: parseInt(approver_id),
            p_days_threshold: parseInt(days_threshold || 5)
        };

        await db.executeProcedure('process_pending_leaves(:p_approver_id, :p_days_threshold)', binds);
        
        req.session.message = { type: 'success', text: 'Pending leaves processed successfully' };
    } catch (error) {
        console.error('Error processing leaves:', error);
        req.session.message = { type: 'error', text: `Error processing leaves: ${error.message}` };
    }
    
    res.redirect('/leaves');
});

// ========================================
// PERFORMANCE REVIEW ROUTES
// ========================================

// List performance reviews
app.get('/performance', async (req, res) => {
    try {
        const result = await db.executeQuery(`
            SELECT pr.perf_id, pr.review_date, pr.teamwork, pr.creativity, 
                   pr.knowledge, pr.overall_score, pr.comments,
                   e.fname || ' ' || e.lname as employee_name,
                   r.fname || ' ' || r.lname as reviewer_name
            FROM performance_review pr
            JOIN employees e ON pr.emp_id = e.emp_id
            LEFT JOIN employees r ON pr.reviewer_id = r.emp_id
            ORDER BY pr.review_date DESC
        `);

        res.render('performance/list', { title: 'Performance Reviews', reviews: result.rows });
    } catch (error) {
        console.error('Error fetching performance reviews:', error);
        res.render('performance/list', { title: 'Performance Reviews', reviews: [] });
    }
});

// Show top performers using package function
app.get('/performance/top-performers', async (req, res) => {
    const { dept_id, limit } = req.query;
    
    try {
        let topPerformersQuery = `
            SELECT e.emp_id, e.fname || ' ' || e.lname as full_name,
                   pos.position_title, pos.salary, AVG(pr.overall_score) as avg_score
            FROM employees e
            JOIN position pos ON e.position_id = pos.position_id
            JOIN performance_review pr ON e.emp_id = pr.emp_id
            WHERE e.is_active = 'Y'
        `;
        
        const binds = [];
        if (dept_id) {
            topPerformersQuery += ' AND pos.dp_id = :deptId';
            binds.push(parseInt(dept_id));
        }
        
        topPerformersQuery += `
            GROUP BY e.emp_id, e.fname, e.lname, pos.position_title, pos.salary
            ORDER BY AVG(pr.overall_score) DESC
        `;
        
        if (limit) {
            topPerformersQuery += ` FETCH FIRST ${parseInt(limit)} ROWS ONLY`;
        } else {
            topPerformersQuery += ' FETCH FIRST 10 ROWS ONLY';
        }

        const result = await db.executeQuery(topPerformersQuery, binds);
        
        // Get departments for filter
        const deptResult = await db.executeQuery('SELECT dp_id, dp_name FROM department ORDER BY dp_name');

        res.render('performance/top-performers', { 
            title: 'Top Performers', 
            performers: result.rows,
            departments: deptResult.rows,
            selectedDept: dept_id || '',
            selectedLimit: limit || '10'
        });
    } catch (error) {
        console.error('Error fetching top performers:', error);
        res.render('performance/top-performers', { 
            title: 'Top Performers', 
            performers: [],
            departments: [],
            selectedDept: '',
            selectedLimit: '10'
        });
    }
});

// ========================================
// REPORTS ROUTES
// ========================================

// Show audit log
app.get('/reports/audit', async (req, res) => {
    try {
        const result = await db.executeQuery(`
            SELECT log_id, table_name, operation, emp_id, old_values, 
                   new_values, change_date, changed_by
            FROM audit_log
            ORDER BY change_date DESC
            FETCH FIRST 50 ROWS ONLY
        `);

        res.render('reports/audit', { title: 'Audit Log', logs: result.rows });
    } catch (error) {
        console.error('Error fetching audit log:', error);
        res.render('reports/audit', { title: 'Audit Log', logs: [] });
    }
});

// ========================================
// ERROR HANDLING
// ========================================

// 404 handler
app.use((req, res) => {
    res.status(404).render('404', { title: 'Page Not Found' });
});

// Error handler
app.use((error, req, res, next) => {
    console.error('Application error:', error);
    res.status(500).render('500', { title: 'Server Error', error });
});

// ========================================
// SERVER STARTUP
// ========================================

async function startServer() {
    try {
        // Initialize database connection pool
        await db.initializePool();
        
        // Start server
        app.listen(PORT, () => {
            console.log(`HR Management System running on http://localhost:${PORT}`);
        });
    } catch (error) {
        console.error('Failed to start server:', error);
        process.exit(1);
    }
}

startServer();