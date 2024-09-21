<<<<<<< HEAD
// messageStudentRoutes.js

const express = require('express');
const router = express.Router();
const MessageStudent = require('../models/messageStudentModel'); // Import MessageStudent Model

// POST route to send a message
router.post('/messages', async (req, res) => {
  const { studentId, subject, message } = req.body;

  // Validate input
  if (!studentId || !subject || !message) {
    return res.status(400).json({ error: 'All fields are required' });
  }

  try {
    // Create a new message
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

module.exports = router;
=======
// messageStudentRoutes.js

const express = require('express');
const router = express.Router();
const MessageStudent = require('./messageStudentModel'); // Import MessageStudent Model

// POST route to send a message
router.post('/messages', async (req, res) => {
  const { studentId, subject, message } = req.body;

  // Validate input
  if (!studentId || !subject || !message) {
    return res.status(400).json({ error: 'All fields are required' });
  }

  try {
    // Create a new message
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

module.exports = router;
>>>>>>> cc5af9e141bdcffd7728c0c772999721e41a5e89
