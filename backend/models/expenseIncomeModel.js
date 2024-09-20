const mongoose = require('mongoose');

// Schema for Expense
const expenseSchema = new mongoose.Schema({
  name: { type: String, required: true }, // Expense type
  paymentMode: { type: String, required: true },
  chequeNumber: { type: String, default: null }, // Nullable
  bankName: { type: String, default: null }, // Nullable
  date: { type: Date, required: true }, // Non-nullable now
  amount: { type: Number, required: true },
  remark: { type: String, default: null } // Nullable
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
