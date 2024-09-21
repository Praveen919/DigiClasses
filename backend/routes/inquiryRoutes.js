const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const Inquiry = require('../models/inquiryModel');

// Set up multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/'); // Directory where files will be stored
  },
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}_${file.originalname}`); // Rename file to avoid conflicts
  }
});

const upload = multer({ storage: storage });

// Create a new inquiry with file upload
router.post('/', upload.single('file'), async (req, res) => {
  try {
    const {
      studentName,
      gender,
      fatherMobile,
      motherMobile,
      studentMobile,
      studentEmail,
      schoolCollege,
      university,
      standard,
      courseType,
      referenceBy,
      inquiryDate,
      inquirySource,
      inquiry
    } = req.body;

    if (!studentName || !gender || !standard || !courseType || !inquiryDate) {
      return res.status(400).json({ message: 'Missing required fields' });
    }

    const inquiryData = {
      studentName,
      gender,
      fatherMobile,
      motherMobile,
      studentMobile,
      studentEmail,
      schoolCollege,
      university,
      standard,
      courseType,
      referenceBy,
      inquiryDate,
      inquirySource,
      inquiry,
      fileName: req.file ? req.file.filename : null, // Save file name in the database
    };

    const newInquiry = new Inquiry(inquiryData);
    await newInquiry.save();
    res.status(201).json(newInquiry);
  } catch (error) {
    console.error('Error creating inquiry:', error.message);
    res.status(400).json({ message: 'Bad Request', error: error.message });
  }
});

// Get all inquiries
router.get('/', async (req, res) => {
  try {
    const inquiries = await Inquiry.find();
    res.json(inquiries);
  } catch (error) {
    console.error('Error fetching inquiries:', error.message);
    res.status(500).json({ message: 'Internal Server Error', error: error.message });
  }
});

// Get a specific inquiry by ID
router.get('/:id', async (req, res) => {
  try {
    const inquiry = await Inquiry.findById(req.params.id);
    if (inquiry) {
      res.json(inquiry);
    } else {
      res.status(404).json({ message: 'Inquiry not found' });
    }
  } catch (error) {
    console.error('Error fetching inquiry by ID:', error.message);
    res.status(500).json({ message: 'Internal Server Error', error: error.message });
  }
});

// Update an inquiry by ID
router.put('/:id', async (req, res) => {
  try {
    const inquiryId = req.params.id;
    const updatedData = req.body;

    // Validate that 'isSolved' is a boolean
    if (updatedData.hasOwnProperty('isSolved') && typeof updatedData.isSolved !== 'boolean') {
      return res.status(400).json({ message: 'Invalid value for isSolved' });
    }

    const updatedInquiry = await Inquiry.findByIdAndUpdate(inquiryId, updatedData, { new: true });

    if (!updatedInquiry) {
      return res.status(404).json({ message: 'Inquiry not found' });
    }

    res.json(updatedInquiry);
  } catch (error) {
    console.error('Error updating inquiry:', error.message);
    res.status(500).json({ message: 'Failed to update inquiry', error: error.message });
  }
});

// Delete an inquiry by ID
router.delete('/:id', async (req, res) => {
  try {
    const inquiryId = req.params.id;

    const deletedInquiry = await Inquiry.findByIdAndDelete(inquiryId);

    if (!deletedInquiry) {
      return res.status(404).json({ message: 'Inquiry not found' });
    }

    res.json({ message: 'Inquiry deleted successfully' });
  } catch (error) {
    console.error('Error deleting inquiry:', error.message);
    res.status(500).json({ message: 'Failed to delete inquiry', error: error.message });
  }
});

module.exports = router;
