const express = require('express');
const router = express.Router();
const TimeTable = require('../models/manageTimeTableModel');

// Get timetable
router.get('/', async (req, res) => {
  try {
    const { standard, batch } = req.query;
    const timetable = await TimeTable.findOne({ standard, batch: batch.toLowerCase() }); // Convert batch to lowercase
    if (timetable) {
      res.json(timetable.timetable);
    } else {
      res.status(404).json({ message: 'Timetable not found' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Update or create timetable
router.put('/update', async (req, res) => {
  try {
    const { standard, batch, timetable } = req.body;

    const formattedTimetable = [];
    for (let i = 0; i < 5; i++) { // 5 time slots
      const lectures = [];
      for (let day = 0; day < 6; day++) { // 6 days
        lectures.push({ day, subject: timetable[i][day] !== undefined ? timetable[i][day] : null }); // Allow for null
      }
      formattedTimetable.push({ time: `Time Slot ${i + 1}`, lectures });
    }

    const result = await TimeTable.findOneAndUpdate(
      { standard, batch: batch.toLowerCase() },
      { timetable: formattedTimetable },
      { new: true, upsert: true }
    );
    res.json(result);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});


// Create new timetable
router.post('/create', async (req, res) => {
  try {
    const { standard, batch, timetable } = req.body;

    const existingTimetable = await TimeTable.findOne({ standard, batch: batch.toLowerCase() });
    if (existingTimetable) {
      return res.status(400).json({ message: 'Timetable already exists' });
    }

    const formattedTimetable = [];
    for (let i = 0; i < 5; i++) { // 5 time slots
      const lectures = [];
      for (let day = 0; day < 6; day++) { // 6 days
        lectures.push({ day, subject: timetable[i][day] !== undefined ? timetable[i][day] : null }); // Allow for null
      }
      formattedTimetable.push({ time: `Time Slot ${i + 1}`, lectures });
    }

    const newTimeTable = new TimeTable({
      standard,
      batch: batch.toLowerCase(),
      timetable: formattedTimetable,
    });

    await newTimeTable.save();
    res.status(201).json(newTimeTable);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});


// Delete timetable
router.delete('/delete', async (req, res) => {
  try {
    const { standard, batch } = req.query;
    console.log(`Deleting timetable for Standard: ${standard}, Batch: ${batch}`); // Log for debugging

    const result = await TimeTable.deleteOne({ standard, batch: batch.toLowerCase() });
    console.log(`Delete Result:`, result); // Log the result of the deletion

    if (result.deletedCount === 1) {
      res.status(200).json({ message: 'Timetable deleted successfully' });
    } else {
      res.status(404).json({ message: 'Timetable not found' });
    }
  } catch (error) {
    console.error(error); // Log the error for debugging
    res.status(500).json({ message: error.message });
  }
});


module.exports = router;
