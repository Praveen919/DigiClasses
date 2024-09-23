const express = require('express');
const multer = require('multer');
const Absence = require('../models/absenceMessageModel');
const router = express.Router();

// Set up multer for file uploads
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/'); // Directory where files will be stored
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + '-' + file.originalname); // Save the file with a unique name
  },
});

const upload = multer({ storage: storage });

// POST route to handle absence notifications
router.post('/absence', upload.single('document'), async (req, res) => {
  try {
    const { reason } = req.body;
    const documentPath = req.file ? req.file.path : null; // If a file is uploaded, save its path

    // Create and save the absence entry
    const newAbsence = new Absence({
      reason,
      document: documentPath,
    });

    await newAbsence.save();

    // Notify admin and teachers (this can be done using a separate notification service)
    // For now, we just log it
    console.log('Absence notification sent to admin and teachers');

    res.status(200).json({ message: 'Absence notification submitted successfully' });
  } catch (error) {
    console.error('Error submitting absence notification:', error);
    res.status(500).json({ message: 'Failed to submit absence notification' });
  }
});

module.exports = router;
