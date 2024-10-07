const mongoose = require('mongoose');
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
    console.error('Error fetching classes:', error); // Log the error for debugging
    res.status(500).json({ message: 'Server Error' });
  }
});

// Assign a class/batch to a student by full name
router.post('/assign', async (req, res) => {
  const { fullName, classBatchId } = req.body;

  console.log('Assign Request Body:', req.body); // Log the incoming request body

  try {
    // Split the full name into parts (assuming the format is firstName, middleName, lastName)
    const nameParts = fullName.trim().split(' ');
    const firstName = nameParts[0] || '';
    const middleName = nameParts.length > 2 ? nameParts.slice(1, -1).join(' ') : '';
    const lastName = nameParts[nameParts.length - 1] || '';

    // Fetch the student by their full name (first name, middle name, last name)
    const student = await Student.findOne({
      firstName: firstName,
      middleName: middleName,
      lastName: lastName
    });

    console.log('Fetched Student:', student); // Log the fetched student

    if (!student) {
      console.error(`Student with name ${fullName} not found`); // More specific logging
      return res.status(404).json({ message: 'Student not found' });
    }

    // Fetch the class batch directly using the provided ID
    const classBatch = await ClassBatch.findById(classBatchId); 
    console.log('Fetched ClassBatch:', classBatch); // Log the fetched classBatch

    if (!classBatch) {
      console.error(`ClassBatch with ID ${classBatchId} not found`); // More specific logging
      return res.status(404).json({ message: 'Class/Batch not found' });
    }

    // Update the student's class/batch assignment
    student.classBatch = classBatchId;
    await student.save();

    // Check if the student is already in assignedStudents
    if (!classBatch.assignedStudents.includes(student._id)) {
      classBatch.assignedStudents.push(student._id);
      await classBatch.save();
    }

    res.json({ message: 'Class/Batch assigned to student successfully' });
  } catch (error) {
    console.error('Error in assigning class/batch:', error); // Log error for debugging
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
    console.error('Error fetching students:', error); // Log the error for debugging
    res.status(500).json({ message: 'Server Error' });
  }
});

// Remove a student from a class/batch
router.post('/remove', async (req, res) => {
  const { studentId, classBatchId } = req.body;

  try {
    const student = await Student.findById(studentId); // no need for mongoose.Types.ObjectId
    if (!student) {
      return res.status(404).json({ message: 'Student not found' });
    }

    // Check if the student is currently assigned to the specified class/batch
    if (!student.classBatch || student.classBatch.toString() !== classBatchId) {
      return res.status(400).json({ message: 'Student not assigned to this class/batch' });
    }

    // Remove the class/batch assignment
    student.classBatch = null; // or any value indicating no assignment
    await student.save();

    // Remove the studentId from the assignedStudents array
    const classBatch = await ClassBatch.findById(classBatchId);
    if (classBatch) {
      classBatch.assignedStudents.pull(studentId); // Remove studentId from assignedStudents
      await classBatch.save();
    }

    res.json({ message: 'Student removed from class/batch successfully' });
  } catch (error) {
    console.error('Error in removing student from class/batch:', error); // Log error for debugging
    res.status(500).json({ message: 'Server Error' });
  }
});

module.exports = router;
