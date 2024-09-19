const express = require('express');
const router = express.Router();
const Subject = require('../models/assignSubjectModel');  // Assuming you have a Subject model

// POST request to assign a subject
router.post('/', async (req, res) => {
  try {
    const { subjects } = req.body;

    // Logic to save the assigned subjects
    const newAssignment = new Subject({ assignedSubjects: subjects });
    await newAssignment.save();

    res.status(201).json({ message: 'Subjects assigned successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to assign subjects' });
  }
});

module.exports = router;
