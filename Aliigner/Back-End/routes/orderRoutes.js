const express = require('express');
const router = express.Router();

const controller = require('../controllers/orderController');

// Workspace routes
router.get('/workspaces', controller.getWorkspaces);

// Brand routes
router.get('/brands', controller.getBrands);
router.post('/brands', controller.createBrand);

// Campaign routes
router.get('/campaigns', controller.getCampaigns);
router.post('/campaigns', controller.createCampaign);

// Analytics routes
router.get('/analytics/campaigns', controller.getCampaignPerformance);

module.exports = router;