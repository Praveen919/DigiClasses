const mongoose = require('mongoose');
const express = require('express');
const router = express.Router();
const User = require('../models/userModel');
const ObjectId = mongoose.Types.ObjectId;
const {MessageStudent,StudentToAdminTeacherMessage,TeacherToStudentMessage,TeacherToAdminMessage,TeacherToStaffMessage,ExamNotification,
  AdminToTeacherMessage } = require('../models/messageStudentModel'); // Ensure the correct path to your model
const jwt = require('jsonwebtoken');

// JWT verification middleware
const verifyJWT = (req, res, next) => {
    const token = req.headers['authorization'];

    if (!token) {
        return res.status(403).json({ message: 'No token provided' });
    }

    jwt.verify(token.split(' ')[1], process.env.JWT_SECRET, (err, decoded) => {
        if (err) {
            return res.status(500).json({ message: 'Failed to authenticate token', error: err.message });
        }
        req.userId = decoded.id; // Store user ID from the token
        req.role = decoded.role; // Store user role
        console.log('Decoded JWT:', decoded); // Log for debugging
        next();
    });
};

/// POST route to send a message from admin to student
 router.post('/admin/messages', verifyJWT, async (req, res) => {
   const { studentId, subject, message } = req.body;

   // Log the incoming request data
   console.log('Received message request from admin:', { studentId, subject, message });

   // Validate required fields
   if (!studentId || !subject || !message) {
     return res.status(400).json({ error: 'All fields are required' });
   }

   // Check user role (only admins can send messages)
   if (req.role.toLowerCase() !== 'admin') {
     console.error('Access denied: User is not an admin');
     return res.status(403).json({ message: 'Access denied. Only admins can send messages.' });
   }

   try {
     // Create a new admin-to-student message
     const newMessage = new MessageStudent({
       studentId,
       subject,
       message,
       adminId: req.userId, // Store the admin's ID
       createdAt: new Date(),
     });

     // Save message to the database
     await newMessage.save();

     // Send success response
     res.status(201).json({ success: true, message: 'Message sent successfully', message: newMessage });
   } catch (err) {
     console.error('Error sending message to student:', err);
     res.status(500).json({ error: 'Server error while sending message' });
   }
 });


// POST route to send a message from student to admin/teacher
router.post('/student/messages', async (req, res) => {
  try {
    const { senderStudentId, recipientId, subject, message } = req.body;

    // Convert senderStudentId and recipientId to ObjectId
    const senderObjectId = ObjectId.isValid(senderStudentId) ? new ObjectId(senderStudentId) : null;
    const recipientObjectId = ObjectId.isValid(recipientId) ? new ObjectId(recipientId) : null;

    // Check if senderObjectId and recipientObjectId are valid
    if (!senderObjectId || !recipientObjectId) {
      return res.status(400).json({ success: false, message: 'Invalid sender or recipient ID.' });
    }

    // Create and save the message
    const newMessage = new StudentToAdminTeacherMessage({
      senderStudentId: senderObjectId,
      recipientId: recipientObjectId,
      subject,
      message,
    });

    await newMessage.save();
    res.status(200).json({ success: true, message: 'Message sent successfully.' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: 'Failed to send message.' });
  }
});

//POST to send message to admin from teacher
router.post('/teacher/admin/messages', verifyJWT, async (req, res) => {
  const { adminId, title, message } = req.body;

  // Log the incoming request data
  console.log('Received message request:', { adminId, title, message });

  // Validate required fields
  if (!adminId || !title || !message) {
    return res.status(400).json({ error: 'All fields are required' });
  }

  // Check user role
  if (req.role.toLowerCase() !== 'teacher') {
    console.error('Access denied: User is not a teacher');
    return res.status(403).json({ message: 'Access denied. Only teachers can submit messages to admins.' });
  }

  try {
    const user = await User.findById(req.userId);
    if (!user) {
      console.error('User not found:', req.userId);
      return res.status(404).json({ message: 'User not found' });
    }

    // Create a new teacher-to-admin message
    const newMessage = new TeacherToAdminMessage({
      adminId,
      title,
      message,
      submittedBy: req.userId, // Store the teacher's ID
      teacherId: user._id ,
      createdAt: new Date(),
    });

    // Save message to the database
    await newMessage.save();

    // Send success response
    res.status(201).json({ success: true, message: 'Message sent successfully', message: newMessage });
  } catch (err) {
    console.error('Error sending message to admin:', err);
    res.status(500).json({ error: 'Server error while sending message' });
  }
});


// Get messages sent by a teacher to an admin
router.get('/teacher/admin/messages', verifyJWT, async (req, res) => {
  try {
     // Check if the user is an admin
     if (req.role.toLowerCase() !== 'admin') {
       return res.status(403).json({ message: 'Access denied. Only admins can view messages.' });
     }

     // Fetch messages sent to the authenticated admin
     const messages = await TeacherToAdminMessage.find({ adminId: req.userId }).populate('teacherId', 'name');

     // Check if messages are found
     if (messages.length === 0) {
       return res.status(404).json({ message: 'No messages found' });
     }

     // Return the messages
     res.status(200).json({ success: true, messages });
   } catch (err) {
     console.error('Error fetching messages:', err);
     res.status(500).json({ error: 'Server error while fetching messages' });
   }
 });


