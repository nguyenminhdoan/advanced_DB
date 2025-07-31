# HR Management System - Database Project

## COMP214 - Advanced Database Concepts Assignment

A comprehensive HR Management System built with Node.js, Express.js, EJS templates, and Oracle Database, featuring extensive PL/SQL integration including stored procedures, functions, triggers, packages, and more.

## 📋 Project Overview

This project demonstrates advanced database concepts by implementing a complete HR management system with:

- **Frontend**: Node.js with Express.js and EJS templating
- **Database**: Oracle Database with comprehensive PL/SQL programming
- **Features**: Employee management, department operations, leave requests, performance reviews, and audit logging

## 🏗️ Database Architecture

### Tables (6 Tables)
1. **DEPARTMENT** - Department information with managers
2. **POSITION** - Job positions with salary information
3. **EMPLOYEES** - Employee master data with constraints
4. **LEAVE_REQUEST** - Employee leave request management
5. **PERFORMANCE_REVIEW** - Performance evaluation records
6. **AUDIT_LOG** - System audit trail

### Sequences (5 Sequences)
- `emp_seq` - Employee ID auto-generation
- `dept_seq` - Department ID auto-generation
- `pos_seq` - Position ID auto-generation
- `leave_seq` - Leave request ID auto-generation
- `perf_seq` - Performance review ID auto-generation

### Indexes (5 Indexes)
- `idx_emp_email` - Employee email searches
- `idx_emp_name` - Employee name searches
- `idx_leave_status` - Leave request status filtering
- `idx_perf_emp_date` - Performance review queries
- `idx_emp_active_pos` - Active employee position queries

### Triggers (2 Triggers)
1. **trg_calculate_overall_score** - Auto-calculates performance scores
2. **trg_emp_audit** - Audits all employee data changes

### Stored Procedures (2 Procedures)
1. **add_employee** - Adds new employees with validation and exception handling
2. **process_pending_leaves** - Processes leave requests using cursors

### Functions (2 Functions)
1. **get_employee_tenure** - Calculates employee tenure in years
2. **get_dept_avg_salary** - Calculates department average salary

### Package (1 Package)
**hr_management_pkg** - Comprehensive package containing:
- Employee management procedures
- Leave balance calculations
- Performance reporting functions
- Department employee listings

## 🚀 Getting Started

### Prerequisites
- Node.js (v14 or higher)
- Docker and Docker Compose
- Git

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd Database
```

2. **Install dependencies**
```bash
npm install
```

3. **Start Oracle Database**
```bash
docker-compose up -d
```

4. **Wait for database initialization** (5-10 minutes for first run)

5. **Set up the database schema**
```bash
# Connect to Oracle Database and run:
# 1. create_table.sql
# 2. PL_SQL.sql  
# 3. create_sample_data.sql
```

6. **Start the application**
```bash
npm start
# or for development
npm run dev
```

7. **Access the application**
Open http://localhost:3000 in your browser

## 🔧 Configuration

### Environment Variables
Create a `.env` file with the following variables:
```env
# Database Configuration
DB_HOST=localhost
DB_PORT=1521
DB_SERVICE=XE
DB_USERNAME=system
ORACLE_PASSWORD=OraclePass123

# Application Configuration
PORT=3000
NODE_ENV=development
```

### Database Connection
The application uses connection pooling for optimal performance:
- Pool size: 2-10 connections
- Auto-commit: Enabled
- Connection timeout: 300 seconds

## 📊 Features

### 1. Dashboard
- Real-time statistics
- Quick action buttons
- System overview

### 2. Employee Management
- Add new employees using PL/SQL procedures
- View employee details with calculated tenure
- List all employees with search and filtering
- Employee detail pages with leave balance calculations

### 3. Department Management
- Department overview with employee counts
- Average salary calculations using PL/SQL functions
- Department employee listings

### 4. Leave Request Management
- View all leave requests
- Process pending leaves using PL/SQL procedures with cursors
- Automatic approval for requests under threshold
- Leave statistics and analysis

### 5. Performance Reviews
- Performance review listings with auto-calculated scores
- Top performers page with dynamic filtering
- Performance statistics and insights
- Podium display for top 3 performers

### 6. Audit Trail
- Complete audit log of all employee changes
- Automatic logging via database triggers
- Operation analysis and statistics
- Daily activity summaries

## 🗄️ Database Integration

### PL/SQL Procedures Called
```javascript
// Add employee with validation
await db.executeProcedure('add_employee(:p_position_id, :p_fname, :p_lname, :p_email, :p_phone, :p_supervisor_id, :p_emp_id)', binds);

