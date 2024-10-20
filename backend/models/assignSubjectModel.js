const mongoose = require('mongoose');

const AssignedSubjectSchema = new mongoose.Schema({
  assignedSubjects: {
    type: [String],
    required: true,
  },
  otherRequirements: {
    type: Boolean,
    default: false,
  },
}, { timestamps: true });

module.exports = mongoose.model('AssignedSubject', AssignedSubjectSchema);