// POST route to send a message from teacher to student
router.post('/teacher/messages', verifyJWT, async (req, res) => {
  const { studentId, title, message } = req.body;

  // Log the incoming request data
  console.log('Received message request from teacher:', { studentId, title, message });

  // Validate required fields
  if (!studentId || !title || !message) {
    return res.status(400).json({ error: 'All fields are required' });
  }

  // Check user role (only teachers can send messages)
  if (req.role.toLowerCase() !== 'teacher') {
    console.error('Access denied: User is not a teacher');
    return res.status(403).json({ message: 'Access denied. Only teachers can send messages.' });
  }

  try {
    // Create a new teacher-to-student message
    const newMessage = new TeacherToStudentMessage({
      studentId,
      title,
      message,
      teacherId: req.userId, // Store the teacher's ID
      createdAt: new Date(),
    });

    // Save message to the database
    await newMessage.save();

    // Send success response
    res.status(201).json({ success: true, message: 'Message sent successfully', message: newMessage });
  } catch (err) {
    console.error('Error sending message to student:', err);
    res.status(500).json({ error: 'Server error while sending message' });
  }
});


// POST route to send a message from teacher to staff
router.post('/teacher/staff/messages', async (req, res) => {
  const { teacherId,  title, message } = req.body; //staffId

  // Validate input
  if (!teacherId || !title || !message) {
    return res.status(400).json({ error: 'All fields are required' });
  }

  try {
    // Create a new teacher-to-staff message
    const newMessage = new TeacherToStaffMessage({
      teacherId,
     // staffId,
      title,
      message,
    });

    // Save message to the database
    await newMessage.save();

    // Send success response
    res.status(200).json({ success: true, message: 'Message sent successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error while sending message' });
  }
});


// POST route to send a message from admin to staff
router.post('/admin/staff', verifyJWT, async (req, res) => {
  const { staffId, subject, message } = req.body;

  // Log the incoming request data
  console.log('Received message request:', { staffId, subject, message });

  // Validate required fields
  if (!staffId || !message) {
    return res.status(400).json({ error: 'All fields are required' });
  }

  // Check user role
  if (req.role.toLowerCase() !== 'admin') {
    console.error('Access denied: User is not an admin');
    return res.status(403).json({ message: 'Access denied. Only admins can send messages to staff.' });
  }

  try {
    const user = await User.findById(req.userId);
    if (!user) {
      console.error('User not found:', req.userId);
      return res.status(404).json({ message: 'User not found' });
    }

    // Create a new admin-to-staff message
    const newMessage = new AdminToTeacherMessage({
      teacherId: staffId,
      subject: subject || '', // Optional subject
      message,
      submittedBy: req.userId, // Store the admin's ID
      adminId: user._id, // Assuming you want to store the admin ID too
      createdAt: new Date(),
    });

    // Save message to the database
    await newMessage.save();

    // Send success response
    res.status(201).json({ success: true, message: 'Message sent successfully', data: newMessage });
  } catch (err) {
    console.error('Error sending message to staff:', err);
    res.status(500).json({ error: 'Server error while sending message' });
  }
});

// GET route to retrieve messages sent from admin to staff/teacher
router.get('/staff/messages', verifyJWT, async (req, res) => {
  try {
    // Use the user ID from the JWT token
    const teacherId = req.userId; // This should be the authenticated teacher's ID

    // Log the incoming request data
    console.log('Received request to fetch messages for teacher:', { teacherId });

    // Check user role (allowing only teachers to fetch messages)
    const userRole = req.role.toLowerCase();
    if (userRole !== 'teacher') {
      console.error('Access denied: User is not a teacher');
      return res.status(403).json({ message: 'Access denied. Only teachers can fetch messages.' });
    }

    // Retrieve messages for the specified teacher (the authenticated teacher)
    const messages = await AdminToTeacherMessage.find({ teacherId })
      .populate('adminId', 'name') // Populate with admin's name
      .sort({ createdAt: -1 }); // Sort messages by createdAt in descending order

    // Transform messages to include relevant fields
    const transformedMessages = messages.map(message => ({
      adminId: message.adminId._id, // Sender's ID (admin ID)
      name: message.adminId.name, // Admin's name
      subject: message.subject, // Subject of the message
      message: message.message, // Message content
      date: message.timestamp, // Date when the message was sent
    }));

    // Check if messages exist
    if (transformedMessages.length === 0) {
      return res.status(404).json({ message: 'No messages found for this teacher.' });
    }

    // Send success response with transformed messages
    res.status(200).json({ success: true, messages: transformedMessages });
  } catch (err) {
    console.error('Error fetching messages for teacher:', err);
    res.status(500).json({ error: 'Server error while fetching messages' });
  }
});


// POST route to send exam notification
router.post('/exam/notifications', async (req, res) => {
  const { standard, subject, examName, date } = req.body;

  // Validate input
  if (!standard || !subject || !examName) {
    return res.status(400).json({ error: 'All fields are required' });
  }

  try {
    // Create a new exam notification
    const newNotification = new ExamNotification({
      standard,
      subject,
      examName,
      date,
    });

    // Save notification to the database
    await newNotification.save();

    // Send success response
    res.status(200).json({ success: true, message: 'Exam notification sent successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error while sending exam notification' });
  }
});


// GET route for retrieving messages sent to a specific student
router.get('/student/messages/:studentId', async (req, res) => {
  const { studentId } = req.params;

  try {
    const messages = await MessageStudent.find({ studentId }).populate('studentId');
    res.status(200).json(messages);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error retrieving student messages' });
  }
});


// GET route for retrieving messages sent from a student to admin/teacher
router.get('/student/to-admin-teacher/messages/:studentId', async (req, res) => {
  const { studentId } = req.params;

  try {
    const messages = await StudentToAdminTeacherMessage.find({ senderStudentId: studentId }).populate('recipientId');
    res.status(200).json(messages);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error retrieving student to admin/teacher messages' });
  }
});

// GET route for retrieving exam notifications
router.get('/exam/notifications', async (req, res) => {
  try {
    const notifications = await ExamNotification.find();
    res.status(200).json(notifications);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error retrieving exam notifications' });
  }
});

module.exports = router;
