const mongoose = require('mongoose');

// Schema for Expense Type
const expenseTypeSchema = new mongoose.Schema({
    type: {
      type: String, 
      unique: true,    // Ensure types are unique
    },
  });
  
  const ExpenseType = mongoose.model('ExpenseType', expenseTypeSchema);

module.exports = { ExpenseType };  