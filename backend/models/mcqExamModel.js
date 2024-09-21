const mongoose = require('mongoose');

// Define schema for MCQ questions
const mcqQuestionSchema = new mongoose.Schema({
  question: { type: String, required: true },
  options: [{ type: String, required: true }],
  correctAnswer: { type: Number, required: true }
});

// Define schema for MCQ exam
const mcqExamSchema = new mongoose.Schema({
  paperName: { type: String, required: true },
  standard: { type: String, required: true },
  subject: { type: String, required: true },
  examPaperType: { type: String, required: true },
  questions: [mcqQuestionSchema] // Embedded questions schema
});

const MCQExam = mongoose.model('MCQExam', mcqExamSchema);
const MCQQuestion = mongoose.model('MCQQuestion', mcqQuestionSchema);

module.exports = { MCQExam, MCQQuestion };
