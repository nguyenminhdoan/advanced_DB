const oracledb = require('oracledb');

// Oracle Database configuration
const dbConfig = {
    user: process.env.DB_USERNAME || 'SYSTEM',
    password: process.env.ORACLE_PASSWORD || 'OraclePass123',
    connectString: `${process.env.DB_HOST || 'localhost'}:${process.env.DB_PORT || '1521'}/${process.env.DB_SERVICE || 'XE'}`,
    poolMin: 2,
    poolMax: 10,
    poolIncrement: 1,
    poolTimeout: 300
};

// Initialize connection pool
async function initializePool() {
    try {
        await oracledb.createPool(dbConfig);
        console.log('Oracle connection pool created successfully');
        console.log(`Connected to Oracle Database: ${dbConfig.connectString}`);
    } catch (error) {
        console.error('Error creating Oracle connection pool:', error);
        throw error;
    }
}

// Get connection from pool
async function getConnection() {
    try {
        return await oracledb.getConnection();
    } catch (error) {
        console.error('Error getting connection from pool:', error);
        throw error;
    }
}

// Execute query with automatic connection management
async function executeQuery(sql, binds = [], options = {}) {
    let connection;
    try {
        connection = await getConnection();
        const result = await connection.execute(sql, binds, {
            outFormat: oracledb.OUT_FORMAT_OBJECT,
            autoCommit: true,
            ...options
        });
        return result;
    } catch (error) {
        console.error('Database query error:', error);
        throw error;
    } finally {
        if (connection) {
            try {
                await connection.close();
            } catch (error) {
                console.error('Error closing connection:', error);
            }
        }
    }
}

// Execute stored procedure
async function executeProcedure(procedureName, binds = {}) {
    let connection;
    try {
        connection = await getConnection();
        const result = await connection.execute(
            `BEGIN ${procedureName}; END;`,
            binds,
            {
                autoCommit: true,
                outFormat: oracledb.OUT_FORMAT_OBJECT
            }
        );
        return result;
    } catch (error) {
        console.error('Stored procedure execution error:', error);
        throw error;
    } finally {
        if (connection) {
            try {
                await connection.close();
            } catch (error) {
                console.error('Error closing connection:', error);
            }
        }
    }
}

// Execute function
async function executeFunction(functionCall, binds = {}) {
    let connection;
    try {
        connection = await getConnection();
        const result = await connection.execute(
            `SELECT ${functionCall} as result FROM dual`,
            binds,
            {
                autoCommit: true,
                outFormat: oracledb.OUT_FORMAT_OBJECT
            }
        );
        return result.rows[0]?.RESULT;
    } catch (error) {
        console.error('Function execution error:', error);
        throw error;
    } finally {
        if (connection) {
            try {
                await connection.close();
            } catch (error) {
                console.error('Error closing connection:', error);
            }
        }
    }
}

// Close connection pool
async function closePool() {
    try {
        await oracledb.getPool().close(10);
        console.log('Oracle connection pool closed');
    } catch (error) {
        console.error('Error closing Oracle connection pool:', error);
    }
}

// Graceful shutdown
process.on('SIGINT', async () => {
    console.log('Received SIGINT. Graceful shutdown...');
    await closePool();
    process.exit(0);
});

process.on('SIGTERM', async () => {
    console.log('Received SIGTERM. Graceful shutdown...');
    await closePool();
    process.exit(0);
});

module.exports = {
    initializePool,
    getConnection,
    executeQuery,
    executeProcedure,
    executeFunction,
    closePool
};