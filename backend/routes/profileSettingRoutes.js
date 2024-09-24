const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const ProfileSettings = require('../models/profileSettingModel');

// Multer setup for file uploads
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, './uploads'); // Store files in the "uploads/" folder
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + path.extname(file.originalname)); // Set unique file name
  },
});

// Optional: Filter to allow only image files (JPEG/PNG)
const fileFilter = (req, file, cb) => {
  if (file.mimetype === 'image/jpeg' || file.mimetype === 'image/png') {
    cb(null, true);
  } else {
    cb(new Error('Only image files are allowed!'), false);
  }
};

// Initialize multer with storage, size limit (5MB), and file filter
const upload = multer({
  storage: storage,
  limits: { fileSize: 1024 * 1024 * 5 }, // 5MB file size limit
  fileFilter: fileFilter,
});

// Create or update profile settings with profileLogo upload
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

    // Ensure email is provided, used for identification
    if (!email) {
      return res.status(400).json({ message: 'Email is required to update profile settings' });
    }

    // Prepare profile data object with file path if file uploaded
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
      profileLogo: req.file ? req.file.path : null, // Store file path
    };

    // Find existing profile settings by email, update or create new if not found
    const profileSettings = await ProfileSettings.findOneAndUpdate(
      { email }, // Identify profile by email
      profileData,
      { new: true, upsert: true, setDefaultsOnInsert: true } // Create if doesn't exist
    );

    // Send success response
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
