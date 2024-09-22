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
      assignedStandards.standards = [...new Set([...assignedStandards.standards, ...standards])];
    } else {
      // Create a new record if none exists
      assignedStandards = new AssignedStandard({
        standards: [...new Set(standards)], // Avoid duplicates on creation as well
      });
    }

    // Sort the standards after updating
    assignedStandards.standards = sortStandards(assignedStandards.standards);

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
      res.status(200).json({ message: 'Successfully fetched assigned standards', standards: assignedStandards.standards });
    } else {
      res.status(200).json({ message: 'No standards assigned yet', standards: [] });
    }
  } catch (error) {
    res.status(500).json({ message: 'Error fetching assigned standards', error });
  }
});

// Remove Specific Standards
router.post('/remove', async (req, res) => {
  try {
    const { standardsToRemove } = req.body;

    let assignedStandards = await AssignedStandard.findOne();

    if (assignedStandards) {
      const notAssigned = standardsToRemove.filter(standard => !assignedStandards.standards.includes(standard));
      
      if (notAssigned.length > 0) {
        return res.status(400).json({ message: 'Standards not assigned: ' + notAssigned.join(', ') });
      }

      // Remove specified standards from the array
      assignedStandards.standards = assignedStandards.standards.filter(
        standard => !standardsToRemove.includes(standard)
      );

      // Sort the standards after removal
      assignedStandards.standards = sortStandards(assignedStandards.standards);

      await assignedStandards.save();
      res.status(200).json({ message: 'Standards removed successfully', standards: assignedStandards.standards });
    } else {
      res.status(404).json({ message: 'No assigned standards found to remove' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Error removing standards', error });
  }
});

module.exports = router;
