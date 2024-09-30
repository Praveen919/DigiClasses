const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { body, validationResult } = require('express-validator');
const User = require('../models/userModel');
const { verifyJWT } = require('../utils/middleware');

const router = express.Router();

// User registration route with validation and sanitization
router.post('/register', [
    body('email').isEmail().withMessage('Invalid email').normalizeEmail(),
    body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters long'),
    body('mobile').isMobilePhone().withMessage('Invalid mobile number'),
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }

    const { instituteName, country, city, name, mobile, email, password, role, branch, year } = req.body;

    try {
        const existingUser = await User.findOne({ email });
        if (existingUser) {
            return res.status(409).json({ message: 'Email already exists' });
        }

        const newUser = new User({
            instituteName,
            country,
            city,
            name,
            mobile,
            email,
            password, // Store raw password; it will be hashed in pre-save middleware
            role,
            branch: branch || null,  // Optional branch
            year: year || null        // Optional year
        });

        await newUser.save();
        res.status(201).json({ message: 'User registered successfully' });
    } catch (error) {
        console.error('Error during registration:', error.message);
        res.status(500).json({ message: 'Error registering user' });
    }
});

// Login route with JWT authentication
router.post('/login', async (req, res) => {
    const { email, password } = req.body;

    try {
        const user = await User.findOne({ email });
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        const match = await bcrypt.compare(password, user.password);
        if (!match) {
            return res.status(401).json({ message: 'Invalid credentials' });
        }

        // Create JWT token
        const token = jwt.sign({ id: user._id, role: user.role, email: user.email }, process.env.JWT_SECRET, { expiresIn: '1h' });
        res.status(200).json({
            message: 'Login successful',
            token,
            userData: {
                name: user.name,
                branch: user.branch || '',  // Send branch if available
                year: user.year || '',      // Send year if available
                role: user.role
            }
        });
    } catch (error) {
        console.error('Error during login:', error.message);
        res.status(500).json({ message: 'Error logging in' });
    }
});

// Route to get all students (role: Student)
router.get('/students', verifyJWT, async (req, res) => {
    try {
        const students = await User.find({ role: 'Student' }).select('-password');
        res.status(200).json(students);
    } catch (error) {
        console.error('Error fetching students:', error.message);
        res.status(500).json({ message: 'Error fetching students' });
    }
});

// Route to get users by role (e.g., Teachers)
router.get('/users', verifyJWT, async (req, res) => {
    try {
        const role = req.query.role || 'Teacher';  // Default to 'Teacher'
        const users = await User.find({ role }).select('-password');
        res.status(200).json(users);
    } catch (error) {
        console.error('Error fetching users:', error.message);
        res.status(500).json({ message: 'Error fetching users' });
    }
});

module.exports = router;
