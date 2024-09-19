const express = require('express');
const router = express.Router();
const ProfileSettings = require('../models/profileSettingModel');
const upload = require('../config/gridfsStorage'); // Set up GridFS storage

// Create or update profile settings
router.post('/', upload.single('profileLogo'), async (req, res) => {
  try {
    const {
      instituteName,
      country,
      city,
      branchName,
      feeRecHeader,
      branchAddress,
      taxNo,
      feeFooter,
      logoDisplay,
      feeStatusDisplay,
      chatOption,
      name,
      mobile,
      email
    } = req.body;

    const profileData = {
      instituteName,
      country,
      city,
      branchName,
      feeRecHeader,
      branchAddress,
      taxNo,
      feeFooter,
      logoDisplay,
      feeStatusDisplay,
      chatOption,
      name,
      mobile,
      email,
      profileLogo: req.file ? req.file.filename : null // Save file ID from GridFS
    };

    // Upsert: create new or update existing settings
    const profileSettings = await ProfileSettings.findOneAndUpdate(
      { email: email }, // Identify by email
      profileData,
      { new: true, upsert: true }
    );

    res.status(200).json(profileSettings);
  } catch (error) {
    res.status(500).json({ message: 'Error saving profile settings', error });
  }
});

module.exports = router;
