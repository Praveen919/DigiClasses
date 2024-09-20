const express = require('express');
const Feedback = require('../models/feedbacksModel');
const verifyJWT = require('../utils/middleware');

const router = express.Router();

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

// Add feedback (optional)
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
