require('dotenv').config(); // Load environment variables from .env file
const express = require('express');
const app = express();
const cors = require('cors'); // Include CORS middleware if needed
const bodyParser = require('body-parser'); // Include body-parser middleware for parsing request bodies

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
const assignClassBatchRoutes = require('./routes/assignClassBatchRoutes');
const studentRoutes = require('./routes/studentRoutes');
const attendanceRoutes = require('./routes/attendanceRoutes');
const messageStudentRoutes = require('./routes/messageStudentRoutes');
const feedbacksRoutes = require('./routes/feedbacksRoutes');
const studentRightsRoutes = require('./routes/studentRightsRoutes');
const feeCollectionRoutes = require('./routes/feeCollectionRoutes');
const messageStudentIdPassRoutes = require('./routes/messageStudentIdPassRoutes');
const inquiriesStudentRoutes = require('./routes/inquiriesStudentRoutes');
const absenceMessageRoutes = require ('./routes/absenceMessageRoutes');
const cardReportRoutes = require('./routes/cardReportRoutes');
const staffRightsRoutes = require('./routes/staffRightsRoutes');
const forgotPasswordRoutes = require('./routes/forgotPasswordRoutes');
const logbookTRoutes = require('./routes/logbookTRoutes');

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
app.use('/api/attendance', attendanceRoutes);
// Use updated/new routes
app.use('/api/profile-settings', profileSettingRoutes); // Updated route for profile settings
app.use('/api/expenses', expenseIncomeRoutes);
app.use('/api/messageStudent', messageStudentRoutes);
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
app.use('/api/assignClassBatch', assignClassBatchRoutes);
app.use('/api/student', studentRoutes);
app.use('/api/feedbacks', feedbacksRoutes);
app.use('/api/assign-rights', studentRightsRoutes);
app.use('./api/feeCollection', feeCollectionRoutes);
app.use('/api/messageStudentIdPass', messageStudentIdPassRoutes);
app.use('/api/inquiriesStudent', inquiriesStudentRoutes);
app.use('/api/absenceMessage', absenceMessageRoutes);
app.use('/api/cardReport', cardReportRoutes);
app.use('/api/staff-rights', staffRightsRoutes);
app.use ('/api/forgotPass', forgotPasswordRoutes);
app.use('/api/logbook', logbookTRoutes); 

// Start the server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
