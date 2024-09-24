const express = require('express');
const router = express.Router();
const multer = require('multer');
const ProfileSettings = require('../models/profileSettingsModel1');

// Configure Multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/profile-logos'); // Specify the folder to store profile logos
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + '-' + file.originalname); // Generate a unique filename
  }
});

const upload = multer({ storage });

// POST route to update profile settings
router.post('/profile-settings', upload.single('profileLogo'), async (req, res) => {
  try {
    const {
      instituteName, country, city, branchName, branchAddress,
      logoDisplay, chatOption, name, mobile, email
    } = req.body;

    // Create a new profile settings object
    const newSettings = new ProfileSettings({
      instituteName,
      country,
      city,
      branchName,
      branchAddress,
      logoDisplay,
      chatOption,
      name,
      mobile,
      email,
      profileLogo: req.file ? req.file.path : null, // Save the profile logo path if provided
    });

    await newSettings.save();
    res.status(200).json({ message: 'Profile settings updated successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to update profile settings' });
  }
});

module.exports = router;
