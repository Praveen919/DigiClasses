<<<<<<< HEAD
const mongoose = require('mongoose');

const classBatchSchema = new mongoose.Schema({
  classBatchName: { type: String, required: true },
  strength: { type: Number, required: true }, // Class capacity
  fromTime: { type: String, required: true }, // Start time
  toTime: { type: String, required: true },   // End time
  assignedStudents: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Student' }] // List of students assigned
});

module.exports = mongoose.model('ClassBatch', classBatchSchema);
=======
const mongoose = require('mongoose');

const classBatchSchema = new mongoose.Schema({
  classBatchName: { type: String, required: true },
  strength: { type: Number, required: true }, // Class capacity
  fromTime: { type: String, required: true }, // Start time
  toTime: { type: String, required: true },   // End time
  assignedStudents: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Student' }] // List of students assigned
});

module.exports = mongoose.model('ClassBatch', classBatchSchema);
>>>>>>> cc5af9e141bdcffd7728c0c772999721e41a5e89
