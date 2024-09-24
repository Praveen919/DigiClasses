const mongoose = require('mongoose');

const staffRightsSchema = new mongoose.Schema({
  staffId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Staff', 
    required: true 
  },
  role: {
    type: String,
    enum: ['Admin', 'Teacher', 'Student'],
    default: 'Teacher',
    required: true
  },
  assignedAt: {
    type: Date,
    default: Date.now
  }
});

const StaffRights = mongoose.model('StaffRights', staffRightsSchema);

module.exports = StaffRights;
