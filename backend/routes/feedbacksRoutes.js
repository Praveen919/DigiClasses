const express = require('express');
const Feedback = require('../models/feedbacksModel');
const User = require('../models/userModel');
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
        req.userId = decoded.id; // Store user ID from the token
        req.role = decoded.role; // Store user role
        console.log('Decoded JWT:', decoded); // Log for debugging
        next();
    });
};

// Add feedback (for students)
router.post('/', verifyJWT, async (req, res) => {
    const { subject, feedback } = req.body;

    // Validate required fields
    if (!subject || !feedback) {
        return res.status(400).json({ message: 'Subject and feedback content are required' });
    }

    try {
        const user = await User.findById(req.userId);
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        const studentId = user._id;

        // Check for existing feedback for the same subject by the same student
        const existingFeedback = await Feedback.findOne({ studentId, subject });

        if (existingFeedback) {
            console.log(`Feedback already exists for student ${studentId} on subject ${subject}`);
            return res.status(200).json({ message: 'Feedback already submitted', feedback: existingFeedback });
        }

        const feedbackDoc = new Feedback({
            studentId,
            subject,
            feedback,
            createdAt: new Date(),
        });

        await feedbackDoc.save();
        return res.status(201).json({ message: 'Feedback submitted successfully', feedback: feedbackDoc });
    } catch (error) {
        console.error('Error submitting feedback:', error); // Log the error
        return res.status(500).json({ message: 'Error submitting feedback', error: error.message });
    }
});

// Fetch all feedbacks from Students
router.get('/', verifyJWT, async (req, res) => {
    // Allow both admin and teacher roles to access this route
    if (!['admin', 'Admin', 'teacher', 'Teacher'].includes(req.role)) {
        return res.status(403).json({ message: 'Access denied' });
    }

    try {
        // Fetch only feedbacks submitted by students
        const feedbacks = await Feedback.find({ teacherId: null }) // Assuming teacherId is null for student feedback
            .populate('studentId', 'name'); // Populate student name
        return res.status(200).json(feedbacks);
    } catch (error) {
        console.error('Error fetching feedbacks:', error); // Log the error
        return res.status(500).json({ message: 'Error fetching feedbacks', error: error.message });
    }
});

// Add feedback from Teacher to Admin
router.post('/admin', verifyJWT, async (req, res) => {
    const { subject, feedback } = req.body;

    // Validate required fields
    if (!subject || !feedback) {
        return res.status(400).json({ message: 'Subject and feedback content are required' });
    }

    // Allow only teachers to submit feedback to admins
    if (req.role.toLowerCase() !== 'teacher') {
        return res.status(403).json({ message: 'Access denied. Only teachers can submit feedback to admins.' });
    }

    try {
        const user = await User.findById(req.userId);
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        const feedbackDoc = new Feedback({
            subject,
            feedback,
            createdAt: new Date(),
            submittedBy: req.userId, // Store the teacher's ID
            teacherId: user._id // Add the teacher's ID to the feedback
        });

        await feedbackDoc.save();
        console.log('Teacher feedback saved:', feedbackDoc); // Log the saved feedback

        return res.status(201).json({ message: 'Feedback submitted to admin successfully', feedback: feedbackDoc });
    } catch (error) {
        console.error('Error submitting feedback to admin:', error); // Log the error
        return res.status(500).json({ message: 'Error submitting feedback to admin', error: error.message });
    }
});

// Fetch all feedbacks from Teachers (Only Admin can access)
router.get('/admin', verifyJWT, async (req, res) => {

    // Allow only admin roles to access this route
    if (!['admin', 'Admin'].includes(req.role)) {
        return res.status(403).json({ message: 'Access denied' });
    }

    try {
        const feedbacks = await Feedback.find({ teacherId: { $ne: null } }) // Fetch only feedbacks submitted by teachers
            .populate('teacherId', 'name'); // Populate teacher's name
        return res.status(200).json(feedbacks);
    } catch (error) {
        console.error('Error fetching admin feedbacks:', error);
        return res.status(500).json({ message: 'Error fetching admin feedbacks', error: error.message });
    }
});

module.exports = router;
