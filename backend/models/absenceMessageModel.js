const mongoose = require('mongoose');

const absenceSchema = new mongoose.Schema({
  studentName: { type: String, required: false },
  standard: { type: String, required: false },
  batch: { type: String, required: false },
  reason: { type: String, required: true },
  document: { type: String }, // URL to the document file (if uploaded)
  createdAt: { type: Date, default: Date.now },
});

const Absence = mongoose.model('Absence', absenceSchema);

module.exports = Absence;
