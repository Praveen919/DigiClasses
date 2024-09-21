const express = require('express');
const Feedback = require('../models/feedbacksModel');
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
            return res.status(500).json({ message: 'Failed to authenticate token' });
        }
        req.userId = decoded.id;
        next();
    });
};

// Fetch all feedbacks
router.get('/', verifyJWT, async (req, res) => {
    try {
        const feedbacks = await Feedback.find().populate('studentId', 'name');
        res.status(200).json(feedbacks);
    } catch (error) {
        console.error('Error fetching feedbacks:', error.message);
        res.status(500).json({ message: 'Error fetching feedbacks' });
    }
});

// Add feedback
router.post('/', verifyJWT, async (req, res) => {
    const { studentId, subject, feedback } = req.body;

    if (!studentId || !subject || !feedback) {
        return res.status(400).json({ message: 'All fields are required' });
    }

    try {
        const newFeedback = new Feedback({ studentId, subject, feedback });
        await newFeedback.save();
        res.status(201).json({ message: 'Feedback submitted successfully' });
    } catch (error) {
        console.error('Error submitting feedback:', error.message);
        res.status(500).json({ message: 'Error submitting feedback' });
    }
});

module.exports = router;
