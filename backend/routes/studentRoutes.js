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

// Route to assign a student to a class/batch
router.post('/assign-class', async (req, res) => {
  try {
    const { studentId, classBatchId } = req.body;

    // Validate input
    if (!studentId || !classBatchId) {
      return res.status(400).json({ error: 'Student ID and ClassBatch ID are required' });
    }

    // Fetch the classBatch and student
    const classBatch = await ClassBatch.findById(classBatchId);
    const student = await Student.findById(studentId);

    if (!classBatch || !student) {
      return res.status(404).json({ error: 'Student or Class/Batch not found' });
    }

    // Check availability by comparing class strength to assigned students
    const availableSeats = classBatch.strength - classBatch.assignedStudents.length;

    if (availableSeats > 0) {
      // Assign student to classBatch
      student.classBatch = classBatchId;
      classBatch.assignedStudents.push(studentId);

      // Save updates
      await student.save();
      await classBatch.save();

      res.json({ message: 'Student assigned to class/batch successfully.' });
    } else {
      res.status(400).json({ message: 'No available seats in this class/batch.' });
    }
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Route to remove a student from a class/batch
router.post('/remove-class', async (req, res) => {
  try {
    const { studentId, classBatchId } = req.body;

    // Validate input
    if (!studentId || !classBatchId) {
      return res.status(400).json({ error: 'Student ID and ClassBatch ID are required' });
    }

    // Fetch the classBatch and student
    const classBatch = await ClassBatch.findById(classBatchId);
    const student = await Student.findById(studentId);

    if (!classBatch || !student) {
      return res.status(404).json({ error: 'Student or Class/Batch not found' });
    }

    // Remove student from classBatch
    student.classBatch = null;
    classBatch.assignedStudents = classBatch.assignedStudents.filter(
      (assignedStudentId) => assignedStudentId.toString() !== studentId
    );

    // Save updates
    await student.save();
    await classBatch.save();

    res.json({ message: 'Student removed from class/batch successfully.' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
