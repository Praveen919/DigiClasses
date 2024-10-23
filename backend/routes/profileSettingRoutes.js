const express = require('express');
const multer = require('multer');
const path = require('path');
const User = require('../models/userModel'); 
const jwt = require('jsonwebtoken');

const router = express.Router();

// Middleware to verify the token
const verifyToken = (req, res, next) => {
    const token = req.headers['authorization']?.split(' ')[1];

    if (!token) {
        return res.status(403).send('A token is required for authentication');
    }

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.user = decoded; // Attach user info to request
    } catch (err) {
        return res.status(401).send('Invalid Token');
    }
    return next();
};

// Multer setup for file uploads
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, './uploads');
    },
    filename: function (req, file, cb) {
        cb(null, Date.now() + path.extname(file.originalname));
    },
});

const upload = multer({
    storage: storage,
    limits: { fileSize: 1024 * 1024 * 5 },
    fileFilter: (req, file, cb) => {
        if (file.mimetype === 'image/jpeg' || file.mimetype === 'image/png') {
            cb(null, true);
        } else {
            cb(new Error('Only image files are allowed!'), false);
        }
    },
});

// Fetch profile settings
router.get('/', verifyToken, async (req, res) => {
    try {
        const userId = req.user.id;
        const profile = await User.findById(userId);

        if (!profile) {
            return res.status(404).json({ message: 'Profile not found' });
        }

        res.status(200).json(profile);
    } catch (error) {
        console.error('Error fetching profile settings:', error);
        res.status(500).json({ message: 'Error fetching profile settings', error: error.message });
    }
});


// Update or create profile settings
router.post('/', verifyToken, upload.single('profileLogo'), async (req, res) => {
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
            email,
        } = req.body;

        const userId = req.user.id; 

        // Validate user ID
        if (!userId) {
            return res.status(400).json({ message: 'User ID is required' });
        }


        // Check if email is provided and matches the logged-in user's email
        if (!email || email === 'null') {
            return res.status(400).json({ message: 'Email is required and cannot be null' });
        }
        if (email !== req.user.email) {
            return res.status(400).json({ message: 'Email must match the logged-in user' });
        }

        // Prepare the profile data
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
            profileLogo: req.file ? req.file.path : null, 
        };

        // Check for existing profile settings to prevent null email entry
        const existingProfile = await User.findOne({ _id: userId });
        if (existingProfile && !existingProfile.email) {
            return res.status(400).json({ message: 'Existing profile settings cannot have a null email' });
        }

        // Update or create the existing profile settings
        const profileSettings = await User.findOneAndUpdate(
            { _id: userId },
            profileData,
            { new: true, upsert: true }
        );

        res.status(200).json({
            message: 'Profile settings updated successfully',
            profileSettings,
        });

    } catch (error) {
        console.error('Error saving profile settings:', error);
        res.status(500).json({ message: 'Error saving profile settings', error: error.message });
    }
});

module.exports = router;
