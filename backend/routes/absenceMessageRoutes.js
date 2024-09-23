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
    const { studentName, standard, batch, reason } = req.body;
    const documentPath = req.file ? req.file.path : null; // If a file is uploaded, save its path

    // Create and save the absence entry
    const newAbsence = new Absence({
      studentName,
      standard,
      batch,
      reason,
      document: documentPath,
    });

    await newAbsence.save();

    // Notify admin and teachers (this can be done using a separate notification service)
    console.log('Absence notification sent to admin and teachers');

    res.status(200).json({ message: 'Absence notification submitted successfully' });
  } catch (error) {
    console.error('Error submitting absence notification:', error);
    res.status(500).json({ message: 'Failed to submit absence notification' });
  }
});

// GET route to fetch today's absentees
router.get('/absences/today', async (req, res) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const absentees = await Absence.find({
      createdAt: {
        $gte: today,
        $lt: new Date(today.getTime() + 24 * 60 * 60 * 1000),
      },
    });

    res.status(200).json(absentees);
  } catch (error) {
    console.error('Error fetching today\'s absentees:', error);
    res.status(500).json({ message: 'Failed to fetch absentees' });
  }
});

module.exports = router;
