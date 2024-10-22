const express = require('express');
const router = express.Router();
const AssignedStandard = require('../models/assignStandardModel');

// Helper function to sort standards
const sortStandards = (standards) => {
  return standards.sort((a, b) => {
    const numA = parseInt(a) || 0;
    const numB = parseInt(b) || 0;

    // Sort numerically first; if equal, sort alphabetically
    return numA - numB || a.localeCompare(b);
  });
};

// Save or Update Assigned Standards
router.post('/assign', async (req, res) => {
  try {
    const { standards } = req.body;

    // Check if there's already an existing entry for assigned standards
    let assignedStandards = await AssignedStandard.findOne();

    if (assignedStandards) {
      // Update the existing array by adding new standards (avoiding duplicates)
      assignedStandards.assignedStandards = [...new Set([...assignedStandards.assignedStandards, ...standards])];
    } else {
      // Create a new record if none exists
      assignedStandards = new AssignedStandard({
        assignedStandards: [...new Set(standards)], // Avoid duplicates on creation as well
      });
    }

    // Sort the standards after updating
    assignedStandards.assignedStandards = sortStandards(assignedStandards.assignedStandards);

    await assignedStandards.save();
    res.status(201).json({ message: 'Standards assigned successfully!', data: assignedStandards });
  } catch (error) {
    res.status(500).json({ message: 'Error assigning standards', error });
  }
});

// Fetch Already Assigned Standards
router.get('/alreadyAssigned', async (req, res) => {
  try {
    const assignedStandards = await AssignedStandard.findOne();

    if (assignedStandards) {
      res.status(200).json({
        message: 'Successfully fetched assigned standards',
        standards: assignedStandards.assignedStandards,  // Fix here
      });
    } else {
      res.status(200).json({ message: 'No standards assigned yet', standards: [] });
    }
  } catch (error) {
    res.status(500).json({ message: 'Error fetching assigned standards', error });
  }
});

// Remove specific standards
router.post('/remove', async (req, res) => {
  try {
    const { standardsToRemove } = req.body;

    if (!standardsToRemove || !Array.isArray(standardsToRemove)) {
      return res.status(400).json({ message: 'Invalid input: standardsToRemove should be an array' });
    }

    let assignedStandards = await AssignedStandard.findOne();

    if (assignedStandards) {
      const notAssigned = standardsToRemove.filter(standard => !assignedStandards.assignedStandards.includes(standard));  // Change to assignedStandards
      
      if (notAssigned.length > 0) {
        return res.status(400).json({ message: 'Standards not assigned: ' + notAssigned.join(', ') });
      }

      // Remove specified standards from the array
      assignedStandards.assignedStandards = assignedStandards.assignedStandards.filter(  // Change to assignedStandards
        standard => !standardsToRemove.includes(standard)
      );

      // Sort the standards after removal
      assignedStandards.assignedStandards = sortStandards(assignedStandards.assignedStandards);  // Change to assignedStandards

      await assignedStandards.save();
      res.status(200).json({ message: 'Standards removed successfully', standards: assignedStandards.assignedStandards });  // Change to assignedStandards
    } else {
      res.status(404).json({ message: 'No assigned standards found to remove' });
    }
  } catch (error) {
    console.error('Error removing standards:', error);  // Log the error for debugging
    res.status(500).json({ message: 'Error removing standards', error: error.message });
  }
});

module.exports = router;
