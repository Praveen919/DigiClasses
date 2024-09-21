const express = require('express');
const router = express.Router();
const TimeTable = require('../models/manageTimeTableModel');

// Get timetable
router.get('/timetable', async (req, res) => {
  try {
    const { standard, batch } = req.query;
    const timetable = await TimeTable.findOne({ standard, batch });
    if (timetable) {
      res.json(timetable.timetable);
    } else {
      res.status(404).json({ message: 'Timetable not found' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Update timetable
router.put('/timetable/update', async (req, res) => {
  try {
    const { standard, batch, timetable } = req.body;
    const result = await TimeTable.findOneAndUpdate(
      { standard, batch },
      { timetable },
      { new: true, upsert: true }
    );
    res.json(result);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
