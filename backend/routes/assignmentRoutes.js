// routes/assignmentRoutes.js

const express = require('express');
const router = express.Router();
const Assignment = require('../models/assignmentModel'); // Adjust path as needed
const multer = require('multer');
const path = require('path');

// Multer setup for file uploads
const storage = multer.diskStorage({
    destination: './uploads/',
    filename: (req, file, cb) => {
        cb(null, Date.now() + path.extname(file.originalname)); // Append timestamp to file name
    }
});
const upload = multer({ storage });

// Create a new assignment
router.post('/', upload.single('file'), async (req, res) => {
    try {
        const { standard, subject, assignmentName, dueDate } = req.body;
        const fileName = req.file ? req.file.originalname : '';
        const file = req.file ? req.file.path : '';

        const newAssignment = new Assignment({
            standard,
            subject,
            assignmentName,
            dueDate,
            fileName,
            file,
        });

        await newAssignment.save();
        res.status(201).json(newAssignment);
    } catch (error) {
        res.status(400).json({ error: 'Assignment validation failed', details: error.message });
    }
});

// Get all assignments
router.get('/', async (req, res) => {
    try {
        const assignments = await Assignment.find();
        res.status(200).json(assignments);
    } catch (error) {
        res.status(400).json({ error: 'Failed to load assignments', details: error.message });
    }
});

// Update an existing assignment
router.put('/:id', upload.single('file'), async (req, res) => {
    try {
        const { id } = req.params;
        const { standard, subject, assignmentName, dueDate } = req.body;
        const fileName = req.file ? req.file.originalname : '';
        const file = req.file ? req.file.path : '';

        const updatedAssignment = await Assignment.findByIdAndUpdate(id, {
            standard,
            subject,
            assignmentName,
            dueDate,
            fileName,
            file,
        }, { new: true });

        if (!updatedAssignment) {
            return res.status(404).json({ error: 'Assignment not found' });
        }

        res.status(200).json(updatedAssignment);
    } catch (error) {
        res.status(400).json({ error: 'Assignment validation failed', details: error.message });
    }
});

// Delete an assignment
router.delete('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const deletedAssignment = await Assignment.findByIdAndDelete(id);

        if (!deletedAssignment) {
            return res.status(404).json({ error: 'Assignment not found' });
        }

        res.status(200).json({ message: 'Assignment deleted successfully' });
    } catch (error) {
        res.status(400).json({ error: 'Failed to delete assignment', details: error.message });
    }
});

module.exports = router;
