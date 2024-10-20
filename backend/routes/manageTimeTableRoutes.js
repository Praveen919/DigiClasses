const express = require('express');
const router = express.Router();
const TimeTable = require('../models/manageTimeTableModel');

// Constants
const NUM_TIME_SLOTS = 5; // 5 time slots
const NUM_DAYS = 6; // 6 days

// Get timetable
router.get('/', async (req, res) => {
  try {
    const { standard, batch } = req.query;
    const timetable = await TimeTable.findOne({ standard, batch: batch.toLowerCase() });
    
    if (timetable && timetable.timetable.length > 0) {
      res.json(timetable.timetable);
    } else if (timetable && timetable.timetable.length === 0) {
      res.json({ message: 'Timetable is currently empty' });
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

    if (!standard || !batch || !timetable) {
      return res.status(400).json({ message: 'Missing standard, batch, or timetable' });
    }

    // Ensure the timetable format is valid and filter out empty subjects
    const formattedTimetable = timetable.map((timeSlot) => ({
      time: timeSlot.time || `Time Slot ${timeSlot}`, // Use provided time or fallback
      lectures: timeSlot.lectures
        .filter((lecture) => lecture.subject && lecture.subject.trim()) // Filter empty subjects
        .map((lecture) => ({
          day: lecture.day,
          subject: lecture.subject.trim(), // Trim whitespace
        })),
    }));

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
    const { standard, batch } = req.body;

    // Initialize an empty timetable with null values
    const emptyTimetable = Array.from({ length: NUM_TIME_SLOTS }, () =>
      Array(NUM_DAYS).fill(null)
    );

    const existingTimetable = await TimeTable.findOne({ standard, batch: batch.toLowerCase() });
    if (existingTimetable) {
      return res.status(400).json({ message: 'Timetable already exists' });
    }

    const formattedTimetable = [];
    for (let i = 0; i < NUM_TIME_SLOTS; i++) {
      const lectures = [];
      for (let day = 0; day < NUM_DAYS; day++) {
        lectures.push({ day, subject: emptyTimetable[i][day] }); // Initialize as null
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
