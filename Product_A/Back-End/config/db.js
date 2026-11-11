const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    database: process.env.DB_NAME || 'saas_platform',
    user: process.env.DB_USER || 'saas_admin',
    password: process.env.DB_PASSWORD,
    max: 20,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 2000,
});

pool.on('connect', () => {
    console.log('✅ Database connected successfully!');
});

pool.on('error', (err) => {
    console.error('❌ Unexpected database error:', err);
});

// Test connection and check for UUID extension
pool.query('SELECT NOW()', (err, res) => {
    if (err) {
        console.error('❌ Database connection test failed:', err);
    } else {
        console.log('✅ Database connection test successful');
    }
});

module.exports = {
    query: (text, params) => pool.query(text, params),
    pool,
};