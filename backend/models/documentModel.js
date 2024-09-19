// models/documentModel.js

const mongoose = require('mongoose');

const documentSchema = new mongoose.Schema({
    standard: { type: String, required: true },
    documentName: { type: String, required: true },
    // Additional fields can be added as needed
});

module.exports = mongoose.model('Document', documentSchema);
