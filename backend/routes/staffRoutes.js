const express = require('express');
const multer = require('multer');
const mongoose = require('mongoose');
const Staff = require('../models/staffModel');
const User = require('../models/userModel');

const router = express.Router();

// Setup multer for file uploads
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, 'uploads/'); // Save files to the 'uploads' directory
    },
    filename: function (req, file, cb) {
        cb(null, Date.now() + '-' + file.originalname); // Generate a unique filename
    }
});

const upload = multer({ storage: storage });

// Create staff
router.post('/', upload.single('profilePicture'), async (req, res) => {
    try {
        const staffData = {
            firstName: req.body.firstName,
            middleName: req.body.middleName,
            lastName: req.body.lastName,
            gender: req.body.gender,
            mobile: req.body.mobile,
            email: req.body.email,
            address: req.body.address,
            profilePicture: req.file ? req.file.path : null // Save file path if exists
        };

        const staff = new Staff(staffData);
        await staff.save();

        res.status(201).json({ message: 'Staff created successfully', staff });
    } catch (error) {
        res.status(500).json({ message: 'Error creating staff', error: error.message });
    }
});

// Update Staff
router.put('/:id', upload.single('profilePicture'), async (req, res) => {
    console.log('Updating staff with ID:', req.params.id); // Log staff ID

    try {
        const staffId = req.params.id;

        // Validate staff ID
        if (!staffId || !mongoose.Types.ObjectId.isValid(staffId)) {
            return res.status(400).json({ message: 'Invalid staff ID.' });
        }

        // Log the incoming request body
        console.log('Request Body:', req.body);

        const staffData = {};

        // Check for required fields
        if (!req.body.firstName || !req.body.lastName || !req.body.email) {
            return res.status(400).json({ message: 'First name, last name, and email are required.' });
        }

        // Assign fields if provided
        staffData.firstName = req.body.firstName;
        staffData.lastName = req.body.lastName;
        if (req.body.gender) staffData.gender = req.body.gender;
        if (req.body.mobile) staffData.mobile = req.body.mobile;
        if (req.body.email) staffData.email = req.body.email;
        if (req.body.address) staffData.address = req.body.address;

        // Check if a new profile picture is uploaded
        if (req.file) {
            staffData.profilePicture = `${req.protocol}://${req.get('host')}/${req.file.path}`;
        }

        // Find staff and update
        const staff = await Staff.findByIdAndUpdate(staffId, staffData, { new: true });

        if (!staff) {
            return res.status(404).json({ message: 'Staff not found' });
        }

        res.status(200).json({ message: 'Staff updated successfully', staff });
    } catch (error) {
        console.error('Error updating staff:', error); // Log the error for debugging
        res.status(500).json({ message: 'Error updating staff', error: error.message });
    }
});

// Route to get all staff members
router.get('/', async (req, res) => {
    try {
        const staffList = await Staff.find(); // Fetches all staff members
        res.status(200).json(staffList);
    } catch (error) {
        console.error('Error fetching staff:', error.message);
        res.status(500).json({ message: 'Error fetching staff list' });
    }
});

// DELETE route to delete staff by ID
router.delete('/:id', async (req, res) => {
    const { id } = req.params;
  
    try {
      // Find and delete the staff member by ID
      const staff = await Staff.findByIdAndDelete(id);
  
      if (!staff) {
        return res.status(404).json({ message: 'Staff not found' });
      }
  
      // Respond with success message
      return res.status(200).json({ message: 'Staff deleted successfully' });
    } catch (error) {
      // Handle errors and send an error message
      return res.status(500).json({ message: 'Failed to delete staff', error });
    }
  });

// Fetch users with the "Teacher" role
router.get('/teachers', async (req, res) => {
    try {
        const teachers = await User.find({ role: 'Teacher' });
        res.status(200).json(teachers);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching teachers', error: error.message });
    }
});

// Update teacher attendance
router.put('/attendance', async (req, res) => {
    const attendanceData = req.body.attendance;

    try {
        for (let i = 0; i < attendanceData.length; i++) {
            await User.findByIdAndUpdate(attendanceData[i]._id, {
                attendance: attendanceData[i].attendance, // Save attendance in the user document
            });
        }
        res.status(200).json({ message: 'Attendance updated successfully' });
    } catch (error) {
        res.status(500).json({ message: 'Error updating attendance', error: error.message });
    }
});

// Update user's role based on selected rights
router.put('/updateRole/:id', async (req, res) => {
    const userId = req.params.id;
    const newRole = req.body.role;

    try {
        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        user.role = newRole;
        await user.save();
        res.status(200).json({ message: 'User role updated successfully' });
    } catch (error) {
        res.status(500).json({ message: 'Error updating user role', error: error.message });
    }
});

module.exports = router;