// Process leave requests
await db.executeProcedure('process_pending_leaves(:p_approver_id, :p_days_threshold)', binds);
```

### PL/SQL Functions Called
```javascript
// Calculate employee tenure
const tenure = await db.executeFunction('get_employee_tenure(:empId)', { empId });

// Get department average salary
const avgSalary = await db.executeFunction('get_dept_avg_salary(:deptId)', { deptId });

// Calculate leave balance using package
const leaveBalance = await db.executeFunction('hr_management_pkg.calculate_annual_leave_balance(:empId)', { empId });
```

### Automatic Triggers
- Performance scores are automatically calculated on insert/update
- All employee changes are automatically logged for audit purposes

## 🛠️ Technical Stack

### Backend
- **Node.js** - JavaScript runtime
- **Express.js** - Web application framework
- **oracledb** - Oracle Database driver
- **EJS** - Templating engine
- **body-parser** - Request parsing middleware

### Frontend
- **Bootstrap 5** - CSS framework
- **Font Awesome** - Icons
- **Custom CSS** - Enhanced styling and animations
- **Vanilla JavaScript** - Client-side functionality

### Database
- **Oracle Database 21c Express Edition** - Database engine
- **PL/SQL** - Stored procedures, functions, triggers, packages
- **Connection pooling** - Optimized database connections

## 📁 Project Structure
```
Database/
├── app.js                 # Main Express application
├── package.json           # Node.js dependencies
├── docker-compose.yml     # Oracle Database setup
├── .env                   # Environment variables
├── config/
│   └── database.js        # Database connection module
├── views/
│   ├── layout.ejs         # Main layout template
│   ├── index.ejs          # Dashboard page
│   ├── employees/         # Employee templates
│   ├── departments/       # Department templates
│   ├── leaves/            # Leave request templates
│   ├── performance/       # Performance review templates
│   └── reports/           # Report templates
├── public/
│   ├── styles.css         # Custom CSS
│   └── script.js          # Client-side JavaScript
├── create_table.sql       # Database schema
├── PL_SQL.sql            # PL/SQL objects
└── create_sample_data.sql # Sample data
```

## 🧪 Testing

### Database Testing
Run the test scripts included in the SQL files:
```sql
-- Test sequences
SELECT emp_seq.CURRVAL FROM dual;

-- Test functions
SELECT get_employee_tenure(1001) FROM dual;
SELECT get_dept_avg_salary(101) FROM dual;

-- Test procedures
EXEC add_employee(201, 'John', 'Doe', 'john.doe@company.com', '416-555-1234', NULL, :emp_id);
EXEC process_pending_leaves(1001, 5);
```

### Application Testing
1. Start the application
2. Test all main features:
   - Add new employee
   - View employee details
   - Process leave requests
   - View performance reviews
   - Check audit logs

## 📈 Performance Considerations

- **Connection Pooling**: Optimized database connections
- **Indexes**: Strategic indexing for common queries
- **Lazy Loading**: Data loaded on demand
- **Caching**: Client-side caching of static assets
- **Compression**: Gzip compression for responses

## 🔒 Security Features

- **Input Validation**: Server-side validation for all inputs
- **SQL Injection Prevention**: Parameterized queries
- **XSS Protection**: Template escaping
- **Audit Logging**: Complete audit trail
- **Connection Security**: Secure database connections

## 🚀 Future Enhancements

- User authentication and authorization
- Role-based access control
- RESTful API endpoints
- Real-time notifications
- Advanced reporting and analytics
- Mobile responsive design improvements
- Data export functionality (PDF, Excel)

## 📝 Assignment Requirements Fulfilled

### ✅ Database Objects Created
- [x] 6 Tables with constraints
- [x] 5 Sequences with usage
- [x] 5 Indexes for search optimization
- [x] 2 Triggers for automation
- [x] 2 Stored procedures with cursors and exceptions
- [x] 2 Functions with exception handling
- [x] 1 Package with procedures and functions

### ✅ Frontend Implementation
- [x] Functional web interface
- [x] Professional styling
- [x] Integration with all PL/SQL objects
- [x] Real-time data display
- [x] User-friendly navigation

### ✅ Data Requirements
- [x] 10+ records in main tables
- [x] 5+ records in lookup tables
- [x] Meaningful sample data
- [x] Proper foreign key relationships

## 👥 Group Members
[Add group member names here]

## 📧 Contact
For questions or issues, please contact the development team.

---

**Note**: This project is for educational purposes as part of the COMP214 Advanced Database Concepts course.