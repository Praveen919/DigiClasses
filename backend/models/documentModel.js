<<<<<<< HEAD
const mongoose = require('mongoose');

const documentSchema = new mongoose.Schema({
    standard: { type: String, required: true }, // Class/Batch
    documentName: { type: String, required: true }, // Original file name
    documentPath: { type: String, required: true }, // Path where file is stored
    message: { type: String, required: true }, // Message associated with the document
    uploadedAt: { type: Date, default: Date.now }, // Timestamp for when the document was uploaded
});

module.exports = mongoose.model('Document', documentSchema);
=======
const mongoose = require('mongoose');

const documentSchema = new mongoose.Schema({
    standard: { type: String, required: true }, // Class/Batch
    documentName: { type: String, required: true }, // Original file name
    documentPath: { type: String, required: true }, // Path where file is stored
    message: { type: String, required: true }, // Message associated with the document
    uploadedAt: { type: Date, default: Date.now }, // Timestamp for when the document was uploaded
});

module.exports = mongoose.model('Document', documentSchema);
>>>>>>> cc5af9e141bdcffd7728c0c772999721e41a5e89
