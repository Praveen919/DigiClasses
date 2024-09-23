const mongoose = require('mongoose');

const MessageSchema = new mongoose.Schema({
  email: {
    type: String,
    required: true,
  },
  studentId: {
    type: String,
  },
  message: {
    type: String,
    required: true,
  },
  sentAt: {
    type: Date,
    default: Date.now,
  },
  recipientId: {
    type: mongoose.Schema.Types.ObjectId, // Optional field for storing teacher/admin ID
    ref: 'User', // Assuming teachers/admins are stored as 'User'
  },
});

module.exports = mongoose.model('Message', MessageSchema);
