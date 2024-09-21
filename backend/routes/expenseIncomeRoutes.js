const express = require('express');
const mongoose = require('mongoose');
const router = express.Router();
const { Expense, Income } = require('../models/expenseIncomeModel'); // Ensure correct path

// Helper function to parse dates
const parseDate = (dateString) => {
  const [day, month, year] = dateString.split('/');
  return new Date(`${year}-${month}-${day}T00:00:00`); // Add T00:00:00 for proper ISO format
};

// Expense Routes
// Create a new expense
router.post('/', async (req, res) => {
  try {
    const { name, paymentMode, chequeNo, date, amount, remark } = req.body;

    if (!name || !paymentMode || !date || !amount) {
      return res.status(400).json({ error: 'Required fields are missing' });
    }

    const parsedDate = new Date(date);

    if (isNaN(parsedDate.getTime())) {
      return res.status(400).json({ error: 'Invalid date format' });
    }

    const expenseData = {
      name,
      paymentMode,
      chequeNumber: chequeNo || null,
      date: parsedDate,
      amount: parseFloat(amount),
      remark: remark || null,
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

    // Format date as dd/MM/yyyy for response
    const formatDate = (date) => {
      const parsedDate = new Date(date);
      const day = String(parsedDate.getDate()).padStart(2, '0');
      const month = String(parsedDate.getMonth() + 1).padStart(2, '0'); // getMonth is zero-based
      const year = parsedDate.getFullYear();
      return `${day}/${month}/${year}`;
    };

    const formattedExpenses = expenses.map(expense => ({
      ...expense._doc,
      chequeNumber: expense.chequeNumber ?? '',
      remark: expense.remark ?? '',
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
    console.error('Error retrieving expense:', error);
    res.status(500).json({ error: 'Failed to retrieve expense' });
  }
});

// Update an expense by ID
router.patch('/:id', async (req, res) => {
  try {
    const { name, paymentMode, chequeNo, date, amount, remark } = req.body;

    const parsedDate = parseDate(date);

    if (isNaN(parsedDate.getTime())) {
      return res.status(400).json({ error: 'Invalid date format' });
    }

    const expense = await Expense.findByIdAndUpdate(req.params.id, {
      name,
      paymentMode,
      chequeNumber: chequeNo || null,
      date: parsedDate,
      amount: parseFloat(amount),
      remark: remark || null,
    }, { new: true, runValidators: true });

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
router.post('/', async (req, res) => {
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
    res.status(200).json(income);
  } catch (error) {
    console.error('Error deleting income:', error.message);
    res.status(500).json({ error: 'Failed to delete income' });
  }
});

module.exports = router;
