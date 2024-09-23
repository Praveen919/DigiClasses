const mongoose = require('mongoose');

// Schema for messages sent from admin to student
const MessageStudentSchema = new mongoose.Schema({
  studentId: { type: mongoose.Schema.Types.ObjectId, ref: 'Student', required: true },
  subject: { type: String, required: true },
  message: { type: String, required: true },
  createdAt: { type: Date, default: Date.now },
});

// Schema for messages sent from student to admin/teacher
const StudentToAdminTeacherMessageSchema = new mongoose.Schema({
  senderStudentId: { type: mongoose.Schema.Types.ObjectId, ref: 'Student', required: true },
  recipientId: { type: mongoose.Schema.Types.ObjectId, ref: 'AdminTeacher', required: true },
  subject: { type: String, required: true },
  message: { type: String, required: true },
  createdAt: { type: Date, default: Date.now },
});

// Schema for messages sent from teacher to student
const TeacherToStudentMessageSchema = new mongoose.Schema({
  teacherId: { type: mongoose.Schema.Types.ObjectId, ref: 'Teacher', required: true },
  studentId: { type: mongoose.Schema.Types.ObjectId, ref: 'Student', required: true },
  subject: { type: String, required: true },
  message: { type: String, required: true },
  createdAt: { type: Date, default: Date.now },
});

// Schema for messages sent from teacher to staff
const TeacherToStaffMessageSchema = new mongoose.Schema({
  teacherId: { type: mongoose.Schema.Types.ObjectId, ref: 'Teacher', required: true },
  staffId: { type: mongoose.Schema.Types.ObjectId, ref: 'Staff', required: true },
  subject: { type: String, required: true },
  message: { type: String, required: true },
  createdAt: { type: Date, default: Date.now },
});

const ExamNotificationSchema = new mongoose.Schema({
  standard: {type: String,required: true,},
  subject: {type: String,required: true,},
  examName: {type: String,required: true,},
  date: {type: Date,default: Date.now,},
});


// Models
const MessageStudent = mongoose.model('MessageStudent', MessageStudentSchema);
const StudentToAdminTeacherMessage = mongoose.model('StudentToAdminTeacherMessage', StudentToAdminTeacherMessageSchema);
const TeacherToStudentMessage = mongoose.model('TeacherToStudentMessage', TeacherToStudentMessageSchema);
const TeacherToStaffMessage = mongoose.model('TeacherToStaffMessage', TeacherToStaffMessageSchema);
const ExamNotification = mongoose.model('ExamNotification', ExamNotificationSchema);

module.exports = {
  MessageStudent,
  StudentToAdminTeacherMessage,
  TeacherToStudentMessage,
  TeacherToStaffMessage,
  ExamNotification,
};
