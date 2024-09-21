const mongoose = require('mongoose');

// Define the schema for Study Material
const studyMaterialSchema = new mongoose.Schema({
    courseName: {
        type: String,
        required: true
    },
    standard: {
        type: String,
        required: true
    },
    subject: {
        type: String,
        required: true
    },
    fileName: {
        type: String,
        default: null
    },
    filePath: {
        type: String,
        default: null
    }
});

// Create the model from the schema
const StudyMaterial = mongoose.model('StudyMaterial', studyMaterialSchema);

module.exports = StudyMaterial;
