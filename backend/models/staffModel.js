const mongoose = require('mongoose');

const staffSchema = new mongoose.Schema({
    firstName: { type: String, required: true },
    middleName: { type: String },
    lastName: { type: String, required: true },
    gender: { type: String, required: true },
    mobile: { type: String, required: true },
    email: { type: String, required: true },
    address: { type: String },
    profilePicture: { type: String }, // Field for storing the profile picture path
});

module.exports = mongoose.model('Staff', staffSchema);
