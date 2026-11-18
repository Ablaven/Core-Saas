const db = require('../config/db');

// Get all brands for a workspace
const getBrands = async (req, res) => {
    try {
        const { workspace_id } = req.query;
        
        if (!workspace_id) {
            return res.status(400).json({
                status: 'error',
                message: 'workspace_id is required'
            });
        }

        const result = await db.query(
            'SELECT * FROM product_a.brand_profiles WHERE workspace_id = $1 ORDER BY created_at DESC',
            [workspace_id]
        );

        res.status(200).json({
            status: 'success',
            count: result.rows.length,
            data: result.rows
        });
    } catch (error) {
        console.error('Error fetching brands:', error);
        res.status(500).json({
            status: 'error',
            message: 'Internal server error',
            error: error.message
        });
    }
};

// Create a new brand
const createBrand = async (req, res) => {
    try {
        const { workspace_id, brand_name, brand_description, logo_url, website_url, industry, target_audience } = req.body;
        
        if (!workspace_id || !brand_name) {
            return res.status(400).json({
                status: 'error',
                message: 'workspace_id and brand_name are required'
            });
        }

        const result = await db.query(
            `INSERT INTO product_a.brand_profiles 
            (workspace_id, brand_name, brand_description, logo_url, website_url, industry, target_audience) 
            VALUES ($1, $2, $3, $4, $5, $6, $7) 
            RETURNING *`,
            [workspace_id, brand_name, brand_description, logo_url, website_url, industry, target_audience]
        );

        res.status(201).json({
            status: 'success',
            message: 'Brand created successfully',
            data: result.rows[0]
        });
    } catch (error) {
        console.error('Error creating brand:', error);
        res.status(500).json({
            status: 'error',
            message: 'Internal server error',
            error: error.message
        });
    }
};

// Get all campaigns for a workspace
const getCampaigns = async (req, res) => {
    try {
        const { workspace_id } = req.query;
        
        if (!workspace_id) {
            return res.status(400).json({
                status: 'error',
                message: 'workspace_id is required'
            });
        }

        const result = await db.query(
            `SELECT c.*, b.brand_name 
             FROM product_a.campaigns c
             LEFT JOIN product_a.brand_profiles b ON c.brand_id = b.id
             WHERE c.workspace_id = $1 
             ORDER BY c.created_at DESC`,
            [workspace_id]
        );

        res.status(200).json({
            status: 'success',
            count: result.rows.length,
            data: result.rows
        });
    } catch (error) {
        console.error('Error fetching campaigns:', error);
        res.status(500).json({
            status: 'error',
            message: 'Internal server error',
            error: error.message
        });
    }
};

// Create a new campaign
const createCampaign = async (req, res) => {
    try {
        const { 
            workspace_id, 
            brand_id, 
            campaign_name, 
            campaign_description, 
            campaign_type,
            budget,
            start_date,
            end_date,
            status = 'draft'
        } = req.body;
        
        if (!workspace_id || !brand_id || !campaign_name) {
            return res.status(400).json({
                status: 'error',
                message: 'workspace_id, brand_id, and campaign_name are required'
            });
        }

        const result = await db.query(
            `INSERT INTO product_a.campaigns 
            (workspace_id, brand_id, campaign_name, campaign_description, campaign_type, budget, start_date, end_date, status) 
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) 
            RETURNING *`,
            [workspace_id, brand_id, campaign_name, campaign_description, campaign_type, budget, start_date, end_date, status]
        );

        res.status(201).json({
            status: 'success',
            message: 'Campaign created successfully',
            data: result.rows[0]
        });
    } catch (error) {
        console.error('Error creating campaign:', error);
        res.status(500).json({
            status: 'error',
            message: 'Internal server error',
            error: error.message
        });
    }
};

// Get campaign performance summary
const getCampaignPerformance = async (req, res) => {
    try {
        const { workspace_id } = req.query;
        
        if (!workspace_id) {
            return res.status(400).json({
                status: 'error',
                message: 'workspace_id is required'
            });
        }

        const result = await db.query(
            `SELECT * FROM product_a.campaign_performance_summary 
             WHERE workspace_id = $1 
             ORDER BY avg_roi DESC NULLS LAST`,
            [workspace_id]
        );

        res.status(200).json({
            status: 'success',
            count: result.rows.length,
            data: result.rows
        });
    } catch (error) {
        console.error('Error fetching campaign performance:', error);
        res.status(500).json({
            status: 'error',
            message: 'Internal server error',
            error: error.message
        });
    }
};

// Get all workspaces
const getWorkspaces = async (req, res) => {
    try {
        const result = await db.query(
            'SELECT * FROM core.workspaces ORDER BY created_at DESC'
        );

        res.status(200).json({
            status: 'success',
            count: result.rows.length,
            data: result.rows
        });
    } catch (error) {
        console.error('Error fetching workspaces:', error);
        res.status(500).json({
            status: 'error',
            message: 'Internal server error',
            error: error.message
        });
    }
};

module.exports = {
    getBrands,
    createBrand,
    getCampaigns,
    createCampaign,
    getCampaignPerformance,
    getWorkspaces
};