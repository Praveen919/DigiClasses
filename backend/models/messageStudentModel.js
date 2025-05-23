const mongoose = require('mongoose');

// Schema for messages sent from admin to student
const MessageStudentSchema = new mongoose.Schema({
  adminId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: false },
  studentId: { type: mongoose.Schema.Types.ObjectId, ref: 'Student', required: true },
  subject: { type: String, required: true },
  message: { type: String, required: true },
  createdAt: { type: Date, default: Date.now },
});

// Schema for messages sent from student to admin/teacher
const StudentToAdminTeacherMessageSchema = new mongoose.Schema({
  senderStudentId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: false },
  adminId: { type: mongoose.Schema.Types.ObjectId, ref: 'Admin', required: true },
  subject: { type: String, required: true },
  message: { type: String, required: true },
  createdAt: { type: Date, default: Date.now },
});

// Schema for messages sent from teacher to admin
const TeacherToAdminMessageSchema = new mongoose.Schema({
  teacherId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: false },
  //senderId: { type: mongoose.Schema.Types.ObjectId, ref: 'Teacher', required: true },
  adminId: { type: mongoose.Schema.Types.ObjectId, ref: 'Admin', required: true },
  title: { type: String, required: true },
  message: { type: String, required: true },
  createdAt: { type: Date, default: Date.now },
});

// Schema for messages sent from teacher to student
const TeacherToStudentMessageSchema = new mongoose.Schema({
  teacherId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: false },
  studentId: { type: mongoose.Schema.Types.ObjectId, ref: 'Student', required: true },
  title: { type: String, required: true },
  message: { type: String, required: true },
  createdAt: { type: Date, default: Date.now },
});

// Schema for messages sent from teacher to staff
const TeacherToStaffMessageSchema = new mongoose.Schema({
  teacherId: { type: mongoose.Schema.Types.ObjectId, ref: 'Teacher', required: true },
  //staffId: { type: mongoose.Schema.Types.ObjectId, ref: 'Staff', required: true },
  title: { type: String, required: true },
  message: { type: String, required: true },
  createdAt: { type: Date, default: Date.now },
});

//Schema to send message from admin to students for exam reminder
const ExamNotificationSchema = new mongoose.Schema({
  standard: {type: String,required: true,},
  subject: {type: String,required: true,},
  examName: {type: String,required: true,},
  date: {type: Date,default: Date.now,},
});

// Schema for messages sent from admin to teacher
const adminToTeacherMessageSchema = new mongoose.Schema({
  adminId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: false },
  teacherId: {type: mongoose.Schema.Types.ObjectId,ref: 'Teacher', required: true,},
  subject: {type: String,required: false,},
  message: {type: String,required: true,},
  timestamp: {type: Date,default: Date.now,
  },
});

// Models
const MessageStudent = mongoose.model('MessageStudent', MessageStudentSchema);
const StudentToAdminTeacherMessage = mongoose.model('StudentToAdminTeacherMessage', StudentToAdminTeacherMessageSchema);
const TeacherToStudentMessage = mongoose.model('TeacherToStudentMessage', TeacherToStudentMessageSchema);
const TeacherToAdminMessage = mongoose.model('TeacherToAdminMessage', TeacherToAdminMessageSchema);

const TeacherToStaffMessage = mongoose.model('TeacherToStaffMessage', TeacherToStaffMessageSchema);
const ExamNotification = mongoose.model('ExamNotification', ExamNotificationSchema);
const AdminToTeacherMessage = mongoose.model('AdminToTeacherMessage', adminToTeacherMessageSchema);

module.exports = {
  MessageStudent,
  StudentToAdminTeacherMessage,
  TeacherToStudentMessage,
  TeacherToAdminMessage,

  TeacherToStaffMessage,
  ExamNotification,
  AdminToTeacherMessage
};
