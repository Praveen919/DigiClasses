const express = require('express');
const router = express.Router();
const ClassBatch = require('../models/classBatchModel');
const Student = require('../models/studentModel');

// Fetch all classes/batches
router.get('/classes', async (req, res) => {
  try {
    const classes = await ClassBatch.find();
    res.json(classes);
  } catch (error) {
    res.status(500).json({ message: 'Server Error' });
  }
});

// Assign a class/batch to a student
router.post('/assign', async (req, res) => {
  const { studentId, classBatchId } = req.body;

  try {
    const student = await Student.findById(studentId);
    if (!student) {
      return res.status(404).json({ message: 'Student not found' });
    }

    const classBatch = await ClassBatch.findById(classBatchId);
    if (!classBatch) {
      return res.status(404).json({ message: 'Class/Batch not found' });
    }

    // Update the student's class/batch assignment
    student.classBatch = classBatchId;
    await student.save();

    res.json({ message: 'Class/Batch assigned to student successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Server Error' });
  }
});

// Fetch students assigned to a specific class/batch
router.get('/students/:classBatchId', async (req, res) => {
  const { classBatchId } = req.params;

  try {
    const students = await Student.find({ classBatch: classBatchId });
    res.json(students);
  } catch (error) {
    res.status(500).json({ message: 'Server Error' });
  }
});

module.exports = router;
