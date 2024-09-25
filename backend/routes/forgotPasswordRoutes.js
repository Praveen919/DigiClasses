const express = require('express');
const crypto = require('crypto');
const bcrypt = require('bcrypt');
const nodemailer = require('nodemailer');
const User = require('../models/userModel'); // Import the User model

const router = express.Router();

// POST route to request a password reset
router.post('/forgot-password', async (req, res) => {
    const { email } = req.body;

    try {
        const user = await User.findOne({ email });

        if (!user) {
            return res.status(404).send('User with this email does not exist');
        }

        // Generate a reset token
        const resetToken = crypto.randomBytes(32).toString('hex');
        const resetTokenHash = crypto.createHash('sha256').update(resetToken).digest('hex');

        // Set the token and its expiration (1 hour)
        user.resetPasswordToken = resetTokenHash;
        user.resetPasswordExpires = Date.now() + 3600000; // 1 hour from now

        await user.save();

        // Send email with the reset token
        const resetLink = `http://192.168.0.104:3000/reset-password?token=${resetToken}`;

        // Send email (using nodemailer here)
        const transporter = nodemailer.createTransport({
            service: 'gmail', // Use your preferred email service
            auth: {
                user: 'digiclass737@gmail.com', // Replace with your email
                pass: 'digiclass@2024'  // Replace with your email password
            }
        });

        const mailOptions = {
            from: 'digiclass737@gmail.com',
            to: user.email,
            subject: 'Password Reset Request',
            text: `You requested a password reset. Click the link to reset your password: ${resetLink}`
        };

        await transporter.sendMail(mailOptions);

        res.send('Password reset link has been sent to your email.');
    } catch (error) {
        res.status(500).send('Something went wrong. Please try again.');
    }
});

// POST route to reset the password
router.post('/reset-password/:token', async (req, res) => {
    const { token } = req.params;
    const { password } = req.body;

    try {
        // Hash the token received from the URL
        const resetTokenHash = crypto.createHash('sha256').update(token).digest('hex');

        // Find the user with the matching token and ensure it's not expired
        const user = await User.findOne({
            resetPasswordToken: resetTokenHash,
            resetPasswordExpires: { $gt: Date.now() }  // Check if token is still valid
        });

        if (!user) {
            return res.status(400).send('Token is invalid or has expired.');
        }

        // Update password and clear the reset token fields
        user.password = password;
        user.resetPasswordToken = undefined;
        user.resetPasswordExpires = undefined;

        await user.save();

        res.send('Password has been reset successfully.');
    } catch (error) {
        res.status(500).send('Something went wrong. Please try again.');
    }
});

module.exports = router;
