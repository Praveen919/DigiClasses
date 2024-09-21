const mongoose = require('mongoose');

const studentSchema = new mongoose.Schema({
  name: String,
  rollNumber: String,
  classBatch: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'ClassBatch',
    default: null
  }
});

module.exports = mongoose.model('Student', studentSchema);
