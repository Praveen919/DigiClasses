<<<<<<< HEAD
// messageStudentModel.js

const mongoose = require('mongoose');

// Define the Message Schema
const messageStudentSchema = new mongoose.Schema({
  studentId: { type: String, required: true }, // Student ID
  subject: { type: String, required: true },   // Subject/Topic
  message: { type: String, required: true },   // Message body
  date: { type: Date, default: Date.now }      // Timestamp
});

// Export the Message model
const MessageStudent = mongoose.model('MessageStudent', messageStudentSchema);
module.exports = MessageStudent;
=======
// messageStudentModel.js

const mongoose = require('mongoose');

// Define the Message Schema
const messageStudentSchema = new mongoose.Schema({
  studentId: { type: String, required: true }, // Student ID
  subject: { type: String, required: true },   // Subject/Topic
  message: { type: String, required: true },   // Message body
  date: { type: Date, default: Date.now }      // Timestamp
});

// Export the Message model
const MessageStudent = mongoose.model('MessageStudent', messageStudentSchema);
module.exports = MessageStudent;
>>>>>>> cc5af9e141bdcffd7728c0c772999721e41a5e89
