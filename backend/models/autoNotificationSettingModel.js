const mongoose = require('mongoose');

const AutoNotificationSettingSchema = new mongoose.Schema({
  userId: { type: String, required: true, unique: true },
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
});

module.exports = mongoose.model('AutoNotificationSetting', AutoNotificationSettingSchema);
