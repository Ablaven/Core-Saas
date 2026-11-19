/**
 * db.js
 * 
 * Database connection configuration.
 * Responsibilities:
 * - Create PostgreSQL connection pool
 * - Configure connection settings (pool size, timeouts)
 * - Handle connection errors
 * - Export query function and pool instance
 */

const { Pool } = require('pg');

const pool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT) || 5432,
    database: process.env.DB_NAME || 'saas_platform',
    user: process.env.DB_USER || 'saas_admin',
    password: process.env.DB_PASSWORD,
    max: 20,                        // Maximum pool size
    idleTimeoutMillis: 30000,       // Close idle clients after 30 seconds
    connectionTimeoutMillis: 2000,  // Connection timeout
});

// Connection event handlers
pool.on('connect', () => {
    console.log('✅ Database connected successfully');
});

pool.on('error', (err) => {
    console.error('❌ Unexpected database error:', err);
    process.exit(-1);
});

// Test connection on startup
pool.query('SELECT NOW()', (err, res) => {
    if (err) {
        console.error('❌ Database connection test failed:', err);
    } else {
        console.log('✅ Database connection test successful:', res.rows[0].now);
    }
});

module.exports = {
    query: (text, params) => pool.query(text, params),
    pool
};
