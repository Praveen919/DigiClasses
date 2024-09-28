const express = require('express');
const router = express.Router();
const Year = require('../models/yearModel');

// Utility function to parse date from dd/mm/yyyy
function parseDate(dateStr) {
  const parts = dateStr.split('/');
  if (parts.length !== 3) {
    throw new Error('Invalid date format');
  }
  const day = parseInt(parts[0], 10);
  const month = parseInt(parts[1], 10);
  const year = parseInt(parts[2], 10);
  if (isNaN(day) || isNaN(month) || isNaN(year) || month < 1 || month > 12 || day < 1 || day > 31) {
    throw new Error('Invalid date');
  }
  return new Date(year, month - 1, day); // Months are 0-based
}

// Add a new Year
router.post('/add', async (req, res) => {
  try {
    const { yearName, fromDate, toDate, remarks } = req.body;

    // Check if the required fields are provided
    if (!yearName || !fromDate || !toDate) {
      return res.status(400).json({ message: 'Year name, from date, and to date are required.' });
    }

    const parsedFromDate = parseDate(fromDate);
    const parsedToDate = parseDate(toDate);

    // Check for existing Year with the same name
    const existingYear = await Year.findOne({ yearName });

    if (existingYear) {
      return res.status(400).json({ message: 'A year with the same name already exists.' });
    }

    // Create a new Year instance
    const newYear = new Year({
      yearName,
      fromDate: parsedFromDate,
      toDate: parsedToDate,
      remarks,
    });

    // Save to the database
    await newYear.save();
    res.status(201).json({ message: 'Year added successfully!', year: newYear });
  } catch (error) {
    res.status(400).json({ message: 'Error adding year', error: error.message });
  }
});

// Route to check if a year with the same name exists
router.get('/check', async (req, res) => {
  const { yearName } = req.query;

  // Check if the year with the same name already exists
  const existingYear = await Year.findOne({ yearName });

  if (existingYear) {
    return res.json({ exists: true });
  }

  return res.json({ exists: false });
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

    // Parse the dates
    const parsedFromDate = fromDate ? parseDate(fromDate) : year.fromDate;
    const parsedToDate = toDate ? parseDate(toDate) : year.toDate;

    // Check for existing Year with the same name (excluding the current year being edited)
    const existingYear = await Year.findOne({
      _id: { $ne: year._id }, // Exclude the current year being edited
      yearName,
    });

    if (existingYear) {
      return res.status(400).json({ message: 'A year with the same name already exists.' });
    }

    // Update fields
    year.yearName = yearName || year.yearName;
    year.fromDate = parsedFromDate;
    year.toDate = parsedToDate;
    year.remarks = remarks || year.remarks;

    // Save changes to database
    await year.save();
    res.status(200).json({ message: 'Year updated successfully!', year });
  } catch (error) {
    res.status(400).json({ message: 'Error updating year', error: error.message });
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
    res.status(400).json({ message: 'Error deleting year', error: error.message });
  }
});

module.exports = router;
