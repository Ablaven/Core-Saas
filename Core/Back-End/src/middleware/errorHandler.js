/**
 * errorHandler.js
 * 
 * Centralized error handling middleware.
 * Responsibilities:
 * - Catch all errors from routes and middleware
 * - Format error responses consistently
 * - Log errors appropriately
 * - Hide internal errors in production
 * - Return user-friendly error messages
 */

const errorHandler = (err, req, res, next) => {
    // Log error details (only in development)
    if (process.env.NODE_ENV === 'development') {
        console.error('Error:', err);
    }
    
    // Determine status code
    const statusCode = err.statusCode || err.status || 500;
    
    // Determine error message
    let message = err.message || 'Internal server error';
    
    // Hide internal errors in production
    if (process.env.NODE_ENV === 'production' && statusCode === 500) {
        message = 'An unexpected error occurred. Please try again later.';
    }
    
    // Handle specific error types
    if (err.code === '23505') {
        // PostgreSQL unique violation
        return res.status(409).json({
            status: 'error',
            message: 'A record with this value already exists.',
            code: 'DUPLICATE_ENTRY'
        });
    }
    
    if (err.code === '23503') {
        // PostgreSQL foreign key violation
        return res.status(400).json({
            status: 'error',
            message: 'Referenced record does not exist.',
            code: 'FOREIGN_KEY_VIOLATION'
        });
    }
    
    if (err.name === 'ValidationError') {
        return res.status(400).json({
            status: 'error',
            message: 'Validation failed.',
            errors: err.details || err.message
        });
    }
    
    // Send error response
    res.status(statusCode).json({
        status: 'error',
        message: message,
        ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
    });
};

module.exports = errorHandler;
