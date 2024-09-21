const mongoose = require('mongoose');

// Create the schema for Subject assignment
const subjectSchema = new mongoose.Schema({
  assignedSubjects: {
    type: [String],  // Array of subject names
    required: true,
  },
});

// Create and export the Subject model
const Subject = mongoose.model('Subject', subjectSchema);
module.exports = Subject;
