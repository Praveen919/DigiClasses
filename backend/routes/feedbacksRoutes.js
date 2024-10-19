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
        const feedbacks = await Feedback.find()
            .populate('studentId', 'name')
            .populate('teacherId', 'name');

        res.status(200).json(feedbacks);
    } catch (error) {
        console.error('Error fetching feedbacks:', error.message);
        res.status(500).json({ message: 'Error fetching feedbacks' });
    }
});

// Add feedback
router.post('/', verifyJWT, async (req, res) => {
    const { studentId, subject, feedback } = req.body;

    if (!subject || !feedback || !studentId ) {
        return res.status(400).json({ message: 'All fields are required' });
    }

    try {
        const newFeedback = new Feedback({ studentId, subject, feedback });
        await newFeedback.save();
        res.status(201).json({ message: 'Feedback submitted successfully' });
    } catch (error) {
        console.error('Error submitting feedback:', error.message);
        res.status(500).json({ message: 'Error submitting feedback' });
        console.log(error);
    }
});

router.post('/feedbacks', verifyJWT, async (req, res) => {
    const { subject, feedback } = req.body;
    const userId = req.userId;
    console.log(userId);

    // Validate and store feedback
    try {
        const newFeedback = new Feedback({
            studentId,
            subject,
            feedback,
            createdAt: new Date(),
        });

        await newFeedback.save();
        res.status(201).json({ message: 'Feedback submitted successfully', feedback: newFeedback });
    } catch (error) {
        res.status(500).json({ message: 'Error saving feedback', error });
        console.log(error);
    }
});

router.get('/admin/feedbacks', verifyJWT, async (req, res) => {
  if (req.role !== 'admin') {
    return res.status(403).json({ message: 'Access denied' });
  }

  try {
    const feedbacks = await Feedback.find(); // Fetch all feedback from DB
    res.status(200).json(feedbacks);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching feedbacks', error });
  }
});

module.exports = router;
