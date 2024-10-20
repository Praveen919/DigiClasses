const mongoose = require('mongoose');

const feedbackSchema = new mongoose.Schema({
    studentId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: false }, // Optional
    teacherId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: false }, // Optional
    staffId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: false },   // Optional
    subject: { type: String, required: true },  // Subject of feedback
    feedback: { type: String, required: true }, // Actual feedback content
    createdAt: { type: Date, default: Date.now }, // Creation timestamp
});

module.exports = mongoose.model('Feedback', feedbackSchema);
