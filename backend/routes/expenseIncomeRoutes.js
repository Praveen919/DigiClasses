const express = require('express');
const mongoose = require('mongoose');
const router = express.Router();
const { Expense, Income } = require('../models/expenseIncomeModel'); // Ensure correct path

  // Expense Routes
  // Create a new expense
  router.post('/', async (req, res) => {
    try {
      const { name, paymentMode, chequeNo, date, amount, remark } = req.body;
  
      if (!name || !paymentMode || !date || !amount) {
        return res.status(400).json({ error: 'Required fields are missing' });
      }
  
      // Function to format date as yyyy/mm/dd
      const formatDate = (date) => {
        const d = new Date(date);
        const year = d.getFullYear();
        const month = `${d.getMonth() + 1}`.padStart(2, '0');
        const day = `${d.getDate()}`.padStart(2, '0');
        return `${year}/${month}/${day}`;
      };
  
      // Prepare expense data
      const expenseData = {
        name: name,
        paymentMode: paymentMode,
        chequeNumber: chequeNo,
        date: new Date(date), 
        amount: parseFloat(amount),
        remark: remark,
      };
  
      const expense = new Expense(expenseData);
      await expense.save();
      res.status(201).json(expense);
    } catch (error) {
      console.error('Error saving expense:', error);
      res.status(500).json({ error: 'Failed to save expense' });
    }
  });
  
  // Get all expenses
  router.get('/', async (req, res) => {
    try {
      const expenses = await Expense.find();
      
      // Format date when returning the data
      const formattedExpenses = expenses.map((expense) => ({
        ...expense._doc,
        date: formatDate(expense.date),
      }));
  
      res.status(200).json(formattedExpenses);
    } catch (error) {
      console.error('Error fetching expenses:', error);
      res.status(500).json({ error: 'Failed to fetch expenses' });
    }
  });


  // Get a single expense by ID
  router.get('/:id', async (req, res) => {
    try {
      const expense = await Expense.findById(req.params.id);
      if (!expense) {
        return res.status(404).json({ error: 'Expense not found' });
      }
      res.status(200).json(expense);
    } catch (error) {
      res.status(500).json({ error: 'Failed to retrieve expense' });
    }
  });

  // Update an expense by ID
  router.patch('/:id', async (req, res) => {
    try {
      const expense = await Expense.findByIdAndUpdate(req.params.id, req.body, { new: true, runValidators: true });
      if (!expense) {
        return res.status(404).json({ error: 'Expense not found' });
      }
      res.status(200).json(expense);
    } catch (error) {
      console.error('Error updating expense:', error.message);
      res.status(500).json({ error: 'Failed to update expense' });
    }
  });
  
  // Delete an expense by ID
  router.delete('/:id', async (req, res) => {
    try {
      const expense = await Expense.findByIdAndDelete(req.params.id);
      if (!expense) {
        return res.status(404).json({ error: 'Expense not found' });
      }
      res.status(200).json({ message: 'Expense deleted successfully' });
    } catch (error) {
      console.error('Error deleting expense:', error.message);
      res.status(500).json({ error: 'Failed to delete expense' });
    }
  });

  // Income Routes
  // Create a new income
  router.post('/incomes', async (req, res) => {
    try {
      const income = new Income(req.body);
      await income.save();
      res.status(201).json(income);
    } catch (error) {
      console.error('Error saving income:', error);
      res.status(400).json({ error: 'Failed to save income' });
    }
  });

  // Get all incomes
  router.get('/incomes', async (req, res) => {
    try {
      const incomes = await Income.find();
      res.status(200).json(incomes);
    } catch (error) {
      res.status(500).json({ error: 'Failed to retrieve incomes' });
    }
  });

  // Get a single income by ID
  router.get('/incomes/:id', async (req, res) => {
    try {
      const income = await Income.findById(req.params.id);
      if (!income) {
        return res.status(404).json({ error: 'Income not found' });
      }
      res.status(200).json(income);
    } catch (error) {
      res.status(500).json({ error: 'Failed to retrieve income' });
    }
  });

  // Update an income by ID
  router.patch('/incomes/:id', async (req, res) => {
    try {
      const income = await Income.findByIdAndUpdate(req.params.id, req.body, { new: true, runValidators: true });
      if (!income) {
        return res.status(404).json({ error: 'Income not found' });
      }
      res.status(200).json(income);
    } catch (error) {
      res.status(400).json({ error: 'Failed to update income' });
    }
  });

  // Delete an income by ID
  router.delete('/incomes/:id', async (req, res) => {
    try {
      const income = await Income.findByIdAndDelete(req.params.id);
      if (!income) {
        return res.status(404).json({ error: 'Income not found' });
      }
      res.status(200).json(income);
    } catch (error) {
      res.status(500).json({ error: 'Failed to delete income' });
    }
  });

  module.exports = router;
