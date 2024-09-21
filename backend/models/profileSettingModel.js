const mongoose = require('mongoose');

const profileSettingsSchema = new mongoose.Schema({
    instituteName: { type: String },
    country: { type: String },
    city: { type: String },
    branchName: { type: String },
    feeRecHeader: { type: String },
    branchAddress: { type: String },
    taxNo: { type: String },
    feeFooter: { type: String },
    logoDisplay: { type: String },
    feeStatusDisplay: { type: String },
    chatOption: { type: String },
    name: { type: String },
    mobile: { type: String },
    email: { type: String, required: true, match: [/.+@.+\..+/, 'Invalid email format'] },
    year: { type: String },
    profileLogo: { type: String } // Optional: URL or filename of the uploaded profile logo
});

module.exports = mongoose.model('ProfileSettings', profileSettingsSchema);
