const mongoose = require('mongoose');
const express = require('express');
const router = express.Router();
const ClassBatch = require('../models/classBatchModel');
const StudentRegistration = require('../models/registrationModel');

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

router.post('/assign', async (req, res) => {
  const { studentId, fullName, classBatchId } = req.body;

  console.log('Assign Request Body:', req.body); // Log the incoming request body

  // Check if classBatchId is provided
  if (!classBatchId) {
    console.error('Missing classBatchId');
    return res.status(400).json({ message: 'Missing classBatchId' });
  }

  try {
    let student;

    // Validate the studentId format before querying
    if (studentId && !mongoose.Types.ObjectId.isValid(studentId)) {
      console.error('Invalid studentId format:', studentId);
      return res.status(400).json({ message: 'Invalid studentId format' });
    }

    // Fetch the student by studentId if provided
    if (studentId) {
      student = await StudentRegistration.findById(studentId); // Update this line
      console.log(`Fetching student with ID: ${studentId}`); // Log the attempt to fetch the student
    }
    // Otherwise, fetch by fullName if provided
    else if (fullName) {
      // Assuming `fullName` needs to be split into individual parts for matching
      const [firstName, lastName] = fullName.split(' '); // Adjust as necessary
      student = await StudentRegistration.findOne({ firstName, lastName }); // Update this line
      console.log(`Fetching student with fullName: ${fullName}`); // Log the attempt to fetch by name
    } else {
      console.error('Missing studentId or fullName');
      return res.status(400).json({ message: 'Missing studentId or fullName' });
    }

    // Check if student was found
    if (!student) {
      console.error(`Student not found. studentId: ${studentId}, fullName: ${fullName}`);
      return res.status(404).json({ message: 'Student not found' });
    }

    console.log('Fetched Student:', student); // Log the fetched student

    // Fetch the class batch directly using the provided ID
    const classBatch = await ClassBatch.findById(classBatchId);
    if (!classBatch) {
      console.error(`ClassBatch with ID ${classBatchId} not found`);
      return res.status(404).json({ message: `Class/Batch with ID ${classBatchId} not found` });
    }

    console.log('Fetched ClassBatch:', classBatch); // Log the fetched classBatch

    // Assign the class/batch to the student
    student.classBatch = classBatchId;
    await student.save();

    // Check if the student is already in assignedStudents
    if (!classBatch.assignedStudents.includes(student._id)) {
      classBatch.assignedStudents.push(student._id);
      await classBatch.save();
    }

    console.log(`Class/Batch assigned to student ${student.firstName} successfully.`); // Adjust to use firstName
    res.json({ message: `Class/Batch assigned to student ${student.firstName} successfully.` });
  } catch (error) {
    console.error('Error in assigning class/batch:', error); // Log error for debugging
    res.status(500).json({ message: 'Server Error', error });
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
    const student = await Student.findById(studentId);
    if (!student) {
      return res.status(404).json({ message: 'Student not found' });
    }

    // Check if the student is currently assigned to the specified class/batch
    if (!student.classBatch || student.classBatch.toString() !== classBatchId) {
      return res.status(400).json({ message: 'Student not assigned to this class/batch' });
    }

    // Remove the class/batch assignment
    student.classBatch = null;
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
