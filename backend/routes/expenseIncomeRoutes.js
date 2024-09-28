const express = require('express');
const mongoose = require('mongoose');
const router = express.Router();
const { Expense, ExpenseType, Income } = require('../models/expenseIncomeModel'); // Ensure correct path

// Helper function to parse dates
const parseDate = (dateString) => {
  const [day, month, year] = dateString.split('/');
  return new Date(`${year}-${month}-${day}T00:00:00`); // Add T00:00:00 for proper ISO format
};

// Expense Routes
// Create a new expense
router.post('/', async (req, res) => {
  try {
    const { type, paymentMode, chequeNumber, date, amount, remark } = req.body;

    // Check for required fields
    if (!type || !paymentMode || !date || !amount) {
      return res.status(400).json({ error: 'Required fields are missing' });
    }

    const parsedDate = new Date(date);

    if (isNaN(parsedDate.getTime())) {
      return res.status(400).json({ error: 'Invalid date format' });
    }

    const expenseData = {
      type,
      paymentMode,
      chequeNumber: chequeNumber || null, // Change from chequeNo to chequeNumber
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
    const { type, paymentMode, chequeNumber, date, amount, remark } = req.body;

    const parsedDate = new Date(date);

    if (isNaN(parsedDate.getTime())) {
      return res.status(400).json({ error: 'Invalid date format' });
    }

    const expense = await Expense.findByIdAndUpdate(req.params.id, {
      type, // Match with schema
      paymentMode,
      chequeNumber: chequeNumber || null,
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
router.patch('/expense-types/:id', async (req, res) => {
  try {
    const { type } = req.body;
    const expenseType = await ExpenseType.findByIdAndUpdate(
      req.params.id,
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
router.delete('/expense-types/:id', async (req, res) => {
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
