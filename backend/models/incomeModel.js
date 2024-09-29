const mongoose = require('mongoose');

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

module.exports = { Income };  