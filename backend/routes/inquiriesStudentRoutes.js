const express = require('express');
const router = express.Router();
const Inquiry = require('../models/inquiriesStudentModel');

// POST: Create a new inquiry
router.post('/inquiries', async (req, res) => {
  try {
    const { subject, message } = req.body;

    if (!subject || !message) {
      return res.status(400).json({ error: 'Subject and message are required.' });
    }

    const inquiry = new Inquiry({
      subject,
      message,
    });

    await inquiry.save();
    res.status(201).json({ message: 'Inquiry submitted successfully.' });
  } catch (error) {
    res.status(500).json({ error: 'An error occurred while submitting the inquiry.' });
  }
});

// GET: Get all inquiries for admin and teacher
router.get('/inquiries', async (req, res) => {
  try {
    const inquiries = await Inquiry.find();
    res.json(inquiries);
  } catch (error) {
    res.status(500).json({ error: 'An error occurred while retrieving inquiries.' });
  }
});

// PUT: Mark inquiry as read by admin or teacher
router.put('/inquiries/:id/read', async (req, res) => {
  const inquiryId = req.params.id;
  const { role } = req.body; // "admin" or "teacher"

  try {
    const inquiry = await Inquiry.findById(inquiryId);

    if (!inquiry) {
      return res.status(404).json({ error: 'Inquiry not found.' });
    }

    if (role === 'admin') {
      inquiry.isReadByAdmin = true;
    } else if (role === 'teacher') {
      inquiry.isReadByTeacher = true;
    }

    await inquiry.save();
    res.json({ message: 'Inquiry marked as read.' });
  } catch (error) {
    res.status(500).json({ error: 'An error occurred while updating inquiry status.' });
  }
});

module.exports = router;
