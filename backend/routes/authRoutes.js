const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { body, validationResult } = require('express-validator');
const User = require('../models/userModel');
const {verifyJWT} = require('../utils/middleware');

const router = express.Router();

// User registration route with validation and sanitization
router.post('/register', [
    body('email').isEmail().withMessage('Invalid email').normalizeEmail(),
    body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters long'),
    body('mobile').isMobilePhone().withMessage('Invalid mobile number'),
    // Other field validations can go here
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }

    const { instituteName, country, city, name, mobile, email, password, role } = req.body;

    if (!instituteName || !country || !city || !name || !mobile || !email || !password || !role) {
        return res.status(400).json({ message: 'All fields are required' });
    }

    try {
        const existingUser = await User.findOne({ email });
        if (existingUser) {
            return res.status(409).json({ message: 'Email already exists' });
        }

        const hashedPassword = await bcrypt.hash(password, 10);
        const newUser = new User({
            instituteName,
            country,
            city,
            name,
            mobile,
            email,
            password: hashedPassword,
            role
        });

        await newUser.save();
        res.status(201).json({ message: 'User registered successfully' });
    } catch (error) {
        console.error('Error during registration:', error.message);
        res.status(500).json({ message: 'Error registering user' });
    }
});

// Login route with input validation
router.post('/login', async (req, res) => {
    const { email, password } = req.body;

    if (!email || !password) {
        return res.status(400).json({ message: 'Email and password are required' });
    }

    try {
        const user = await User.findOne({ email });

        if (user) {
            const match = await bcrypt.compare(password, user.password);
            if (match) {
                // Generate a JWT token including role
                const token = jwt.sign({ id: user._id, role: user.role }, process.env.JWT_SECRET, { expiresIn: '1h' });
                res.status(200).json({
                    message: 'Login successful',
                    token: token,
                    userData: {
                        name: user.name,
                        branch: user.branch,  // Returning branch
                        year: user.year,     // Returning year
                        role: user.role      // Returning role
                    }
                });
            } else {
                res.status(401).json({ message: 'Invalid credentials' });
            }
        } else {
            res.status(404).json({ message: 'User not found' });
        }
    } catch (error) {
        console.log('Error during login:', error.message);
        res.status(500).json({ message: 'Error logging in' });
    }
});

// Route to get all students
router.get('/students', verifyJWT, async (req, res) => {
    try {
        const students = await User.find({ role: 'Student' }).select('-password'); // Exclude password
        res.status(200).json(students);
    } catch (error) {
        console.error('Error fetching students:', error.message);
        res.status(500).json({ message: 'Error fetching students' });
    }
});

router.get('/users', verifyJWT, async (req, res) => {
    const role = req.query.role;
    try {
        const query = role ? { role } : {};
        const users = await User.find({role: 'Teacher'}).select('-password');
        res.status(200).json(users);
    } catch (error) {
        console.error('Error fetching users:', error.message);
        res.status(500).json({ message: 'Error fetching users' });
    }
});

module.exports = router;
