const mongoose = require('mongoose');
const express = require('express');
const router = express.Router();
const ClassBatch = require('../models/classBatchModel');
const User = require('../models/userModel'); // Assuming you have a User model
const jwt = require('jsonwebtoken');

// JWT verification middleware
const verifyJWT = (req, res, next) => {
  const token = req.headers['authorization']?.split(' ')[1]; // Extract token from Authorization header

  if (!token) {
    return res.status(403).json({ message: 'No token provided' });
  }

  jwt.verify(token, process.env.JWT_SECRET, (err, decoded) => {
    if (err) {
      return res.status(401).json({ message: 'Unauthorized' });
    }
    req.userId = decoded.id; // Store the user ID (student) in the request
    next(); // Proceed to the next middleware or route handler
  });
};

// Fetch all classes/batches
router.get('/classes', async (req, res) => {
  try {
    const classes = await ClassBatch.find();
    res.json(classes);
  } catch (error) {
    console.error('Error fetching classes:', error); // Log the error for debugging
    res.status(500).json({ message: 'Server Error' });
  }
});

// Assign a class/batch to a user (student) by user ID from the token
router.post('/assign', verifyJWT, async (req, res) => {
  const { classBatchId } = req.body; // Get classBatchId from request body
  const userId = req.userId; // Get userId from the authenticated user's token
  try {
    // Fetch the user (student) by ID from the token
    const user = await User.findById(userId);

    if (!user) {
      console.error(`User with ID ${userId} not found`); // More specific logging
      return res.status(404).json({ message: 'User not found' });
    }

    // Fetch the class batch directly using the provided ID
    const classBatch = await ClassBatch.findById(classBatchId);

    if (!classBatch) {
      console.error(`ClassBatch with ID ${classBatchId} not found`); // More specific logging
      return res.status(404).json({ message: 'Class/Batch not found' });
    }

    // Check if the user is already assigned to the specified class/batch
    if (user.classBatch && user.classBatch.toString() === classBatchId) {
      return res.status(400).json({ message: 'Student is already assigned to this class/batch' });
    }

    // Update the user's class/batch assignment
    user.classBatch = classBatchId; // If you're keeping this in User model as well
    await user.save();

    // Check if the user is already in assignedStudents
    if (!classBatch.assignedStudents.includes(user._id)) {
      classBatch.assignedStudents.push(user._id);
      await classBatch.save();
    }

    res.json({ message: 'Class/Batch assigned to user successfully' });
  } catch (error) {
    console.error('Error in assigning class/batch:', error); // Log error for debugging
    res.status(500).json({ message: 'Server Error' });
  }
});

// Fetch users (students) assigned to a specific class/batch
router.get('/students/:classBatchId', async (req, res) => {
  const { classBatchId } = req.params;

  try {
    const users = await User.find({ classBatch: classBatchId });
    res.json(users);
  } catch (error) {
    console.error('Error fetching students:', error); // Log the error for debugging
    res.status(500).json({ message: 'Server Error' });
  }
});

// Remove a user (student) from a class/batch
router.post('/remove', verifyJWT, async (req, res) => {
  const { classBatchId } = req.body; // Get classBatchId from request body
  const userId = req.userId; // Get userId from the authenticated user's token

  try {
      // Fetch the user by ID using userId from the User model
      const user = await User.findById(userId); // Use userId to find the User

      if (!user) {
          console.error(`User with ID ${userId} not found`); // Log if user not found
          return res.status(404).json({ message: 'User not found' });
      }

      // Check if the user is currently assigned to the specified class/batch
      if (!user.classBatch || user.classBatch.toString() !== classBatchId) {
          return res.status(400).json({ message: 'Student is not assigned to this class/batch' });
      }

      // Remove the class/batch assignment
      user.classBatch = null; // Indicating no assignment
      await user.save();

      // Fetch the class batch to remove the user from assignedStudents array
      const classBatch = await ClassBatch.findById(classBatchId);
      if (!classBatch) {
          console.error(`ClassBatch with ID ${classBatchId} not found`); // Log if classBatch not found
          return res.status(404).json({ message: 'Class/Batch not found' });
      }

      // Remove the userId from the assignedStudents array
      classBatch.assignedStudents.pull(user._id); // Use user._id here for consistency
      await classBatch.save();

      res.json({ message: 'User removed from class/batch successfully' });
  } catch (error) {
      console.error('Error in removing user from class/batch:', error); // Log error for debugging
      res.status(500).json({ message: 'Server Error' });
  }
});

module.exports = router;
