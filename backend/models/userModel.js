// models/userModel.js

const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
    instituteName: { type: String, required: true },
    country: { type: String, required: true },
    city: { type: String, required: true },
    name: { type: String, required: true },
    mobile: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    role: { type: String, enum: ['Admin', 'Teacher', 'Student'], required: true },
    branch: { type: String },  // New field for branch
    year: { type: String }     // New field for year
});

module.exports = mongoose.model('User', userSchema);
