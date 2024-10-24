const mongoose = require('mongoose');
const express = require('express');
const router = express.Router();
const ObjectId = mongoose.Types.ObjectId;
const {
  MessageStudent,
  StudentToAdminTeacherMessage,
  TeacherToStudentMessage,
  TeacherToStaffMessage,
  ExamNotification,
  AdminToTeacherMessage // Import the model for admin-to-teacher messages
} = require('../models/messageStudentModel'); // Ensure the correct path to your model

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
  try {
    const { senderStudentId, recipientId, subject, message } = req.body;

    // Convert senderStudentId and recipientId to ObjectId
    const senderObjectId = ObjectId.isValid(senderStudentId) ? new ObjectId(senderStudentId) : null;
    const recipientObjectId = ObjectId.isValid(recipientId) ? new ObjectId(recipientId) : null;

    // Check if senderObjectId and recipientObjectId are valid
    if (!senderObjectId || !recipientObjectId) {
      return res.status(400).json({ success: false, message: 'Invalid sender or recipient ID.' });
    }

    // Create and save the message
    const newMessage = new StudentToAdminTeacherMessage({
      senderStudentId: senderObjectId,
      recipientId: recipientObjectId,
      subject,
      message,
    });

    await newMessage.save();
    res.status(200).json({ success: true, message: 'Message sent successfully.' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: 'Failed to send message.' });
  }
});

// POST route to send a message from teacher to student
router.post('/teacher/messages', async (req, res) => {
  const { studentId, title, message } = req.body;  //teacherId

  // Validate input
  if ( !studentId || !title || !message) {
    return res.status(400).json({ error: 'All fields are required' });
  }

  try {
    // Create a new teacher-to-student message
    const newMessage = new TeacherToStudentMessage({
      //teacherId,
      studentId,
      title,
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
  const { teacherId,  title, message } = req.body; //staffId

  // Validate input
  if (!teacherId || !title || !message) {
    return res.status(400).json({ error: 'All fields are required' });
  }

  try {
    // Create a new teacher-to-staff message
    const newMessage = new TeacherToStaffMessage({
      teacherId,
     // staffId,
      title,
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
  const { staffId, subject, message } = req.body;

  // Validate input
  if (!staffId || !message) {
    return res.status(400).json({ error: 'All fields are required' });
  }

  try {
    // Create a new admin-to-staff message
    const newMessage = new AdminToTeacherMessage({
      teacherId: staffId,
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
  if (!standard || !subject || !examName) {
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
    res.status(500).json({ error: 'Server error while sending exam notification' });
  }
});

// GET route to retrieve messages for a specific admin
router.get('/admin/messages/:adminId', async (req, res) => {
  const { adminId } = req.params;

  try {
    // Find all messages sent to this admin
    const messages = await AdminToTeacherMessage.find({ recipientId: adminId }).populate('teacherId');

    // Return the messages
    res.status(200).json(messages);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error retrieving messages' });
  }
});

// GET route for retrieving messages sent to a specific student
router.get('/student/messages/:studentId', async (req, res) => {
  const { studentId } = req.params;

  try {
    const messages = await MessageStudent.find({ studentId }).populate('studentId');
    res.status(200).json(messages);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error retrieving student messages' });
  }
});


// GET route for retrieving messages sent from a student to admin/teacher
router.get('/student/to-admin-teacher/messages/:studentId', async (req, res) => {
  const { studentId } = req.params;

  try {
    const messages = await StudentToAdminTeacherMessage.find({ senderStudentId: studentId }).populate('recipientId');
    res.status(200).json(messages);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error retrieving student to admin/teacher messages' });
  }
});

// GET route for retrieving messages sent to a specific teacher
router.get('/teacher/messages/:teacherId', async (req, res) => {
  const { teacherId } = req.params;

  try {
    const messages = await TeacherToStudentMessage.find({ teacherId }).populate('studentId');
    res.status(200).json(messages);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error retrieving messages for teacher' });
  }
});

// GET route for retrieving messages sent to a specific staff member
router.get('/staff/messages/:staffId', async (req, res) => {
  const { staffId } = req.params;

  try {
    const messages = await TeacherToStaffMessage.find({ staffId }).populate('teacherId');
    res.status(200).json(messages);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error retrieving messages for staff' });
  }
});

// GET route for retrieving exam notifications
router.get('/exam/notifications', async (req, res) => {
  try {
    const notifications = await ExamNotification.find();
    res.status(200).json(notifications);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error retrieving exam notifications' });
  }
});

module.exports = router;
