const express = require('express');
const bodyParser = require('body-parser');
const methodOverride = require('method-override');
const session = require('express-session');
const path = require('path');

// Import mock data
const { 
    mockEmployees, 
    mockDepartments, 
    mockLeaves, 
    mockPerformanceReviews, 
    mockAuditLogs 
} = require('./mock-data');

const app = express();
const PORT = process.env.PORT || 3000;

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
// ROUTES WITH MOCK DATA
// ========================================

// Home page
app.get('/', async (req, res) => {
    const stats = {
        totalEmployees: mockEmployees.filter(e => e.IS_ACTIVE === 'Y').length,
        totalDepartments: mockDepartments.length,
        pendingLeaves: mockLeaves.filter(l => l.STATUS === 'PENDING').length
    };
    res.render('index', { title: 'HR Management System', stats });
});

// List all employees
app.get('/employees', async (req, res) => {
    res.render('employees/list', { title: 'Employees', employees: mockEmployees });
});

// Show add employee form
app.get('/employees/new', async (req, res) => {
    const positions = [
        { POSITION_ID: 201, POSITION_TITLE: 'HR Manager', DP_NAME: 'Human Resources' },
        { POSITION_ID: 202, POSITION_TITLE: 'HR Specialist', DP_NAME: 'Human Resources' },
        { POSITION_ID: 203, POSITION_TITLE: 'IT Manager', DP_NAME: 'Information Technology' },
        { POSITION_ID: 204, POSITION_TITLE: 'Software Developer', DP_NAME: 'Information Technology' }
    ];
    
    const supervisors = mockEmployees.map(emp => ({
        EMP_ID: emp.EMP_ID,
        FULL_NAME: `${emp.FNAME} ${emp.LNAME}`
    }));

    res.render('employees/new', { 
        title: 'Add Employee', 
        positions: positions,
        supervisors: supervisors
    });
});

// Add new employee (mock)
app.post('/employees', async (req, res) => {
    const { position_id, fname, lname, email, phone, supervisor_id } = req.body;
    
    // Simulate adding employee
    const newEmpId = Math.max(...mockEmployees.map(e => e.EMP_ID)) + 1;
    const newEmployee = {
        EMP_ID: newEmpId,
        FNAME: fname,
        LNAME: lname,
        EMAIL: email,
        PHONE: phone,
        POSITION_TITLE: 'New Position',
        DP_NAME: 'Information Technology',
        SUPERVISOR_NAME: supervisor_id ? 'Michael Chen' : null,
        HIRE_DATE: new Date(),
        IS_ACTIVE: 'Y'
    };
    
    mockEmployees.push(newEmployee);
    
    req.session.message = { type: 'success', text: `Employee added successfully with ID: ${newEmpId}` };
    res.redirect('/employees');
});

// Show employee details (mock calculations)
app.get('/employees/:id', async (req, res) => {
    const empId = parseInt(req.params.id);
    const employee = mockEmployees.find(e => e.EMP_ID === empId);
    
    if (!employee) {
        return res.status(404).render('404', { title: 'Employee Not Found' });
    }

    // Mock employee details with additional fields
    const employeeDetails = {
        ...employee,
        POSITION_TITLE: employee.POSITION_TITLE,
        SALARY: 75000,
        SUPERVISOR_NAME: employee.SUPERVISOR_NAME
    };

    // Mock tenure calculation (years since hire date)
    const tenure = ((new Date() - new Date(employee.HIRE_DATE)) / (365.25 * 24 * 60 * 60 * 1000)).toFixed(1);
    
    // Mock leave balance
    const leaveBalance = 15;

    res.render('employees/detail', { 
        title: 'Employee Details', 
        employee: employeeDetails,
        tenure: tenure,
        leaveBalance: leaveBalance
    });
});

// List departments
app.get('/departments', async (req, res) => {
    res.render('departments/list', { title: 'Departments', departments: mockDepartments });
});

// Show department employees
app.get('/departments/:id/employees', async (req, res) => {
    const deptId = parseInt(req.params.id);
    const department = mockDepartments.find(d => d.DP_ID === deptId);
    
    if (!department) {
        return res.status(404).render('404', { title: 'Department Not Found' });
    }

    const deptEmployees = mockEmployees
        .filter(e => e.DP_NAME === department.DP_NAME)
        .map(e => ({
            ...e,
            FULL_NAME: `${e.FNAME} ${e.LNAME}`,
            SALARY: 75000
        }));

    res.render('departments/employees', { 
        title: 'Department Employees', 
        department: department,
        employees: deptEmployees
    });
});

// List leave requests
app.get('/leaves', async (req, res) => {
    res.render('leaves/list', { title: 'Leave Requests', leaves: mockLeaves });
});

// Process pending leaves (mock)
app.post('/leaves/process', async (req, res) => {
    const { approver_id, days_threshold } = req.body;
    
    // Mock processing - approve short leaves
    let processed = 0;
    mockLeaves.forEach(leave => {
        if (leave.STATUS === 'PENDING' && leave.DAYS <= parseInt(days_threshold)) {
            leave.STATUS = 'APPROVED';
            leave.APPROVER_NAME = 'System Auto-Approval';
            processed++;
        }
    });
    
    req.session.message = { type: 'success', text: `Processed ${processed} leave requests successfully` };
    res.redirect('/leaves');
});

// List performance reviews
app.get('/performance', async (req, res) => {
    res.render('performance/list', { title: 'Performance Reviews', reviews: mockPerformanceReviews });
});

// Show top performers
app.get('/performance/top-performers', async (req, res) => {
    const { dept_id, limit } = req.query;
    
    // Mock top performers data
    const performers = mockPerformanceReviews
        .map(review => ({
            EMP_ID: mockEmployees.find(e => e.FNAME + ' ' + e.LNAME === review.EMPLOYEE_NAME)?.EMP_ID || 1001,
            FULL_NAME: review.EMPLOYEE_NAME,
            POSITION_TITLE: 'Software Developer',
            SALARY: 85000,
            TENURE: 2.5,
            AVG_SCORE: review.OVERALL_SCORE
        }))
        .sort((a, b) => b.AVG_SCORE - a.AVG_SCORE)
        .slice(0, parseInt(limit) || 10);
    
    const departments = mockDepartments.map(d => ({ DP_ID: d.DP_ID, DP_NAME: d.DP_NAME }));

    res.render('performance/top-performers', { 
        title: 'Top Performers', 
        performers: performers,
        departments: departments,
        selectedDept: dept_id || '',
        selectedLimit: limit || '10'
    });
});

// Show audit log
app.get('/reports/audit', async (req, res) => {
    res.render('reports/audit', { title: 'Audit Log', logs: mockAuditLogs });
});

// 404 handler
app.use((req, res) => {
    res.status(404).render('404', { title: 'Page Not Found' });
});

// Error handler
app.use((error, req, res, next) => {
    console.error('Application error:', error);
    res.status(500).render('500', { title: 'Server Error', error });
});

// Start server
app.listen(PORT, () => {
    console.log(`🚀 HR Management System (MOCK MODE) running on http://localhost:${PORT}`);
    console.log('📝 Using mock data - perfect for frontend testing!');
    console.log('🔄 Switch to app.js when Oracle database is ready');
});

module.exports = app;