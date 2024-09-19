const express = require('express');
const multer = require('multer');
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
        res.status(500).json({ message: 'Error creating staff', error });
    }
});

// Update staff
router.put('/:id', upload.single('profilePicture'), async (req, res) => {
    try {
        const staffData = {
            firstName: req.body.firstName,
            middleName: req.body.middleName,
            lastName: req.body.lastName,
            gender: req.body.gender,
            mobile: req.body.mobile,
            email: req.body.email,
            address: req.body.address,
        };

        // Check if a profile picture is provided in the update
        if (req.file) {
            staffData.profilePicture = req.file.path;
        }

        const staff = await Staff.findByIdAndUpdate(req.params.id, staffData, { new: true });

        if (!staff) {
            return res.status(404).json({ message: 'Staff not found' });
        }

        res.status(200).json({ message: 'Staff updated successfully', staff });
    } catch (error) {
        res.status(500).json({ message: 'Error updating staff', error });
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

// Fetch users with the "Teacher" role
router.get('/teachers', async (req, res) => {
  try {
    const teachers = await User.find({ role: 'Teacher' });
    res.status(200).json(teachers);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching teachers' });
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
    res.status(500).json({ message: 'Error updating attendance' });
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
    res.status(500).json({ message: 'Error updating user role' });
  }
});

module.exports = router;
