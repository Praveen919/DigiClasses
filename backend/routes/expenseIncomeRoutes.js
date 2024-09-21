<<<<<<< HEAD
const express = require('express');
const mongoose = require('mongoose');
const router = express.Router();
const { Expense, Income } = require('./expenseIncomeModel'); // Ensure correct path

// Expense Routes
// Create a new expense
router.post('/expenses', async (req, res) => {
  try {
    const expense = new Expense(req.body);
    await expense.save();
    res.status(201).json(expense);
  } catch (error) {
    console.error('Error saving expense:', error);
    res.status(400).json({ error: 'Failed to save expense' });
  }
});

// Get all expenses
router.get('/expenses', async (req, res) => {
  try {
    const expenses = await Expense.find();
    res.status(200).json(expenses);
  } catch (error) {
    console.error('Error retrieving expenses:', error);
    res.status(500).json({ error: 'Failed to retrieve expenses' });
  }
});

// Get a single expense by ID
router.get('/expenses/:id', async (req, res) => {
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
router.patch('/expenses/:id', async (req, res) => {
  try {
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({ error: 'Invalid ID format' });
    }

    const updateData = req.body;
    const expense = await Expense.findByIdAndUpdate(req.params.id, updateData, { new: true, runValidators: true });

    if (!expense) {
      return res.status(404).json({ error: 'Expense not found' });
    }

    res.status(200).json(expense);
  } catch (error) {
    console.error('Error updating expense:', error);
    res.status(400).json({ error: 'Failed to update expense' });
  }
});

// Delete an expense by ID
router.delete('/expenses/:id', async (req, res) => {
  try {
    const expense = await Expense.findByIdAndDelete(req.params.id);
    if (!expense) {
      return res.status(404).json({ error: 'Expense not found' });
    }
    res.status(200).json(expense);
  } catch (error) {
    console.error('Error deleting expense:', error);
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
    console.error('Error retrieving incomes:', error);
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
    console.error('Error retrieving income:', error);
    res.status(500).json({ error: 'Failed to retrieve income' });
  }
});

// Update an income by ID
router.patch('/incomes/:id', async (req, res) => {
  try {
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({ error: 'Invalid ID format' });
    }

    const updateData = req.body;
    const income = await Income.findByIdAndUpdate(req.params.id, updateData, { new: true, runValidators: true });

    if (!income) {
      return res.status(404).json({ error: 'Income not found' });
    }

    res.status(200).json(income);
  } catch (error) {
    console.error('Error updating income:', error);
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
    console.error('Error deleting income:', error);
    res.status(500).json({ error: 'Failed to delete income' });
  }
});

// Get Profit and Loss
router.get('/profit-loss', async (req, res) => {
  try {
    const totalExpenses = await Expense.aggregate([{ $group: { _id: null, total: { $sum: '$amount' } } }]);
    const totalIncomes = await Income.aggregate([{ $group: { _id: null, total: { $sum: '$amount' } } }]);

    const profitAmount = totalIncomes[0]?.total || 0;
    const lossAmount = totalExpenses[0]?.total || 0;

    res.status(200).json({
      profitAmount,
      lossAmount,
      netProfit: profitAmount - lossAmount,
    });
  } catch (error) {
    console.error('Error calculating profit and loss:', error);
    res.status(500).json({ error: 'Failed to calculate profit and loss' });
  }
});

module.exports = router;
=======
const express = require('express');
const mongoose = require('mongoose');
const router = express.Router();
const { Expense, Income } = require('./expenseIncomeModel'); // Ensure correct path

// Expense Routes
// Create a new expense
router.post('/expenses', async (req, res) => {
  try {
    const expense = new Expense(req.body);
    await expense.save();
    res.status(201).json(expense);
  } catch (error) {
    console.error('Error saving expense:', error);
    res.status(400).json({ error: 'Failed to save expense' });
  }
});

// Get all expenses
router.get('/expenses', async (req, res) => {
  try {
    const expenses = await Expense.find();
    res.status(200).json(expenses);
  } catch (error) {
    console.error('Error retrieving expenses:', error);
    res.status(500).json({ error: 'Failed to retrieve expenses' });
  }
});

// Get a single expense by ID
router.get('/expenses/:id', async (req, res) => {
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
router.patch('/expenses/:id', async (req, res) => {
  try {
    // Validate the ID format
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({ error: 'Invalid ID format' });
    }

    // Extract fields from request body
    const updateData = req.body;

    // Find and update the expense
    const expense = await Expense.findByIdAndUpdate(req.params.id, updateData, { new: true, runValidators: true });

    // Check if expense exists
    if (!expense) {
      return res.status(404).json({ error: 'Expense not found' });
    }

    // Respond with the updated expense
    res.status(200).json(expense);
  } catch (error) {
    console.error('Error updating expense:', error);
    res.status(400).json({ error: 'Failed to update expense' });
  }
});

// Delete an expense by ID
router.delete('/expenses/:id', async (req, res) => {
  try {
    const expense = await Expense.findByIdAndDelete(req.params.id);
    if (!expense) {
      return res.status(404).json({ error: 'Expense not found' });
    }
    res.status(200).json(expense);
  } catch (error) {
    console.error('Error deleting expense:', error);
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
    console.error('Error retrieving incomes:', error);
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
    console.error('Error retrieving income:', error);
    res.status(500).json({ error: 'Failed to retrieve income' });
  }
});

// Update an income by ID
router.patch('/incomes/:id', async (req, res) => {
  try {
    // Validate the ID format
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({ error: 'Invalid ID format' });
    }

    // Extract fields from request body
    const updateData = req.body;

    // Find and update the income
    const income = await Income.findByIdAndUpdate(req.params.id, updateData, { new: true, runValidators: true });

    // Check if income exists
    if (!income) {
      return res.status(404).json({ error: 'Income not found' });
    }

    // Respond with the updated income
    res.status(200).json(income);
  } catch (error) {
    console.error('Error updating income:', error);
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
    console.error('Error deleting income:', error);
    res.status(500).json({ error: 'Failed to delete income' });
  }
});

module.exports = router;
>>>>>>> cc5af9e141bdcffd7728c0c772999721e41a5e89
