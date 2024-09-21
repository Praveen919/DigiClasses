const mongoose = require('mongoose');

const inquirySchema = new mongoose.Schema({
  studentName: { type: String, required: true },
  gender: { type: String, required: true },
  fatherMobile: { type: String },
  motherMobile: { type: String },
  studentMobile: { type: String },
  studentEmail: { type: String },
  schoolCollege: { type: String },
  university: { type: String },
  standard: { type: String, required: true },
  courseType: { type: String, required: true },
  referenceBy: { type: String },
  fileName: { type: String },
  inquiryDate: { type: Date, required: true },
  inquirySource: { type: String },
  inquiry: { type: String },
}, { timestamps: true });

module.exports = mongoose.model('Inquiry', inquirySchema);
