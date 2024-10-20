const mongoose = require('mongoose');

const logbookSchema = new mongoose.Schema({
  month: {
    type: String,
    required: true,
  },
  subject: {
    type: String,
    required: true,
  },
  time: {
    type: String,
    required: true,
  },
  // Add other fields as needed
});

const Logbook = mongoose.model('Logbook', logbookSchema);
module.exports = Logbook;
