// models/feeStructureModel.js

const mongoose = require('mongoose');

const feeStructureSchema = new mongoose.Schema({
    standard: {
        type: String,
        required: true
    },
    courseType: {
        type: String,
        required: true
    },
    feeAmount: {
        type: String,
        required: true
    },
    remark: String
});

module.exports = mongoose.model('FeeStructure', feeStructureSchema);
