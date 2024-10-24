const express = require('express');
const multer = require('multer');
const jwt = require('jsonwebtoken');
const Absence = require('../models/absenceMessageModel');
const User = require('../models/userModel');
const router = express.Router();

// Set up multer for file uploads
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/');
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + '-' + file.originalname);
  },
});

const upload = multer({ storage: storage });

// Middleware to verify JWT and extract student ID
const verifyStudentToken = async (req, res, next) => {
  const token = req.headers['authorization']?.split(' ')[1];
  if (!token) return res.status(403).json({ message: 'Token is required' });

  jwt.verify(token, process.env.JWT_SECRET, async (err, decoded) => {
    if (err) return res.status(401).json({ message: 'Invalid token' });

    const user = await User.findById(decoded.id);
    if (!user || user.role.toLowerCase() !== 'student') {
      return res.status(403).json({ message: 'Access denied. Only students can submit absence messages.' });
    }

    req.studentId = user._id; // Set studentId for future use
    next();
  });
};

// POST route to handle absence notifications
router.post('/absence', verifyStudentToken, upload.single('document'), async (req, res) => {
  try {
    const { reason, standard, batch } = req.body; // Extract standard and batch from request
    const documentPath = req.file ? req.file.path : null;
    const studentId = req.studentId;

    const newAbsence = new Absence({
      reason,
      document: documentPath,
      student: studentId,
      standard, // Include standard if provided
      batch,    // Include batch if provided
    });

    await newAbsence.save();

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
    today.setHours(0, 0, 0, 0); // Set to the start of the day (midnight)
    
    const tomorrow = new Date(today);
    tomorrow.setDate(today.getDate() + 1); // Set to the start of the next day

    // Find absences where the createdAt field is between today and tomorrow
    const absentees = await Absence.find({
      createdAt: {
        $gte: today,
        $lt: tomorrow,
      },
    }).populate('student', 'name'); // Populate the student field

    // Format the response with studentName field
    const formattedAbsentees = absentees.map(absentee => ({
      studentName: absentee.student ? absentee.student.name : 'Unknown', // Fallback to 'Unknown'
      reason: absentee.reason,
      createdAt: absentee.createdAt,
      document: absentee.document,
      standard: absentee.standard, // Include standard in response if needed
      batch: absentee.batch,       // Include batch in response if needed
    }));

    console.log('Fetched absentees:', formattedAbsentees);

    if (formattedAbsentees.length === 0) {
      return res.status(404).json({ message: 'No absentees found for today.' });
    }

    res.status(200).json(formattedAbsentees); // Return formatted absentees
  } catch (error) {
    console.error('Error fetching today\'s absentees:', error);
    res.status(500).json({ message: 'Failed to fetch absentees' });
  }
});

// GET route to fetch today's absentees count
router.get('/absences/today/count', async (req, res) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0); // Start of the day

    const tomorrow = new Date(today);
    tomorrow.setDate(today.getDate() + 1); // Start of the next day

    // Count absences where the createdAt field is between today and tomorrow
    const absenteesCount = await Absence.countDocuments({
      createdAt: {
        $gte: today,
        $lt: tomorrow,
      },
    });

    res.status(200).json({ count: absenteesCount });
  } catch (error) {
    console.error('Error fetching absentees count:', error.message);
    res.status(500).json({ message: 'Failed to fetch absentees count', error: error.message });
  }
});

module.exports = router;
