const mongoose = require('mongoose');

const classBatchSchema = new mongoose.Schema({
  classBatchName: { type: String, required: true },
  strength: { type: Number, required: true },
  fromTime: { type: String, required: true }, // Store time as string
  toTime: { type: String, required: true },   // Store time as string
});

module.exports = mongoose.model('ClassBatch', classBatchSchema);
