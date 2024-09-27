const mongoose = require('mongoose');

// Schema for individual notifications
const notificationSchema = new mongoose.Schema({
  message: { type: String, required: true }, // The content of the notification
  date: { type: Date, default: Date.now }, // Date of notification
  type: { type: String, enum: ['admin', 'teacher'], required: true }, // Source of notification
  read: { type: Boolean, default: false } // Whether the notification has been read
});

// Main AutoNotificationSetting schema
const AutoNotificationSettingSchema = new mongoose.Schema({
  userId: { type: String, required: true, unique: true }, // Unique user identifier
  studentAbsentAttendanceNotification: { type: Boolean, default: false },
  attendancePerformanceStatusNotification: { type: Boolean, default: false },
  feeReminderNotification: { type: Boolean, default: false },
  newManualExamScheduledNotification: { type: Boolean, default: false },
  studentAbsentInExamNotification: { type: Boolean, default: false },
  studentExamMarksNotification: { type: Boolean, default: false },
  newMcqExamAssignedNotification: { type: Boolean, default: false },
  studentAbsentInMcqExamNotification: { type: Boolean, default: false },
  studentMcqExamMarksNotification: { type: Boolean, default: false },
  newAssignmentSharedNotification: { type: Boolean, default: false },
  newDocumentSharedNotification: { type: Boolean, default: false },
  
  // Array to store dynamic notifications from admin/teacher
  notifications: [notificationSchema]
});

module.exports = mongoose.model('AutoNotificationSetting', AutoNotificationSettingSchema);
