// models/examModel.js
const mongoose = require('mongoose');

const examSchema = new mongoose.Schema({
  standard: { type: String, required: true },
  subject: { type: String, required: true },
  examName: { type: String, required: true },
  totalMarks: { type: Number, required: true },
  examDate: { type: Date, required: true },
  fromTime: { type: String, required: true },
  toTime: { type: String, required: true },
  note: { type: String },
  remark: { type: String },
  documentPath: { type: String }, // To store file path
});

module.exports = mongoose.model('Exam', examSchema);
