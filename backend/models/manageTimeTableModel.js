const mongoose = require('mongoose');

const timeTableSchema = new mongoose.Schema({
  standard: { type: String, required: true },
  batch: { type: String, required: true },
  timetable: [
    {
      time: { type: String, required: true }, // e.g., "08:00 - 09:00"
      lectures: [
        {
          day: { type: Number, required: true }, // 0 for Monday, 1 for Tuesday, etc.
          subject: { type: String, default: null }, // Allow subject to be null
        },
      ],
    },
  ],
});

module.exports = mongoose.model('TimeTable', timeTableSchema);
