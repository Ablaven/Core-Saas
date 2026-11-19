/**
 * server.js
 * 
 * Entry point for the Node.js backend application.
 * Responsibilities:
 * - Load environment variables
 * - Initialize the Express app
 * - Start the HTTP server
 * - Handle graceful shutdown
 */

require('dotenv').config();
const app = require('./app');
const { pool } = require('./config/db');

const PORT = process.env.PORT || 5000;

// Start server
const server = app.listen(PORT, () => {
    console.log(`
╔════════════════════════════════════════════════════════════════╗
║  🚀 Core Backend API Server                                   ║
║  📍 Server: http://localhost:${PORT}                              ║
║  🗄️  Database: ${process.env.DB_NAME}                              ║
║  🌍 Environment: ${process.env.NODE_ENV}                           ║
╚════════════════════════════════════════════════════════════════╝
    `);
});

// Graceful shutdown
process.on('SIGTERM', () => {
    console.log('SIGTERM signal received: closing HTTP server');
    server.close(() => {
        console.log('HTTP server closed');
        pool.end(() => {
            console.log('Database pool closed');
            process.exit(0);
        });
    });
});

process.on('SIGINT', () => {
    console.log('SIGINT signal received: closing HTTP server');
    server.close(() => {
        console.log('HTTP server closed');
        pool.end(() => {
            console.log('Database pool closed');
            process.exit(0);
        });
    });
});
