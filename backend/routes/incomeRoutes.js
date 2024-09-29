const express = require('express');
const mongoose = require('mongoose');
const router = express.Router();
const { Income } = require('../models/incomeModel'); // Ensure correct path

// Helper function to parse dates
const parseDate = (dateString) => {
    const [day, month, year] = dateString.split('/');
    return new Date(`${year}-${month}-${day}T00:00:00`); // Add T00:00:00 for proper ISO format
};

// Income Routes
// Create a new income
router.post('/', async (req, res) => {
    try {
      const { incomeType, iPaymentType, iChequeNumber, bankName, iDate, iAmount } = req.body;
  
      // Validate the required fields
      if (!incomeType || !iPaymentType || !iDate || !iAmount) {
        return res.status(400).json({ error: 'Required fields are missing' });
      }
  
      // Convert iDate to Date object and validate
      const date = new Date(iDate);
      if (isNaN(date.getTime())) {
        return res.status(400).json({ error: 'Invalid date format' });
      }
  
      const income = new Income({
        incomeType,
        iPaymentType,
        iChequeNumber,
        bankName,
        iDate: date, // Store as a Date object
        iAmount
      });
  
      await income.save();
      res.status(201).json(income);
    } catch (error) {
      console.error('Error saving income:', error);
      res.status(400).json({ error: 'Failed to save income' });
    }
  });
  
  // Get all incomes
  router.get('/', async (req, res) => {
    try {
      const incomes = await Income.find();
      res.status(200).json(incomes);
    } catch (error) {
      console.error('Error fetching incomes:', error);
      res.status(500).json({ error: 'Failed to retrieve incomes' });
    }
  });
  
  // Get a single income by ID
  router.get('/:id', async (req, res) => {
    try {
      const income = await Income.findById(req.params.id);
      if (!income) {
        return res.status(404).json({ error: 'Income not found' });
      }
      res.status(200).json(income);
    } catch (error) {
      console.error('Error retrieving income:', error);
      res.status(500).json({ error: 'Failed to retrieve income' });
    }
  });
  
  // Update an income by ID
  router.patch('/:id', async (req, res) => {
    try {
      const income = await Income.findByIdAndUpdate(req.params.id, req.body, { new: true, runValidators: true });
      if (!income) {
        return res.status(404).json({ error: 'Income not found' });
      }
      res.status(200).json(income);
    } catch (error) {
      console.error('Error updating income:', error.message);
      res.status(400).json({ error: 'Failed to update income' });
    }
  });
  
  // Delete an income by ID
  router.delete('/:id', async (req, res) => {
    try {
      const income = await Income.findByIdAndDelete(req.params.id);
      if (!income) {
        return res.status(404).json({ error: 'Income not found' });
      }
      res.status(200).json({ message: 'Income deleted successfully', income });
    } catch (error) {
      console.error('Error deleting income:', error.message);
      res.status(500).json({ error: 'Failed to delete income' });
    }
  });
  
  module.exports = router;
  