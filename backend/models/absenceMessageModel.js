const mongoose = require('mongoose');

const absenceSchema = new mongoose.Schema({
  student: { type: mongoose.Schema.Types.ObjectId, ref: 'Student', required: true },
  standard: { type: String, required: false },
  batch: { type: String, required: false },
  reason: { type: String, required: true },
  document: { type: String },
  createdAt: { type: Date, default: Date.now },
});

const Absence = mongoose.model('Absence', absenceSchema);

module.exports = Absence;
