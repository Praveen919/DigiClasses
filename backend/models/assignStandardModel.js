const mongoose = require('mongoose');

const assignedStandardSchema = new mongoose.Schema({
  standards: { type: [String], required: true },
});

const AssignedStandard = mongoose.model('AssignedStandard', assignedStandardSchema);

module.exports = AssignedStandard;
