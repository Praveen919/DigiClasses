const mongoose = require('mongoose');

// Define the Message Schema for admin to student messages
const messageStudentSchema = new mongoose.Schema({
  studentId: { type: String, required: true },  // Student ID
  subject: { type: String, required: true },    // Subject/Topic
  message: { type: String, required: true },    // Message body
  date: { type: Date, default: Date.now }       // Timestamp
});

// Define the Message Schema for student to admin/teacher messages
const studentToAdminTeacherSchema = new mongoose.Schema({
  senderStudentId: { type: String, required: true },  // Student ID sending the message
  recipientId: { type: String, required: true },      // Admin/Teacher ID receiving the message
  subject: { type: String, required: true },          // Subject/Topic
  message: { type: String, required: true },          // Message body
  date: { type: Date, default: Date.now }             // Timestamp
});

// Export the Message models
const MessageStudent = mongoose.model('MessageStudent', messageStudentSchema);
const StudentToAdminTeacherMessage = mongoose.model('StudentToAdminTeacherMessage', studentToAdminTeacherSchema);

module.exports = {
  MessageStudent,
  StudentToAdminTeacherMessage
};
