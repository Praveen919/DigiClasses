const express = require('express');
const Feedback = require('../models/feedbacksModel');
const User = require('../models/userModel'); // Import the User model
const jwt = require('jsonwebtoken');

const router = express.Router();

// JWT verification middleware
const verifyJWT = (req, res, next) => {
    const token = req.headers['authorization'];

    if (!token) {
        return res.status(403).json({ message: 'No token provided' });
    }

    jwt.verify(token, process.env.JWT_SECRET, (err, decoded) => {
        if (err) {
            return res.status(500).json({ message: 'Failed to authenticate token', error: err.message });
        }
        req.userId = decoded.id;  // Store user ID from the token
        req.role = decoded.role;  // Assuming role is also part of the token
        next();
    });
};

// Add feedback
router.post('/', verifyJWT, async (req, res) => {
    const { teacherId, staffId, subject, feedback } = req.body;

    // Validate required fields
    if (!subject || !feedback) {
        return res.status(400).json({ message: 'Subject and feedback content are required' });
    }

    // Ensure at least one of the roles (teacher, staff) is provided
    if (!teacherId && !staffId) {
        return res.status(400).json({ message: 'At least one ID (teacher or staff) is required' });
    }

    try {
        // Fetch the student ID based on the logged-in user
        const user = await User.findById(req.userId); // Adjust this if you're using a different way to find users
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        const studentId = user._id; // Assuming the logged-in user is a student

        const newFeedback = new Feedback({
            studentId, // Use fetched studentId
            teacherId: teacherId || null, // Use null if not provided
            staffId: staffId || null,     // Use null if not provided
            subject,
            feedback,
            createdAt: new Date(),
        });

        await newFeedback.save();
        return res.status(201).json({ message: 'Feedback submitted successfully', feedback: newFeedback });
    } catch (error) {
        console.error('Error submitting feedback:', error);
        return res.status(500).json({ message: 'Error submitting feedback', error: error.message });
    }
});

// Fetch all feedbacks (Admin only)
router.get('/', verifyJWT, async (req, res) => {
    if (req.role !== 'admin') {
        return res.status(403).json({ message: 'Access denied' });
    }

    try {
        const feedbacks = await Feedback.find()
            .populate('studentId', 'name')
            .populate('teacherId', 'name')
            .populate('staffId', 'name');

        return res.status(200).json(feedbacks);
    } catch (error) {
        console.error('Error fetching feedbacks:', error);
        return res.status(500).json({ message: 'Error fetching feedbacks', error: error.message });
    }
});

module.exports = router;
