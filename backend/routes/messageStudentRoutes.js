const express = require('express');
const router = express.Router();
const {
  MessageStudent,
  StudentToAdminTeacherMessage,
  TeacherToStudentMessage,
  TeacherToStaffMessage,
  ExamNotification,
  AdminToTeacherMessage // Assuming you need this model for admin-to-teacher messages
} = require('../models/messageStudentModel'); // Import models

// POST route to send a message from admin to student
router.post('/admin/messages', async (req, res) => {
  const { studentId, subject, message } = req.body;

  // Validate input
  if (!studentId || !subject || !message) {
    return res.status(400).json({ error: 'All fields are required' });
  }

  try {
    // Create a new admin-to-student message
    const newMessage = new MessageStudent({
      studentId,
      subject,
      message,
    });

    // Save message to the database
    await newMessage.save();

    // Send success response
    res.status(200).json({ success: true, message: 'Message sent successfully' });
  } catch (err) {
    console.error(err); // Log the error for debugging
    res.status(500).json({ error: 'Server error while sending message' });
  }
});

// POST route to send a message from student to admin/teacher
router.post('/student/messages', async (req, res) => {
  const { senderStudentId, recipientId, subject, message } = req.body;

  // Validate input
  if (!senderStudentId || !recipientId || !subject || !message) {
    return res.status(400).json({ error: 'All fields are required' });
  }

  try {
    // Create a new student-to-admin/teacher message
    const newMessage = new StudentToAdminTeacherMessage({
      senderStudentId,
      recipientId,
      subject,
      message,
    });

    // Save message to the database
    await newMessage.save();

    // Send success response
    res.status(200).json({ success: true, message: 'Message sent successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error while sending message' });
  }
});

// POST route to send a message from teacher to student
router.post('/teacher/messages', async (req, res) => {
  const { teacherId, studentId, subject, message } = req.body;

  // Validate input
  if (!teacherId || !studentId || !subject || !message) {
    return res.status(400).json({ error: 'All fields are required' });
  }

  try {
    // Create a new teacher-to-student message
    const newMessage = new TeacherToStudentMessage({
      teacherId,
      studentId,
      subject,
      message,
    });

    // Save message to the database
    await newMessage.save();

    // Send success response
    res.status(200).json({ success: true, message: 'Message sent successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error while sending message' });
  }
});

// POST route to send a message from teacher to staff
router.post('/teacher/staff/messages', async (req, res) => {
  const { teacherId, staffId, subject, message } = req.body;

  // Validate input
  if (!teacherId || !staffId || !subject || !message) {
    return res.status(400).json({ error: 'All fields are required' });
  }

  try {
    // Create a new teacher-to-staff message
    const newMessage = new TeacherToStaffMessage({
      teacherId,
      staffId,
      subject,
      message,
    });

    // Save message to the database
    await newMessage.save();

    // Send success response
    res.status(200).json({ success: true, message: 'Message sent successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error while sending message' });
  }
});

// POST route to send a message from admin to staff
router.post('/admin/staff', async (req, res) => {
  const { teacherId, subject, message } = req.body;

  // Validate input
  if (!teacherId || !message) {
    return res.status(400).json({ error: 'All fields are required' });
  }

  try {
    // Create a new admin-to-teacher message
    const newMessage = new AdminToTeacherMessage({
      teacherId,
      subject: subject || '',
      message,
    });

    // Save message to the database
    await newMessage.save();

    // Send success response
    res.status(200).json({ success: true, message: 'Message sent successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error while sending message' });
  }
});

// POST route to send exam notification
router.post('/exam/notifications', async (req, res) => {
  const { standard, subject, examName, date } = req.body;

  // Validate input
  if (!standard || !subject || !examName || !date) {
    return res.status(400).json({ error: 'All fields are required' });
  }

  try {
    // Create a new exam notification
    const newNotification = new ExamNotification({
      standard,
      subject,
      examName,
      date,
    });

    // Save notification to the database
    await newNotification.save();

    // Send success response
    res.status(200).json({ success: true, message: 'Exam notification sent successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error while sending notification' });
  }
});

module.exports = router;
