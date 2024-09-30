const express = require('express');
const nodemailer = require('nodemailer');
const crypto = require('crypto');
const bcrypt = require('bcrypt');
const User = require('../models/userModel'); // Your user model
const router = express.Router();
require('dotenv').config();

let otpStore = {}; // Temporary storage for OTPs (in production, use a database)

// Send OTP to the user's email
router.post('/send-otp', async (req, res) => {
  const { email } = req.body;
  try {
    const user = await User.findOne({ email });

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    const otp = crypto.randomInt(100000, 999999); // Generate a 6-digit OTP
    const expiryTime = Date.now() + 5 * 60 * 1000; // OTP expires in 5 minutes

    otpStore[email] = { otp, expiryTime }; // Store OTP and expiry time

    // Configure nodemailer
    const transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: process.env.EMAIL,
        pass: process.env.EMAIL_PASSWORD,
      },
    });

    // Send OTP email
    const mailOptions = {
      from: process.env.EMAIL,
      to: email,
      subject: 'Your OTP Code',
      text: `Your OTP code is ${otp}. It is valid for 5 minutes.`,
    };

    transporter.sendMail(mailOptions, (error, info) => {
      if (error) {
        return res.status(500).json({ message: 'Failed to send OTP' });
      }
      res.status(200).json({ message: 'OTP sent successfully' });
    });
  } catch (error) {
    res.status(500).json({ message: 'Error sending OTP', error });
  }
});

// Verify OTP
router.post('/verify-otp', (req, res) => {
  const { email, otp } = req.body;
  const storedOtpData = otpStore[email];

  if (!storedOtpData) {
    return res.status(400).json({ message: 'OTP not found or expired' });
  }

  const { otp: storedOtp, expiryTime } = storedOtpData;

  if (Date.now() > expiryTime) {
    delete otpStore[email];
    return res.status(400).json({ message: 'OTP has expired' });
  }

  if (storedOtp === otp) {
    delete otpStore[email]; // Clear OTP after successful verification
    return res.status(200).json({ message: 'OTP verified successfully' });
  } else {
    return res.status(400).json({ message: 'Invalid OTP' });
  }
});

// Reset Password without hashing
router.post('/reset-password', async (req, res) => {
  const { email, newPassword } = req.body;

  try {
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Directly update the password without hashing
    user.password = newPassword; // Save plain text password
    await user.save();

    res.status(200).json({ message: 'Password reset successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error resetting password', error });
  }
});

module.exports = router;
