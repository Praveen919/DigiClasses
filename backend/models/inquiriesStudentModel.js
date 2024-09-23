const mongoose = require('mongoose');

const inquirySchema = new mongoose.Schema({
  subject: {
    type: String,
    required: true,
  },
  message: {
    type: String,
    required: true,
  },
  date: {
    type: Date,
    default: Date.now,
  },
  isReadByAdmin: {
    type: Boolean,
    default: false,
  },
  isReadByTeacher: {
    type: Boolean,
    default: false,
  },
});

module.exports = mongoose.model('InquiryStudent', inquirySchema);
