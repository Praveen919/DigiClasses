const express = require('express');
const router = express.Router();
const Student = require('../models/studentModel');
const ClassBatch = require('../models/classBatchModel');
const Attendance = require('../models/attendanceModel'); // Assuming you have an attendance model

// Route to get all class batches
router.get('/class-batch', async (req, res) => {
  try {
    const classBatches = await ClassBatch.find();
    res.json(classBatches);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Route to get attendance data by class batch and date
router.post('/attendance-data', async (req, res) => {
  try {
    const { classBatchId, date } = req.body;
    const attendance = await Attendance.find({ classBatch: classBatchId, date });
    res.json(attendance);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Route to update attendance
router.post('/update-attendance', async (req, res) => {
  try {
    const { attendanceId, status } = req.body;
    const attendance = await Attendance.findById(attendanceId);
    if (attendance) {
      attendance.status = status;
      await attendance.save();
      res.json({ message: 'Attendance updated successfully' });
    } else {
      res.status(404).json({ message: 'Attendance record not found' });
    }
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Route to get attendance percentage for a student
router.get('/attendance-percentage/:studentId', async (req, res) => {
  try {
    const { studentId } = req.params;

    // Fetch all attendance records for the student
    const attendanceRecords = await Attendance.find({ studentId });

    const totalClasses = attendanceRecords.length;
    const attendedClasses = attendanceRecords.filter(record => record.status === 'present').length;

    const attendancePercentage = totalClasses > 0 ? (attendedClasses / totalClasses) * 100 : 0;

    res.json({ attendancePercentage });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
