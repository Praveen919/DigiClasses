const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const expenseSchema = new Schema({
  name: { type: String, required: true },
  paymentMode: { type: String, required: true },
  chequeNo: { type: String, required: false },
  date: { type: String, required: true },
  amount: { type: Number, required: true },
  remark: { type: String, required: false }
}, { timestamps: true });

const incomeSchema = new Schema({
  type: { type: String, required: true },
  paymentType: { type: String, required: true },
  chequeNo: { type: String, required: false },
  bankName: { type: String, required: false },
  date: { type: String, required: true },
  amount: { type: Number, required: true }
}, { timestamps: true });

const Expense = mongoose.model('Expense', expenseSchema);
const Income = mongoose.model('Income', incomeSchema);

module.exports = { Expense, Income };
