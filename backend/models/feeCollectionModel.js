// Model.js
const mongoose = require('mongoose');

// Define the schema for fee collection
const FeeCollectionSchema = new mongoose.Schema({
  name: { type: String, required: true },
  std: { type: String, required: true }, // Standard/Grade
  batch: { type: String, required: true },
  totalFees: { type: Number, required: true },
  discountedFees: { type: Number, default: 0 },
  amtPaid: { type: Number, required: true },
  date: { type: Date, required: true }
});

// Create the model
const FeeCollection = mongoose.model('FeeCollection', FeeCollectionSchema);

module.exports = FeeCollection;
