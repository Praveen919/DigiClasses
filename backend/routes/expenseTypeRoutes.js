const express = require('express');
const mongoose = require('mongoose');
const router = express.Router();
const { ExpenseType } = require('../models/expenseTypeModel'); // Ensure correct path

// Helper function to parse dates
const parseDate = (dateString) => {
  const [day, month, year] = dateString.split('/');
  return new Date(`${year}-${month}-${day}T00:00:00`); // Add T00:00:00 for proper ISO format
};

// Expense Type Routes
// Create a new expense type
router.post('/', async (req, res) => {
    console.log('Request Body:', req.body); // Log the incoming request body
    try {
      const { type } = req.body;
  
      if (!type) {
        return res.status(400).json({ error: 'Expense type is required' });
      }
  
      const newExpenseType = new ExpenseType({ type });
      await newExpenseType.save();
      res.status(201).json(newExpenseType);
    } catch (error) {
      if (error.name === 'ValidationError') {
        console.error('Validation error creating expense type:', error);
        return res.status(400).json({ error: 'Validation failed: ' + error.message });
      }
  
      console.error('Error creating expense type:', error);
      res.status(500).json({ error: 'Failed to create expense type' });
    }
  });
  
  
  // Get all expense types
  router.get('/', async (req, res) => {
    try {
      const expenseTypes = await ExpenseType.find();
      res.status(200).json(expenseTypes);
    } catch (error) {
      console.error('Error fetching expense types:', error);
      res.status(500).json({ error: 'Failed to fetch expense types' });
    }
  });
  
  // Update an expense type by ID
  router.put('/:id', async (req, res) => {
    try {
      const { id } = req.params;
  
      // Validate ObjectId
      if (!mongoose.Types.ObjectId.isValid(id)) {
        return res.status(400).json({ error: 'Invalid ID format' });
      }
  
      const { type } = req.body;
  
      const expenseType = await ExpenseType.findByIdAndUpdate(
        id,
        { type },
        { new: true, runValidators: true } // Return the updated document
      );
  
      if (!expenseType) {
        return res.status(404).json({ error: 'Expense type not found' });
      }
  
      res.status(200).json(expenseType);
    } catch (error) {
      console.error('Error updating expense type:', error);
      res.status(500).json({ error: 'Failed to update expense type' });
    }
  });  
  
  // Delete an expense type by ID
  router.delete('/:id', async (req, res) => {
    try {
      const expenseType = await ExpenseType.findByIdAndDelete(req.params.id);
      
      if (!expenseType) {
        return res.status(404).json({ error: 'Expense type not found' });
      }
  
      res.status(200).json({ message: 'Expense type deleted successfully' });
    } catch (error) {
      console.error('Error deleting expense type:', error);
      res.status(500).json({ error: 'Failed to delete expense type' });
    }
  });
  
  module.exports = router;
  