const mongoose = require('mongoose');

const assignedStandardSchema = new mongoose.Schema({
  assignedStandards: {
    type: [String],
    required: true,
  },
  otherRequirements: {
    type: Boolean,
    default: false,
  },
}, { timestamps: true });

module.exports = mongoose.model('AssignedStandard', assignedStandardSchema);
