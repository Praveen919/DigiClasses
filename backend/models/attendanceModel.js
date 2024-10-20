const mongoose = require('mongoose');

const attendanceSchema = new mongoose.Schema({
  student: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Student',
    required: true
  },
  classBatch: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'ClassBatch',
    required: true
  },
  date: {
    type: Date,
    required: true
  },
  status: {
    type: String,
    enum: ['Present', 'Absent'], // Ensure these match the values used in your app
    required: true
  }
}, {
  timestamps: true // Optional: to keep track of createdAt and updatedAt fields
});

module.exports = mongoose.model('Attendance', attendanceSchema);
