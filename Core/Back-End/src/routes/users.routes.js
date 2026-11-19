/**
 * users.routes.js
 * 
 * User management routes.
 * Responsibilities:
 * - Define routes for user CRUD operations
 * - Define routes for user search and filtering
 * - Apply authentication and admin-only authorization
 * - Handle user profile management
 */

const express = require('express');
const router = express.Router();
const usersController = require('../controllers/users.controller');
const authenticate = require('../middleware/auth');
const requireRole = require('../middleware/requireRole');
// const validate = require('../middleware/validate');

// All routes require authentication
router.use(authenticate);

// User management (Admin only)
router.get('/', requireRole(['Admin']), usersController.getUsers);
router.get('/:user_id', usersController.getUserById);
router.put('/:user_id', requireRole(['Admin']), usersController.updateUser);
router.delete('/:user_id', requireRole(['Admin']), usersController.deleteUser);

// User search
router.get('/search', usersController.searchUsers);

module.exports = router;
