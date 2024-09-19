const express = require('express');
const router = express.Router();
const Year = require('../models/yearModel');

// Add a new Year
router.post('/add', async (req, res) => {
  try {
    const { yearName, fromDate, toDate, remarks } = req.body;

    // Create a new Year instance
    const newYear = new Year({
      yearName,
      fromDate,
      toDate,
      remarks,
    });

    // Save to the database
    await newYear.save();
    res.status(201).json({ message: 'Year added successfully!', year: newYear });
  } catch (error) {
    res.status(400).json({ message: 'Error adding year', error });
  }
});

// Get list of all Years
router.get('/list', async (req, res) => {
  try {
    const years = await Year.find(); // Fetch all years
    res.status(200).json(years);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching years', error });
  }
});

// Edit a Year by ID
router.put('/edit/:id', async (req, res) => {
  try {
    const { yearName, fromDate, toDate, remarks } = req.body;
    const year = await Year.findById(req.params.id);

    if (!year) {
      return res.status(404).json({ message: 'Year not found' });
    }

    // Update fields
    year.name = yearName || year.name;
    year.fromDate = fromDate || year.fromDate;
    year.toDate = toDate || year.toDate;
    year.remarks = remarks || year.remarks;

    // Save changes to database
    await year.save();
    res.status(200).json({ message: 'Year updated successfully!', year });
  } catch (error) {
    res.status(400).json({ message: 'Error updating year', error });
  }
});

// Delete a Year by ID
router.delete('/delete/:id', async (req, res) => {
  try {
    const year = await Year.findById(req.params.id);

    if (!year) {
      return res.status(404).json({ message: 'Year not found' });
    }

    // Delete the year
    await year.deleteOne();
    res.status(200).json({ message: 'Year deleted successfully!' });
  } catch (error) {
    res.status(400).json({ message: 'Error deleting year', error });
  }
});

module.exports = router;
