const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const User = require('../models/userModel'); // Adjust path as needed
const jwt = require('jsonwebtoken'); // Import jwt

// Middleware to authenticate the token and extract user information
const authenticateToken = async (req, res, next) => {
    const token = req.headers['authorization']?.split(' ')[1];
    if (!token) return res.sendStatus(401); // Unauthorized

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET); // Use your secret
        req.user = await User.findById(decoded.id); // Assuming the token contains user ID
        if (!req.user) return res.sendStatus(404); // User not found
        next();
    } catch (error) {
        console.error('Token verification error:', error.message);
        res.sendStatus(403); // Forbidden
    }
};

// Route to handle password reset
router.post('/resetPassword', authenticateToken, async (req, res) => {
    const { currentPassword, newPassword } = req.body;

    // Validate input
    if (!currentPassword || !newPassword) {
        return res.status(400).json({ message: 'Current and new passwords are required' });
    }

    try {
        // Use the authenticated user's email
        const email = req.user.email; 

        // Find the user by email
        const user = await User.findOne({ email });
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        // Check if the current password is correct
        const isMatch = await bcrypt.compare(currentPassword, user.password);
        if (!isMatch) {
            return res.status(401).json({ message: 'Current password is incorrect' });
        }

        // Check if the new password is the same as the current password
        if (currentPassword === newPassword) {
            return res.status(400).json({ message: 'New Password cannot be the same as current password' });
        }
        // Update the user's password
        user.password = newPassword; // Set the new password
        // Save the user document, which triggers the pre-save hook for hashing
        await user.save();

        res.status(200).json({ message: 'Password updated successfully' });
    } catch (error) {
        console.error('Error resetting password:', error.message);
        res.status(500).json({ message: 'Failed to reset password' });
    }
});
// Route to check email existence for password reset
router.post('/checkEmail', async (req, res) => {
    const { email } = req.body;

    if (!email) {
        return res.status(400).json({ message: 'Email is required' });
    }

    try {
        const user = await User.findOne({ email });
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }
        res.status(200).json({ message: 'Email exists' });
    } catch (error) {
        console.error('Error checking email existence:', error.message);
        res.status(500).json({ message: 'Failed to check email' });
    }
});
module.exports = router;
