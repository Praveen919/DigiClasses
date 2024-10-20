// logbookRoutes.js
const express = require('express');
const router = express.Router();
const Logbook = require('../models/logbookTModel'); // Importing the logbook model

// Route to get logbook data for a specific month
router.get('/logbook', async (req, res) => {
  const { month } = req.query;

  if (!month) {
    return res.status(400).json({ error: 'Month is required to fetch logbook entries' });
  }

  try {
    const logbookEntries = await Logbook.find({ month });
    if (logbookEntries.length === 0) {
      return res.status(404).json({ message: 'No logbook entries found for the specified month' });
    }
    res.status(200).json(logbookEntries);
  } catch (error) {
    console.error('Error fetching logbook entries:', error);
    res.status(500).json({ error: 'Failed to fetch logbook entries' });
  }
});

// Route to save or update logbook entries
router.post('/logbook', async (req, res) => {
  const logbookData = req.body; // Array of logbook entries

  if (!logbookData || logbookData.length === 0) {
    return res.status(400).json({ error: 'Logbook data is required' });
  }

  const month = logbookData[0]?.month;
  if (!month) {
    return res.status(400).json({ error: 'Month is required in logbook data' });
  }

  try {
    // Remove existing entries for the same month to avoid duplicates
    await Logbook.deleteMany({ month });

    // Save the new logbook data
    const newLogbookEntries = await Logbook.insertMany(logbookData);
    res.status(200).json({ message: 'Logbook entries fetched successfully', data: logbookEntries });

  } catch (error) {
    console.error('Error saving logbook entries:', error);
    res.status(500).json({ error: 'Failed to save logbook entries' });
  }
});

module.exports = router;
