/**
 * members.routes.js
 * 
 * Workspace member management routes.
 * Responsibilities:
 * - Define routes for member role updates
 * - Define routes for member status management
 * - Apply proper authorization checks
 * - Ensure only admins/managers can modify members
 */

const express = require('express');
const router = express.Router();
const membersController = require('../controllers/members.controller');
const authenticate = require('../middleware/auth');
const requireRole = require('../middleware/requireRole');
const verifyTenantAccess = require('../middleware/tenant');
// const validate = require('../middleware/validate');

// All routes require authentication and tenant access
router.use(authenticate);
router.use(verifyTenantAccess);

// Member management (Admin/Manager only)
router.get('/', membersController.getMembers);
router.get('/:member_id', membersController.getMemberById);
router.put('/:member_id/role', requireRole(['Admin', 'Manager']), membersController.updateMemberRole);
router.put('/:member_id/status', requireRole(['Admin']), membersController.updateMemberStatus);

module.exports = router;
