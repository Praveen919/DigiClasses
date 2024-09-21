const mongoose = require('mongoose');

// Schema for Expense
const expenseSchema = new mongoose.Schema({
  type: { type: String, required: true },
  paymentMode: { type: String },
  chequeNumber: { type: String },
  bankName: { type: String },
  date: { type: Date },
  amount: { type: Number, required: true },
  remark: { type: String }
});

const Expense = mongoose.model('Expense', expenseSchema);

// Schema for Income
const incomeSchema = new mongoose.Schema({
  type: { type: String, required: true },
  paymentType: { type: String },
  chequeNumber: { type: String },
  bankName: { type: String },
  date: { type: Date },
  amount: { type: Number, required: true }
});

const Income = mongoose.model('Income', incomeSchema);

module.exports = { Expense, Income };
