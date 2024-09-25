// logbookRoutes.js

const express = require('express');
const Logbook = require('./logbookModel'); // Importing the logbook model
const router = express.Router();

// Route to get logbook data for a specific month
router.get('/logbook', async (req, res) => {
  const { month } = req.query;
  
  try {
    const logbookEntries = await Logbook.find({ month });
    res.status(200).json(logbookEntries);
  } catch (error) {
    console.error('Error fetching logbook entries:', error);
    res.status(500).json({ error: 'Failed to fetch logbook entries' });
  }
});

// Route to save or update logbook entries
router.post('/logbook', async (req, res) => {
  const logbookData = req.body; // Array of logbook entries

  try {
    // Remove existing entries for the same month to avoid duplicates
    const month = logbookData[0]?.month;
    if (month) {
      await Logbook.deleteMany({ month });
    }

    // Save the new logbook data
    const newLogbookEntries = await Logbook.insertMany(logbookData);
    res.status(200).json({ message: 'Logbook saved successfully', data: newLogbookEntries });
  } catch (error) {
    console.error('Error saving logbook entries:', error);
    res.status(500).json({ error: 'Failed to save logbook entries' });
  }
});

module.exports = router;
