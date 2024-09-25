// logbookModel.js

const mongoose = require('mongoose');

const logbookSchema = new mongoose.Schema({
  date: { type: String, required: true },    // Date of the entry (can be a string like '2024-09-25')
  timing: { type: String, required: true },  // Time slot, e.g., '9 AM - 10 AM'
  subject: { type: String, required: true }, // Subject being taught
  topic: { type: String, required: true },   // Topic covered in that session
  month: { type: String, required: true },   // Month for the logbook entry
});

const Logbook = mongoose.model('Logbook', logbookSchema);

module.exports = Logbook;
