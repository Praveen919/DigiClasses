const mongoose = require('mongoose');

// Schema for Expense
const expenseSchema = new mongoose.Schema({
  type: { type: String, required: true },
  paymentMode: { type: String, required: true },
  chequeNumber: { type: String },
  date: { type: Date, required: true },
  amount: { type: Number, required: true },
  remark: { type: String }
});

const Expense = mongoose.model('Expense', expenseSchema);

// Schema for Expense Type
const expenseTypeSchema = new mongoose.Schema({
  type: {
    type: String,
    required: true, 
    unique: true,    // Ensure types are unique
  },
});

const ExpenseType = mongoose.model('ExpenseType', expenseTypeSchema);

// Schema for Income
const incomeSchema = new mongoose.Schema({
  incomeType: { type: String, required: true },
  iPaymentType: { type: String, required: true },
  iChequeNumber: { type: String },
  bankName: { type: String },
  iDate: { type: Date, required: true },
  iAmount: { type: Number, required: true }
});

const Income = mongoose.model('Income', incomeSchema);

module.exports = { Expense, ExpenseType, Income };  