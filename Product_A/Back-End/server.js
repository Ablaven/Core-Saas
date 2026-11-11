const express = require('express');
const cors = require('cors');
require('dotenv').config();

const routes = require('./routes/orderRoutes');

const app = express();
const PORT = process.env.PORT || 5000;

// Middlewares
app.use(cors({
    origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000', 'http://localhost:5173'],
    credentials: true
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Request logging
app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
    next();
});

// Mount Routes
app.use('/api', routes);

// Root Endpoint (Health Check)
app.get('/', async (req, res) => {
    try {
        const db = require('./config/db');
        const result = await db.query('SELECT NOW() as time, version() as db_version');
        
        res.json({
            message: '✅ Product A Marketing Platform API is running!',
            timestamp: result.rows[0].time,
            database: 'Connected',
            endpoints: {
                workspaces: 'GET /api/workspaces',
                brands: 'GET /api/brands?workspace_id={uuid}',
                createBrand: 'POST /api/brands',
                campaigns: 'GET /api/campaigns?workspace_id={uuid}',
                createCampaign: 'POST /api/campaigns',
                analytics: 'GET /api/analytics/campaigns?workspace_id={uuid}'
            }
        });
    } catch (error) {
        res.status(500).json({
            message: '❌ API is running but database connection failed',
            error: error.message
        });
    }
});

// 404 Handler
app.use((req, res) => {
    res.status(404).json({
        status: 'error',
        message: 'Route not found',
        path: req.path
    });
});

// Error Handler
app.use((err, req, res, next) => {
    console.error('Error:', err);
    res.status(err.status || 500).json({
        status: 'error',
        message: err.message || 'Internal server error'
    });
});

// Start Server
app.listen(PORT, () => {
    console.log(`
╔════════════════════════════════════════════════════════════════╗
║  🚀 Product A - Marketing Platform API                        ║
║  📍 Server: http://localhost:${PORT}                              ║
║  🗄️  Database: ${process.env.DB_NAME || 'saas_platform'}                              ║
║  🌍 Environment: ${process.env.NODE_ENV || 'development'}                           ║
╚════════════════════════════════════════════════════════════════╝
    `);
    console.log('📋 Available endpoints:');
    console.log('   GET  /api/workspaces');
    console.log('   GET  /api/brands?workspace_id={uuid}');
    console.log('   POST /api/brands');
    console.log('   GET  /api/campaigns?workspace_id={uuid}');
    console.log('   POST /api/campaigns');
    console.log('   GET  /api/analytics/campaigns?workspace_id={uuid}');
    console.log('');
});