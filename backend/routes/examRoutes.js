// routes/examRoutes.js

const express = require('express');
const router = express.Router();
const Exam = require('../models/examModel'); // Adjust path as needed
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

// POST route to create a manual exam (with file upload if required)
router.post('/', upload.single('document'), async (req, res) => {
    const { standard, subject, examName, totalMarks, examDate, fromTime, toTime, note, remark } = req.body;

    if (!standard || !subject || !examName || !totalMarks || !examDate || !fromTime || !toTime) {
        return res.status(400).json({ message: 'All required fields must be filled' });
    }

    try {
        const newExam = new Exam({
            standard,
            subject,
            examName,
            totalMarks,
            examDate,
            fromTime,
            toTime,
            note,
            remark,
            documentPath: req.file ? req.file.path : ''
        });

        await newExam.save();
        res.status(201).json({ message: 'Exam created successfully', exam: newExam });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Update an existing manual exam
router.put('/:id', upload.single('document'), async (req, res) => {
    const { id } = req.params;
    const { standard, subject, examName, totalMarks, examDate, fromTime, toTime, note, remark } = req.body;

    try {
        const exam = await Exam.findById(id);

        if (!exam) {
            return res.status(404).json({ message: 'Exam not found' });
        }

        exam.standard = standard || exam.standard;
        exam.subject = subject || exam.subject;
        exam.examName = examName || exam.examName;
        exam.totalMarks = totalMarks || exam.totalMarks;
        exam.examDate = examDate ? new Date(examDate) : exam.examDate;
        exam.fromTime = fromTime || exam.fromTime;
        exam.toTime = toTime || exam.toTime;
        exam.note = note || exam.note;
        exam.remark = remark || exam.remark;
        exam.documentPath = req.file ? req.file.path : exam.documentPath;

        const updatedExam = await exam.save();
        res.status(200).json({ message: 'Exam updated successfully', exam: updatedExam });
    } catch (error) {
        console.error('Error updating exam:', error.message);
        res.status(500).json({ message: 'Error updating exam', error: error.message });
    }
});

// GET route to fetch all manual exams
router.get('/', async (req, res) => {
    try {
        const exams = await Exam.find();
        res.status(200).json(exams);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Delete Manual Exams
router.delete('/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const result = await Exam.findByIdAndDelete(id);
        if (!result) {
            return res.status(404).json({ message: 'Exam not found' });
        }
        res.status(200).json({ message: 'Exam deleted successfully' });
    } catch (error) {
        console.error('Error deleting exam:', error.message);
        res.status(500).json({ message: 'Error deleting exam', error: error.message });
    }
});

module.exports = router;
