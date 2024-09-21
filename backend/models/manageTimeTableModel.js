const mongoose = require('mongoose');

const timeTableSchema = new mongoose.Schema({
  standard: String,
  batch: String,
  timetable: [
    {
      day: Number, // 0 for Monday, 1 for Tuesday, etc.
      timeSlot: Number, // Slot index (0, 1, 2, 3, 4)
      lecture: String,
    },
  ],
});

module.exports = mongoose.model('TimeTable', timeTableSchema);
