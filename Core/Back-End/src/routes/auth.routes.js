/**
 * auth.routes.js
 * 
 * Authentication routes.
 * Responsibilities:
 * - Define routes for user registration, login, logout
 * - Define routes for token refresh
 * - Define route for getting current user info
 * - Apply validation middleware to requests
 */

const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller');
const authenticate = require('../middleware/auth');
// const validate = require('../middleware/validate');

// Public routes (no authentication required)
router.post('/register', authController.register);
router.post('/login', authController.login);
router.post('/refresh', authController.refreshToken);

// Protected routes (authentication required)
router.get('/me', authenticate, authController.getCurrentUser);
router.post('/logout', authenticate, authController.logout);
router.put('/profile', authenticate, authController.updateProfile);
router.put('/password', authenticate, authController.changePassword);

module.exports = router;
