const mongoose = require('mongoose');

const feedbackSchema = new mongoose.Schema({
    studentId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },  //removed required: true
    teacherId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' }, // added for tchr side feedback to post to admin
    subject: { type: String, required: true },
    feedback: { type: String, required: true },
    createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('Feedback', feedbackSchema);
