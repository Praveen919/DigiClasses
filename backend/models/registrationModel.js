const mongoose = require('mongoose');

// Define the schema for student registration
const registrationSchema = new mongoose.Schema({
  firstName: { type: String, required: true },
  middleName: { type: String },
  lastName: { type: String, required: true },
  fatherName: { type: String },
  motherName: { type: String },
  fatherMobile: { type: String },
  motherMobile: { type: String },
  studentMobile: { type: String, required: true },
  studentEmail: { type: String, required: true, unique: true },
  address: { type: String },
  state: { type: String },
  city: { type: String },
  school: { type: String },
  university: { type: String },
  classBatch: { type: String },
  gender: { type: String, required: true },
  standard: { type: String, required: true },
  courseType: { type: String, required: true },
  birthDate: { type: Date, required: true },
  joinDate: { type: Date, required: true },
  profileImage: { type: String },
  printInquiry: { type: Boolean, default: false },
}, { timestamps: true });

const StudentRegistration = mongoose.model('StudentRegistration', registrationSchema);

module.exports = StudentRegistration;
