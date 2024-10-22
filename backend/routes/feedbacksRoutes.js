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

    jwt.verify(token.split(' ')[1], process.env.JWT_SECRET, (err, decoded) => {
        if (err) {
            return res.status(500).json({ message: 'Failed to authenticate token', error: err.message });
        }
        req.userId = decoded.id;  // Store user ID from the token
        req.role = decoded.role;  // Assuming role is also part of the token
        console.log('Decoded JWT:', decoded); // Log decoded token for debugging
        next();
    });
};

// Add feedback
router.post('/', verifyJWT, async (req, res) => {
    const { subject, feedback } = req.body;

    // Validate required fields
    if (!subject || !feedback) {
        return res.status(400).json({ message: 'Subject and feedback content are required' });
    }

    try {
        // Fetch the student based on the logged-in user
        const user = await User.findById(req.userId); 

        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        const studentId = user._id; // Assuming the logged-in user is a student

        // Check for existing feedback for the same subject by the same student
        const existingFeedback = await Feedback.findOne({
            studentId: studentId,
            subject: subject,
        });

        if (existingFeedback) {
            console.log(`Feedback already exists for student ${studentId} on subject ${subject}`);
            return res.status(200).json({ message: 'Feedback already submitted', feedback: existingFeedback });
        }

        // Create a new feedback entry
        const feedbackDoc = new Feedback({
            studentId,
            subject,
            feedback,
            createdAt: new Date(),
        });

        // Save the feedback document
        await feedbackDoc.save();
        console.log('Feedback saved:', feedbackDoc);  // Log the saved feedback

        return res.status(201).json({ message: 'Feedback submitted successfully', feedback: feedbackDoc });
    } catch (error) {
        console.error('Error submitting feedback:', error);  // Log the error
        return res.status(500).json({ message: 'Error submitting feedback', error: error.message });
    }
});

// Fetch all feedbacks (Admin and Teacher)
router.get('/', verifyJWT, async (req, res) => {
    // Log the user's role for debugging
    console.log(`User role: ${req.role}`);

    // Allow both admin and teacher roles to access this route
    if (!['admin', 'Admin', 'Teacher'].includes(req.role)) {
        return res.status(403).json({ message: 'Access denied' });
    }

    try {
        const feedbacks = await Feedback.find()
            .populate('studentId', 'name');   // Populate student name
        return res.status(200).json(feedbacks);
    } catch (error) {
        console.error('Error fetching feedbacks:', error);  // Log the error
        return res.status(500).json({ message: 'Error fetching feedbacks', error: error.message });
    }
});

module.exports = router;
