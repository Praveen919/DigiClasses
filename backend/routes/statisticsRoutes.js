const express = require('express');
const router = express.Router();
const Attendance = require('../models/attendanceModel');
const Student = require('../models/studentModel');
const Inquiry = require('../models/inquiryModel');

// Route to get total students count
router.get('/students/count', async (req, res) => {
  try {
    const count = await Student.countDocuments({});
    res.status(200).json({ count });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch students count' });
  }
});

// Route to get today's absentees count 
router.get('/absentees/count', async (req, res) => {
  try {
    const today = new Date().toISOString().slice(0, 10); // Get today's date in YYYY-MM-DD format
    const absenteesCount = await Attendance.countDocuments({
      date: {
        $gte: new Date(today),
        $lt: new Date(new Date(today).getTime() + 24 * 60 * 60 * 1000) // 24 hours window
      },
      status: 'Absent'
    });
    res.status(200).json({ count: absenteesCount });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch absentees count' });
  }
});

// Route to get all inquiries
router.get('/inquiries', async (req, res) => {
  try {
    const inquiries = await Inquiry.find({});
    res.status(200).json(inquiries);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch inquiries' });
  }
});

// Route to get all students
router.get('/students', async (req, res) => {
  try {
    const students = await Student.find({});
    res.status(200).json(students);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch students' });
  }
});

// Route to get all absentees for today 
router.get('/absentees', async (req, res) => {
  try {
    const today = new Date().toISOString().slice(0, 10); // Get today's date in YYYY-MM-DD format
    const absentees = await Attendance.find({
      date: {
        $gte: new Date(today),
        $lt: new Date(new Date(today).getTime() + 24 * 60 * 60 * 1000) // 24 hours window
      },
      status: 'Absent'
    }).populate('student', 'name rollNumber'); // Only return student name and roll number

    // Return only student details, without attendance info
    const absenteeList = absentees.map(absentee => ({
      name: absentee.student.name,
      rollNumber: absentee.student.rollNumber,
    }));

    res.status(200).json(absenteeList);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch absentees' });
  }
});

module.exports = router;
