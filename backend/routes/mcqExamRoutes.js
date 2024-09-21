const express = require('express');
const router = express.Router();
const { MCQExam } = require('../models/mcqExamModel');

// Create MCQ Exam
router.post('/', async (req, res) => {
  try {
    const { paperName, standard, subject, examPaperType } = req.body;
    const newExam = new MCQExam({ paperName, standard, subject, examPaperType });
    await newExam.save();
    res.status(201).json({ exam: newExam });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// Get All MCQ Exams
router.get('/', async (req, res) => {
  try {
    const exams = await MCQExam.find();
    res.status(200).json(exams);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get MCQ Exam by ID
router.get('/:id', async (req, res) => {
  try {
    const exam = await MCQExam.findById(req.params.id);
    if (!exam) return res.status(404).json({ message: 'Exam not found' });
    res.status(200).json(exam);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Update MCQ Exam by ID
router.put('/:id', async (req, res) => {
  try {
    const updatedExam = await MCQExam.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!updatedExam) return res.status(404).json({ message: 'Exam not found' });
    res.status(200).json(updatedExam);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// Delete MCQ Exam by ID
router.delete('/:id', async (req, res) => {
  try {
    const deletedExam = await MCQExam.findByIdAndDelete(req.params.id);
    if (!deletedExam) return res.status(404).json({ message: 'Exam not found' });
    res.status(200).json({ message: 'Exam deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Add Questions to MCQ Exam
router.post('/:id/questions', async (req, res) => {
  try {
    const exam = await MCQExam.findById(req.params.id);
    if (!exam) return res.status(404).json({ message: 'Exam not found' });

    exam.questions.push(...req.body.questions);
    await exam.save();
    res.status(200).json(exam);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// Update an MCQ question in an exam
router.put('/:examId/questions/:questionId', async (req, res) => {
  const { examId, questionId } = req.params;
  const { question, options, correctAnswer } = req.body;

  try {
    const mcqExam = await MCQExam.findById(examId);
    if (!mcqExam) {
      return res.status(404).json({ message: 'Exam not found' });
    }

    const questionIndex = mcqExam.questions.findIndex(q => q._id.toString() === questionId);
    if (questionIndex === -1) {
      return res.status(404).json({ message: 'Question not found' });
    }

    mcqExam.questions[questionIndex] = {
      ...mcqExam.questions[questionIndex]._doc, // Retain original properties
      question,
      options,
      correctAnswer
    };

    await mcqExam.save();
    res.status(200).json(mcqExam);
  } catch (error) {
    console.error('Error updating question:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Delete a question from an exam
router.delete('/:examId/questions/:questionId', async (req, res) => {
  const { examId, questionId } = req.params;

  try {
    const result = await MCQExam.updateOne(
      { _id: examId },
      { $pull: { questions: { _id: questionId } } }
    );

    if (result.modifiedCount === 0) {
      return res.status(404).json({ message: 'Question not found' });
    }

    res.status(200).json({ message: 'Question deleted successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
});

module.exports = router;
