// routes/studyMaterialRoutes.js

const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const StudyMaterial = require('../models/studyMaterialModel'); // Adjust path as needed
const fs = require('fs');

// Set up Multer for file uploads
const storage = multer.diskStorage({
    destination: './uploads/',
    filename: (req, file, cb) => {
        cb(null, Date.now() + path.extname(file.originalname)); // Append timestamp to file name
    }
});
const upload = multer({ storage });

// Route to create a study material
router.post('/', upload.single('file'), async (req, res) => {
    const { courseName, standard, subject } = req.body;
    const file = req.file;

    if (!courseName || !standard || !subject) {
        return res.status(400).json({ message: 'Course Name, Standard, and Subject are required' });
    }

    try {
        const newStudyMaterial = new StudyMaterial({
            courseName,
            standard,
            subject,
            fileName: file ? file.originalname : null,
            filePath: file ? file.path : null
        });

        await newStudyMaterial.save();
        res.status(201).json({ message: 'Study material created successfully', studyMaterial: newStudyMaterial });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Route to get all study materials
router.get('/', async (req, res) => {
    try {
        const studyMaterials = await StudyMaterial.find();
        res.status(200).json(studyMaterials);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Route to update a study material
router.put('/:id', upload.single('file'), async (req, res) => {
    const { id } = req.params;
    const { courseName, standard, subject } = req.body;
    const file = req.file;

    try {
        const updatedStudyMaterial = await StudyMaterial.findByIdAndUpdate(id, {
            courseName,
            standard,
            subject,
            fileName: file ? file.originalname : undefined,
            filePath: file ? file.path : undefined
        }, { new: true });

        if (!updatedStudyMaterial) {
            return res.status(404).json({ message: 'Study material not found' });
        }

        res.status(200).json({ message: 'Study material updated successfully', studyMaterial: updatedStudyMaterial });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Route to delete a study material
router.delete('/:id', async (req, res) => {
    const { id } = req.params;

    try {
        const deletedStudyMaterial = await StudyMaterial.findByIdAndDelete(id);

        if (!deletedStudyMaterial) {
            return res.status(404).json({ message: 'Study material not found' });
        }

        // Optionally, delete the file from the server
        if (deletedStudyMaterial.filePath && fs.existsSync(deletedStudyMaterial.filePath)) {
            fs.unlinkSync(deletedStudyMaterial.filePath);
        }

        res.status(200).json({ message: 'Study material deleted successfully' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

module.exports = router;
