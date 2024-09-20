// routes/studentRights.js
const express = require('express');
const router = express.Router();
const StudentRights = require('../models/studentRightsModel');

// API to assign or update rights for a specific role (e.g., Student)
router.post('/assign-rights', async (req, res) => {
  try {
    const { role, rights } = req.body;

    // Check if the role already exists, then update rights, otherwise create new
    let studentRights = await StudentRights.findOne({ role });

    if (studentRights) {
      // Update existing rights
      studentRights.rights = rights;
      await studentRights.save();
    } else {
      // Create new entry for the role
      studentRights = new StudentRights({ role, rights });
      await studentRights.save();
    }

    res.status(200).json({ message: 'Rights assigned successfully' });
  } catch (error) {
    console.error('Error assigning rights:', error);
    res.status(500).json({ message: 'Failed to assign rights' });
  }
});

module.exports = router;
