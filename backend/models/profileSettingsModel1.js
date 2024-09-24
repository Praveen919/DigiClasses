const mongoose = require('mongoose');

const ProfileSettingsSchema = new mongoose.Schema({
  instituteName: {
    type: String,
    required: true,
  },
  country: {
    type: String,
    required: true,
  },
  city: {
    type: String,
    required: true,
  },
  branchName: {
    type: String,
    required: true,
  },
  branchAddress: {
    type: String,
    required: true,
  },
  logoDisplay: {
    type: String,
    enum: ['Yes', 'No'],
    required: true,
  },
  chatOption: {
    type: String,
    enum: ['Yes', 'No'],
    required: true,
  },
  profileLogo: {
    type: String, // Store the file path or URL of the image
    required: false,
  },
  name: {
    type: String,
    required: true,
  },
  mobile: {
    type: String,
    required: true,
  },
  email: {
    type: String,
    required: true,
    match: [/^\S+@\S+\.\S+$/, 'Please provide a valid email address'],
  },
}, {
  timestamps: true, // Automatically add createdAt and updatedAt fields
});

module.exports = mongoose.model('ProfileSettings', ProfileSettingsSchema);
