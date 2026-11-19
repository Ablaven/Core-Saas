/**
 * requireRole.js
 * 
 * Role-based access control (RBAC) middleware.
 * Responsibilities:
 * - Check if authenticated user has required role
 * - Query database for user's role name
 * - Allow or deny access based on role permissions
 * - Handle role-based authorization errors
 */

const db = require('../config/db');

const requireRole = (allowedRoles = []) => {
    return async (req, res, next) => {
        try {
            // Ensure user is authenticated (should be set by auth middleware)
            if (!req.user || !req.user.roleId) {
                return res.status(401).json({
                    status: 'error',
                    message: 'Authentication required.'
                });
            }
            
            // Fetch user's role name
            const result = await db.query(
                'SELECT role_name FROM core.roles WHERE id = $1',
                [req.user.roleId]
            );
            
            if (result.rows.length === 0) {
                return res.status(403).json({
                    status: 'error',
                    message: 'Role not found.'
                });
            }
            
            const userRole = result.rows[0].role_name;
            
            // Check if user's role is in allowed roles
            if (!allowedRoles.includes(userRole)) {
                return res.status(403).json({
                    status: 'error',
                    message: `Access denied. Required role: ${allowedRoles.join(' or ')}`
                });
            }
            
            // Attach role to request for further use
            req.user.role = userRole;
            
            next();
        } catch (error) {
            console.error('Role check error:', error);
            return res.status(500).json({
                status: 'error',
                message: 'Error checking user permissions.'
            });
        }
    };
};

module.exports = requireRole;
