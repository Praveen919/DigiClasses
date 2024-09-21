// routes.js
const express = require('express');
const router = express.Router();
const FeeCollection = require('./feeCollectionModel'); // Import the model
const StudentRegistration = require('./registrationModel');
// Route to get all fee collection data or filter by date range
router.get('/fees', async (req, res) => {
  try {
    let { fromDate, toDate, searchQuery } = req.query;

    // Build the query object
    let query = {};

    if (fromDate && toDate) {
      query.date = {
        $gte: new Date(fromDate),
        $lte: new Date(toDate),
      };
    }

    if (searchQuery) {
      query.$or = [
        { name: new RegExp(searchQuery, 'i') },
        { std: new RegExp(searchQuery, 'i') },
        { batch: new RegExp(searchQuery, 'i') }
      ];
    }

    // Fetch the records based on query
    const fees = await FeeCollection.find(query);
    res.status(200).json(fees);
  } catch (error) {
    console.error('Error fetching fee data:', error);
    res.status(500).send('Internal Server Error');
  }
});

// Route to update multiple fee collection records
router.put('/fees', async (req, res) => {
  try {
    const updates = req.body; // The array of updated fee collection records

    for (let update of updates) {
      await FeeCollection.findByIdAndUpdate(update._id, update);
    }

    res.status(200).json({ message: 'Data updated successfully' });
  } catch (error) {
    console.error('Error updating data:', error);
    res.status(500).send('Internal Server Error');
  }
});

// Update student details based on _id
router.put('/updateStudent', async (req, res) => {
  try {
    const { _id, totalFees, discountedFees, amtPaid, date } = req.body;

    // Find the student by _id and update the fields
    const updatedStudent = await StudentRegistration.findByIdAndUpdate(
      _id,
      {
        totalFees,
        discountedFees,
        amtPaid,
        date
      },
      { new: true }
    );

    if (updatedStudent) {
      res.status(200).json({ message: 'Student data updated successfully', updatedStudent });
    } else {
      res.status(404).json({ message: 'Student not found' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Error updating student data', error });
  }
});

module.exports = router;
