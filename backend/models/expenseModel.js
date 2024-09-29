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

module.exports = { Expense };  