const express = require('express');
const AssignedSubject = require('../models/assignSubjectModel'); // Adjust the path if necessary
const router = express.Router();

// Fetch already assigned subjects
router.get('/alreadyAssigned', async (req, res) => {
  try {
    const assignedSubjects = await AssignedSubject.find();
    res.status(200).json({ subjects: assignedSubjects.flatMap(doc => doc.assignedSubjects) });
  } catch (error) {
    res.status(500).json({ message: 'Error fetching assigned subjects', error: error.message });
  }
});

// Assign subjects
router.post('/assign', async (req, res) => {
  const { assignedSubjects, otherRequirements } = req.body;

  if (!assignedSubjects || assignedSubjects.length === 0) {
    return res.status(400).json({ message: 'Assigned subjects are required' });
  }

  try {
    // Create or update the assigned subjects in the database
    let existingEntry = await AssignedSubject.findOne();
    if (existingEntry) {
      // If entry exists, update it
      existingEntry.assignedSubjects = [...new Set([...existingEntry.assignedSubjects, ...assignedSubjects])];
      existingEntry.otherRequirements = otherRequirements;
      await existingEntry.save();
    } else {
      // Create a new entry
      const newAssignment = new AssignedSubject({ assignedSubjects, otherRequirements });
      await newAssignment.save();
    }

    res.status(200).json({ message: 'Subjects assigned successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Failed to assign subjects', error: error.message });
  }
});

// Remove subjects
router.post('/remove', async (req, res) => {
  const { subjectsToRemove } = req.body;

  if (!subjectsToRemove || subjectsToRemove.length === 0) {
    return res.status(400).json({ message: 'No subjects to remove' });
  }

  try {
    let existingEntry = await AssignedSubject.findOne();

    if (!existingEntry) {
      return res.status(400).json({ message: 'No subjects assigned yet.' });
    }

    const subjectsNotAssigned = subjectsToRemove.filter(subject => !existingEntry.assignedSubjects.includes(subject));

    if (subjectsNotAssigned.length > 0) {
      // Directly respond with the message for unassigned subjects
      for (const subject of subjectsNotAssigned) {
        res.status(200).json({ message: `Subject not assigned: ${subject}` });
      }
      return; // Exit after sending messages
    }

    existingEntry.assignedSubjects = existingEntry.assignedSubjects.filter(subject => !subjectsToRemove.includes(subject));
    await existingEntry.save();

    res.status(200).json({ message: 'Assigned subjects removed successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Failed to remove assigned subjects', error: error.message });
  }
});

module.exports = router;
