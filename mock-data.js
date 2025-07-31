// Mock data for testing frontend without database connection

const mockEmployees = [
    {
        EMP_ID: 1001,
        FNAME: 'Sarah',
        LNAME: 'Johnson',
        EMAIL: 'sarah.johnson@company.com',
        PHONE: '416-555-0101',
        POSITION_TITLE: 'HR Manager',
        DP_NAME: 'Human Resources',
        SUPERVISOR_NAME: null,
        HIRE_DATE: new Date('2020-01-15'),
        IS_ACTIVE: 'Y'
    },
    {
        EMP_ID: 1002,
        FNAME: 'Michael',
        LNAME: 'Chen',
        EMAIL: 'michael.chen@company.com',
        PHONE: '416-555-0102',
        POSITION_TITLE: 'IT Manager',
        DP_NAME: 'Information Technology',
        SUPERVISOR_NAME: null,
        HIRE_DATE: new Date('2019-03-20'),
        IS_ACTIVE: 'Y'
    },
    {
        EMP_ID: 1006,
        FNAME: 'Robert',
        LNAME: 'Miller',
        EMAIL: 'robert.miller@company.com',
        PHONE: '416-555-0106',
        POSITION_TITLE: 'HR Specialist',
        DP_NAME: 'Human Resources',
        SUPERVISOR_NAME: 'Sarah Johnson',
        HIRE_DATE: new Date('2021-05-12'),
        IS_ACTIVE: 'Y'
    },
    {
        EMP_ID: 1007,
        FNAME: 'Emily',
        LNAME: 'Wilson',
        EMAIL: 'emily.wilson@company.com',
        PHONE: '416-555-0107',
        POSITION_TITLE: 'Software Developer',
        DP_NAME: 'Information Technology',
        SUPERVISOR_NAME: 'Michael Chen',
        HIRE_DATE: new Date('2020-08-18'),
        IS_ACTIVE: 'Y'
    }
];

const mockDepartments = [
    {
        DP_ID: 101,
        DP_NAME: 'Human Resources',
        MANAGER_NAME: 'Sarah Johnson',
        EMPLOYEE_COUNT: 2,
        CREATED_DATE: new Date('2020-01-01'),
        avgSalary: 75000
    },
    {
        DP_ID: 102,
        DP_NAME: 'Information Technology',
        MANAGER_NAME: 'Michael Chen',
        EMPLOYEE_COUNT: 3,
        CREATED_DATE: new Date('2019-01-01'),
        avgSalary: 85000
    },
    {
        DP_ID: 103,
        DP_NAME: 'Finance',
        MANAGER_NAME: 'Jennifer Williams',
        EMPLOYEE_COUNT: 2,
        CREATED_DATE: new Date('2018-01-01'),
        avgSalary: 75000
    }
];

const mockLeaves = [
    {
        LEAVE_ID: 301,
        EMPLOYEE_NAME: 'Robert Miller',
        START_DATE: new Date('2024-08-15'),
        END_DATE: new Date('2024-08-19'),
        DAYS: 5,
        REASON: 'Vacation',
        STATUS: 'APPROVED',
        APPROVER_NAME: 'Sarah Johnson',
        REQUEST_DATE: new Date('2024-07-20')
    },
    {
        LEAVE_ID: 302,
        EMPLOYEE_NAME: 'Emily Wilson',
        START_DATE: new Date('2024-09-10'),
        END_DATE: new Date('2024-09-12'),
        DAYS: 3,
        REASON: 'Medical appointment',
        STATUS: 'PENDING',
        APPROVER_NAME: null,
        REQUEST_DATE: new Date('2024-08-15')
    }
];

const mockPerformanceReviews = [
    {
        PERF_ID: 401,
        EMPLOYEE_NAME: 'Robert Miller',
        REVIEW_DATE: new Date('2024-06-15'),
        TEAMWORK: 8,
        CREATIVITY: 7,
        KNOWLEDGE: 9,
        OVERALL_SCORE: 8.0,
        REVIEWER_NAME: 'Sarah Johnson',
        COMMENTS: 'Excellent team player with strong technical skills'
    },
    {
        PERF_ID: 402,
        EMPLOYEE_NAME: 'Emily Wilson',
        REVIEW_DATE: new Date('2024-05-20'),
        TEAMWORK: 9,
        CREATIVITY: 8,
        KNOWLEDGE: 8,
        OVERALL_SCORE: 8.3,
        REVIEWER_NAME: 'Michael Chen',
        COMMENTS: 'Outstanding problem-solving abilities and collaboration'
    }
];

const mockAuditLogs = [
    {
        LOG_ID: 1,
        TABLE_NAME: 'EMPLOYEES',
        OPERATION: 'INSERT',
        EMP_ID: 1007,
        OLD_VALUES: null,
        NEW_VALUES: 'ID:1007,Name:Emily Wilson,Email:emily.wilson@company.com',
        CHANGED_BY: 'SYSTEM',
        CHANGE_DATE: new Date('2024-07-31T10:30:00')
    },
    {
        LOG_ID: 2,
        TABLE_NAME: 'EMPLOYEES',
        OPERATION: 'UPDATE',
        EMP_ID: 1006,
        OLD_VALUES: 'ID:1006,Name:Robert Miller,Email:robert.miller@company.com',
        NEW_VALUES: 'ID:1006,Name:Robert Miller,Email:robert.miller@company.com',
        CHANGED_BY: 'SYSTEM',
        CHANGE_DATE: new Date('2024-07-31T09:15:00')
    }
];

module.exports = {
    mockEmployees,
    mockDepartments,
    mockLeaves,
    mockPerformanceReviews,
    mockAuditLogs
};