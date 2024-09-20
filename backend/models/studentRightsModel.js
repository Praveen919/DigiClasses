// models/StudentRights.js
const mongoose = require('mongoose');

// Define the schema for user roles and rights
const studentRightsSchema = new mongoose.Schema({
  role: {
    type: String,
    required: true,
    default: 'Student',
  },
  rights: {
    type: Map,
    of: Boolean,
  },
});

// Export the model
module.exports = mongoose.model('StudentRights', studentRightsSchema);
