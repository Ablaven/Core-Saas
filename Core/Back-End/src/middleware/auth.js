/**
 * auth.js
 * 
 * Authentication middleware.
 * Responsibilities:
 * - Verify JWT tokens from request headers
 * - Decode and validate token payload
 * - Attach user information to request object
 * - Handle authentication errors (expired, invalid, missing tokens)
 */

const jwt = require('jsonwebtoken');

const authenticate = (req, res, next) => {
    try {
        // Extract token from Authorization header
        const authHeader = req.headers.authorization;
        
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return res.status(401).json({
                status: 'error',
                message: 'Authentication required. Please provide a valid token.'
            });
        }
        
        const token = authHeader.split(' ')[1];
        
        // Verify token
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        
        // Attach user info to request
        req.user = {
            userId: decoded.userId,
            email: decoded.email,
            workspaceId: decoded.workspaceId,
            roleId: decoded.roleId
        };
        
        next();
    } catch (error) {
        if (error.name === 'TokenExpiredError') {
            return res.status(401).json({
                status: 'error',
                message: 'Token has expired. Please login again.'
            });
        }
        
        if (error.name === 'JsonWebTokenError') {
            return res.status(401).json({
                status: 'error',
                message: 'Invalid token. Authentication failed.'
            });
        }
        
        return res.status(500).json({
            status: 'error',
            message: 'Authentication error occurred.'
        });
    }
};

module.exports = authenticate;
