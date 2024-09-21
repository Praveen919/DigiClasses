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

    // Ensure email is provided as it's used for identification
    if (!email) {
      return res.status(400).json({ message: 'Email is required to update profile settings' });
    }

    // Prepare the profile data object
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
      profileLogo: req.file ? req.file.filename : undefined // Save file name from GridFS if uploaded
    };

    // Find the existing profile settings by email and update or create new if not found
    const profileSettings = await ProfileSettings.findOneAndUpdate(
      { email }, // Identify by email
      profileData,
      { new: true, upsert: true, setDefaultsOnInsert: true } // Create if not exists, update if exists
    );

    res.status(200).json({
      message: 'Profile settings saved successfully',
      profileSettings
    });
  } catch (error) {
    console.error('Error saving profile settings:', error);
    res.status(500).json({ message: 'Error saving profile settings', error: error.message });
  }
});

module.exports = router;
