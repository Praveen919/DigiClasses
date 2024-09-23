const express = require('express');
const router = express.Router();
const Student = require('../models/studentModel');
const ClassBatch = require('../models/classBatchModel');
const Attendance = require('../models/attendanceModel');

// Route to get all class batches
router.get('/class-batch', async (req, res) => {
  try {
    const classBatches = await ClassBatch.find();
    res.json(classBatches);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Route for students to get their attendance data
router.get('/student-attendance/:studentId', async (req, res) => {
  try {
    const { studentId } = req.params;
    const attendanceRecords = await Attendance.find({ student: studentId }).populate('classBatch');

    // Transform data if necessary
    const response = attendanceRecords.map(record => ({
      date: record.date.toISOString().split('T')[0], // Format the date as needed
      status: record.status,
      classBatch: record.classBatch.name // Assuming classBatch has a name field
    }));

    res.json(response);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Route to get attendance data for a specific class batch and date (Admin/Teacher use)
router.post('/attendance-data', async (req, res) => {
  try {
    const { classBatchId, date } = req.body;
    const attendance = await Attendance.find({ classBatch: classBatchId, date });
    res.json(attendance);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Route to update attendance (Admin/Teacher use)
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

module.exports = router;
