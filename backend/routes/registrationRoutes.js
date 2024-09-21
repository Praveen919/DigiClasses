const express = require('express');
const multer = require('multer');
const path = require('path');
const StudentRegistration = require('../models/registrationModel');

const router = express.Router();

// Multer setup for image uploads
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, './uploads/'); // Store images in the "uploads" folder
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + path.extname(file.originalname)); // Set unique file name
  },
});

const upload = multer({ storage: storage });

// @route   POST /api/students
// @desc    Register a new student
router.post('/students', upload.single('profileImage'), async (req, res) => {
  const {
    firstName, middleName, lastName, fatherName, motherName, fatherMobile,
    motherMobile, studentMobile, studentEmail, address, state, city, school,
    university, classBatch, gender, standard, courseType, birthDate, joinDate, printInquiry
  } = req.body;

  try {
    const newStudent = new StudentRegistration({
      firstName,
      middleName,
      lastName,
      fatherName,
      motherName,
      fatherMobile,
      motherMobile,
      studentMobile,
      studentEmail,
      address,
      state,
      city,
      school,
      university,
      classBatch,
      gender,
      standard,
      courseType,
      birthDate: new Date(birthDate),
      joinDate: new Date(joinDate),
      profileImage: req.file ? req.file.path : null, // Save the file path
      printInquiry,
    });

    await newStudent.save();

    res.status(201).json({ message: 'Student registered successfully!' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error: Failed to register student' });
  }
});

// @route   GET /api/students
// @desc    Get all students
router.get('/students', async (req, res) => {
  try {
    const students = await StudentRegistration.find();
    res.status(200).json(students);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error: Failed to fetch students' });
  }
});

// @route   GET /api/students/:id
// @desc    Get a student by ID
router.get('/students/:id', async (req, res) => {
  try {
    const student = await StudentRegistration.findById(req.params.id);
    if (student) {
      res.status(200).json(student);
    } else {
      res.status(404).json({ error: 'Student not found' });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error: Failed to fetch student' });
  }
});

// @route   PUT /api/students/:id
// @desc    Update a student
router.put('/students/:id', upload.single('profileImage'), async (req, res) => {
  try {
    const updates = { ...req.body };
    if (req.file) {
      updates.profileImage = req.file.path;
    }

    const student = await StudentRegistration.findByIdAndUpdate(req.params.id, updates, { new: true });

    if (student) {
      res.status(200).json(student);
    } else {
      res.status(404).json({ error: 'Student not found' });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error: Failed to update student' });
  }
});

// @route   DELETE /api/students/:id
// @desc    Delete a student
router.delete('/students/:id', async (req, res) => {
  try {
    const student = await StudentRegistration.findByIdAndDelete(req.params.id);
    if (student) {
      res.status(200).json({ message: 'Student deleted successfully' });
    } else {
      res.status(404).json({ error: 'Student not found' });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error: Failed to delete student' });
  }
});

module.exports = router;
