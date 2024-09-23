const express = require('express');
const router = express.Router();
const { MessageStudent, StudentToAdminTeacherMessage } = require('../models/messageStudentModel'); // Import models

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
    res.status(500).json({ error: 'Server error' });
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
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;
