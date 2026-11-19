/**
 * tenant.js
 * 
 * Multi-tenant isolation middleware.
 * Responsibilities:
 * - Verify user has access to requested workspace
 * - Validate workspace_id in request parameters or body
 * - Ensure workspace belongs to authenticated user
 * - Prevent cross-tenant data access
 */

const db = require('../config/db');

const verifyTenantAccess = async (req, res, next) => {
    try {
        // Ensure user is authenticated
        if (!req.user || !req.user.userId) {
            return res.status(401).json({
                status: 'error',
                message: 'Authentication required.'
            });
        }
        
        // Extract workspace_id from various sources
        const workspaceId = req.params.workspace_id || 
                           req.query.workspace_id || 
                           req.body.workspace_id ||
                           req.user.workspaceId;
        
        if (!workspaceId) {
            return res.status(400).json({
                status: 'error',
                message: 'Workspace ID is required.'
            });
        }
        
        // Verify user is a member of the workspace
        const result = await db.query(
            `SELECT wm.id, wm.role_id, r.role_name
             FROM core.workspace_members wm
             JOIN core.roles r ON wm.role_id = r.id
             WHERE wm.workspace_id = $1 AND wm.user_id = $2`,
            [workspaceId, req.user.userId]
        );
        
        if (result.rows.length === 0) {
            return res.status(403).json({
                status: 'error',
                message: 'Access denied. You are not a member of this workspace.'
            });
        }
        
        // Attach workspace info to request
        req.workspace = {
            workspaceId: workspaceId,
            membershipId: result.rows[0].id,
            roleId: result.rows[0].role_id,
            role: result.rows[0].role_name
        };
        
        next();
    } catch (error) {
        console.error('Tenant verification error:', error);
        return res.status(500).json({
            status: 'error',
            message: 'Error verifying workspace access.'
        });
    }
};

module.exports = verifyTenantAccess;
