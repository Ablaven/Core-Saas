/**
 * workspaces.routes.js
 * 
 * Workspace management routes.
 * Responsibilities:
 * - Define routes for workspace CRUD operations
 * - Define routes for workspace member management
 * - Apply authentication and authorization middleware
 * - Apply tenant isolation where needed
 */

const express = require('express');
const router = express.Router();
const workspacesController = require('../controllers/workspaces.controller');
const authenticate = require('../middleware/auth');
const requireRole = require('../middleware/requireRole');
const verifyTenantAccess = require('../middleware/tenant');
// const validate = require('../middleware/validate');

// All routes require authentication
router.use(authenticate);

// Workspace CRUD
router.get('/', workspacesController.getWorkspaces);
router.post('/', workspacesController.createWorkspace);
router.get('/:workspace_id', verifyTenantAccess, workspacesController.getWorkspaceById);
router.put('/:workspace_id', verifyTenantAccess, requireRole(['Admin']), workspacesController.updateWorkspace);
router.delete('/:workspace_id', verifyTenantAccess, requireRole(['Admin']), workspacesController.deleteWorkspace);

// Workspace members
router.get('/:workspace_id/members', verifyTenantAccess, workspacesController.getWorkspaceMembers);
router.post('/:workspace_id/members', verifyTenantAccess, requireRole(['Admin', 'Manager']), workspacesController.addMember);
router.delete('/:workspace_id/members/:member_id', verifyTenantAccess, requireRole(['Admin', 'Manager']), workspacesController.removeMember);

module.exports = router;
