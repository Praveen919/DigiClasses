// models/assignmentModel.js

const mongoose = require('mongoose');

const assignmentSchema = new mongoose.Schema({
    standard: {
        type: String,
        required: true,
        trim: true,
    },
    subject: {
        type: String,
        required: true,
        trim: true,
    },
    assignmentName: {
        type: String,
        required: true,
        trim: true,
    },
    dueDate: {
        type: String, // Use String to match 'dd-mm-yyyy' format
        required: true,
        trim: true,
    },
    fileName: {
        type: String,
        trim: true,
    },
    file: {
        type: String, // Store the file path or URL
        trim: true,
    },
}, {
    timestamps: true, // Adds createdAt and updatedAt fields
});

module.exports = mongoose.model('Assignment', assignmentSchema);
