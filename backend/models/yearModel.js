// yearModel.js

const mongoose = require('mongoose');

const yearSchema = new mongoose.Schema({
  yearName: { type: String, required: true },
  fromDate: { type: Date, required: true },
  toDate: { type: Date, required: true },
  remarks: { type: String },
});

const Year = mongoose.model('Year', yearSchema);

module.exports = Year;

