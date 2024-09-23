const mongoose = require('mongoose');

const absenceSchema = new mongoose.Schema({
  reason: { type: String, required: true },
  document: { type: String }, // URL to the document file (if uploaded)
  createdAt: { type: Date, default: Date.now },
});

const Absence = mongoose.model('Absence', absenceSchema);

module.exports = Absence;
