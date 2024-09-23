const express = require('express');
const router = express.Router();
const Message = require('../models/messageStudentIdPassModel');

// Route to handle student message submission
router.post('/student/messages', async (req, res) => {
  try {
    const { email, studentId, message } = req.body;

    if (!email || !message) {
      return res.status(400).json({ success: false, error: 'Email and message are required' });
    }

    // Create a new message entry
    const newMessage = new Message({
      email,
      studentId,
      message,
    });

    await newMessage.save();
    res.status(200).json({ success: true, message: 'Message sent successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, error: 'Failed to send the message' });
  }
});

module.exports = router;
