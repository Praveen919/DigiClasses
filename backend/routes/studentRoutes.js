const express = require('express');
const router = express.Router();
const Student = require('../models/studentModel');
const ClassBatch = require('../models/classBatchModel');

// Route to create a new student
router.post('/add', async (req, res) => {
  try {
    const { name, rollNumber } = req.body;

    // Validate input
    if (!name || !rollNumber) {
      return res.status(400).json({ error: 'Name and Roll Number are required' });
    }

    const student = new Student({ name, rollNumber });
    await student.save();

    res.status(201).json(student);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Route to get all students (with batch info)
router.get('/all', async (req, res) => {
  try {
    const students = await Student.find().populate('classBatch', 'classBatchName'); // Populate classBatch info
    res.status(200).json(students);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
