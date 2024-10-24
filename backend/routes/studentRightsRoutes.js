const express = require('express');
const router = express.Router();
const StudentRights = require('../models/studentRightsModel');

// API to assign or update rights for a specific role (e.g., Student)
router.post('/assign-rights', async (req, res) => {
  try {
    const { role, rights, action } = req.body; // Expecting an action parameter for add/remove

    // Check if the role already exists
    let studentRights = await StudentRights.findOne({ role });

    if (!studentRights) {
      // Create new entry for the role if it doesn't exist
      studentRights = new StudentRights({ role, rights: new Map() });
    }

    // Handle adding or removing rights based on the action
    if (action === 'add') {
      // Update existing rights with new ones
      for (const [key, value] of Object.entries(rights)) {
        studentRights.rights.set(key, value);
      }
    } else if (action === 'remove') {
      // Remove specified rights
      for (const right of rights) {
        studentRights.rights.delete(right);
      }
    }

    await studentRights.save();
    res.status(200).json({ message: 'Rights updated successfully' });
  } catch (error) {
    console.error('Error assigning rights:', error);
    res.status(500).json({ message: 'Failed to update rights' });
  }
});

module.exports = router;
