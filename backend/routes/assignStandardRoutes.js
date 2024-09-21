// assignedStandardRoutes.js

const express = require('express');
const router = express.Router();
const AssignedStandard = require('../models/assignStandardModel');

// Save Assigned Standards
router.post('/assign', async (req, res) => {
  try {
    const { standards } = req.body;

    const newAssignment = new AssignedStandard({
      standards
    });

    await newAssignment.save();
    res.status(201).json({ message: 'Standards assigned successfully!', data: newAssignment });
  } catch (error) {
    res.status(500).json({ message: 'Error assigning standards', error });
  }
});

module.exports = router;
