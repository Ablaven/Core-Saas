/**
 * validate.js
 * 
 * Request validation middleware using Joi.
 * Responsibilities:
 * - Validate request body, query parameters, and route params
 * - Use Joi schemas for validation rules
 * - Return detailed validation errors
 * - Sanitize and transform input data
 */

const Joi = require('joi');

const validate = (schema) => {
    return (req, res, next) => {
        const validationOptions = {
            abortEarly: false,  // Return all errors, not just the first one
            allowUnknown: true, // Allow unknown keys that will be ignored
            stripUnknown: true  // Remove unknown keys from the validated data
        };
        
        // Validate request body
        if (schema.body) {
            const { error, value } = schema.body.validate(req.body, validationOptions);
            
            if (error) {
                const errors = error.details.map(detail => ({
                    field: detail.path.join('.'),
                    message: detail.message
                }));
                
                return res.status(400).json({
                    status: 'error',
                    message: 'Validation failed',
                    errors: errors
                });
            }
            
            req.body = value;
        }
        
        // Validate query parameters
        if (schema.query) {
            const { error, value } = schema.query.validate(req.query, validationOptions);
            
            if (error) {
                const errors = error.details.map(detail => ({
                    field: detail.path.join('.'),
                    message: detail.message
                }));
                
                return res.status(400).json({
                    status: 'error',
                    message: 'Query validation failed',
                    errors: errors
                });
            }
            
            req.query = value;
        }
        
        // Validate route parameters
        if (schema.params) {
            const { error, value } = schema.params.validate(req.params, validationOptions);
            
            if (error) {
                const errors = error.details.map(detail => ({
                    field: detail.path.join('.'),
                    message: detail.message
                }));
                
                return res.status(400).json({
                    status: 'error',
                    message: 'Parameter validation failed',
                    errors: errors
                });
            }
            
            req.params = value;
        }
        
        next();
    };
};

module.exports = validate;
