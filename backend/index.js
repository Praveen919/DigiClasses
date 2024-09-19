require('dotenv').config(); // Load environment variables from .env file
const express = require('express');
const app = express();
const cors = require('cors'); // Include CORS middleware if needed
const bodyParser = require('body-parser'); // Include body-parser middleware for parsing request bodies
const mongoose = require('mongoose'); // Ensure mongoose is required for MongoDB operations

// Import configuration and storage
const cfg = require('./config/config');
const storage = require('./config/gridfsStorage'); // Initialize GridFS if needed

// Import existing routes
const authRoutes = require('./routes/authRoutes');
const staffRoutes = require('./routes/staffRoutes');
const studyMaterialRoutes = require('./routes/studyMaterialRoutes');
const passwordRoutes = require('./routes/passwordRoutes');
const autoNotificationSettingRoutes = require('./routes/autoNotificationSettingRoutes');
const classBatchRoutes = require('./routes/classBatchRoutes');
const manageTimeTableRoutes = require('./routes/manageTimeTableRoutes');

// Import updated and new routes
const mcqExamRoutes = require('./routes/mcqExamRoutes');
const examRoutes = require('./routes/examRoutes');
const assignmentRoutes = require('./routes/assignmentRoutes');
const documentRoutes = require('./routes/documentRoutes');
const feeStructureRoutes = require('./routes/feeStructureRoutes');
const profileSettingRoutes = require('./routes/profileSettingRoutes'); // Updated to reflect direct user updates
const autoWhatsappSettingRoutes = require('./routes/autoWhatsappSettingRoutes');
const yearRoutes = require('./routes/yearRoutes');
const assignStandardRoutes = require('./routes/assignStandardRoutes');
const assignSubjectRoutes = require('./routes/assignSubjectRoutes');
const expenseIncomeRoutes = require('./routes/expenseIncomeRoutes');
const inquiryRoutes = require('./routes/inquiryRoutes');
const registrationRoutes = require('./routes/registrationRoutes');

// Middleware setup
app.use(cors()); // Enable CORS if needed
app.use(bodyParser.json()); // Parse application/json
app.use(bodyParser.urlencoded({ extended: true })); // Parse application/x-www-form-urlencoded

// Serve static files
app.use('/uploads', express.static('uploads')); // Adjust path if needed

// Use existing routes
app.use('/api/auth', authRoutes);
app.use('/api/staff', staffRoutes);
app.use('/api/users', staffRoutes); // Adjust if 'users' is different from 'staff'
app.use('/api/study-material', studyMaterialRoutes);
app.use('/api/password', passwordRoutes);
app.use('/api/years', yearRoutes);
app.use('/api/timetable', manageTimeTableRoutes);

// Use updated/new routes
app.use('/api/profile-settings', profileSettingRoutes); // Updated route for profile settings
app.use('/api/expenses', expenseIncomeRoutes); // Ensure this route is correctly defined

// Use other new routes
app.use('/api/mcq-exams', mcqExamRoutes);
app.use('/api/exams', examRoutes); // Ensure this route is correctly defined
app.use('/api/assignments', assignmentRoutes);
app.use('/api/documents', documentRoutes);
app.use('/api/fee-structures', feeStructureRoutes);
app.use('/api/class-batch', classBatchRoutes);
app.use('/api/notification-settings', autoNotificationSettingRoutes);
app.use('/api/whatsapp-settings', autoWhatsappSettingRoutes);
app.use('/api/assignStandard', assignStandardRoutes);
app.use('/api/assignSubject', assignSubjectRoutes);
app.use('/api/inquiries', inquiryRoutes);
app.use('/api/registration', registrationRoutes);

// Connect to MongoDB (Make sure the connection string is correct in your config file)
mongoose.connect(cfg.mongoURI, { useNewUrlParser: true, useUnifiedTopology: true })
  .then(() => console.log('MongoDB connected'))
  .catch(err => console.error('MongoDB connection error:', err));

// Start the server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
