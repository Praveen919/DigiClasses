const mongoose = require('mongoose');
const bcrypt = require('bcrypt');

// Define the user schema
const userSchema = new mongoose.Schema({
    instituteName: { type: String, required: true },
    country: { type: String, required: true },
    city: { type: String, required: true },
    name: { type: String, required: true },
    mobile: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    role: { type: String, enum: ['Admin', 'Teacher', 'Student'], required: true },
    branch: { type: String },  // Optional field for branch
    year: { type: String },    // Optional field for year

    // Class batch field, optional
    classBatch: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'ClassBatch',
        default: null // Default to null if not assigned
    },

    // Password reset fields
    resetPasswordToken: String,
    resetPasswordExpires: Date
});

// Method to hash password before saving the user
userSchema.pre('save', async function (next) {
    if (!this.isModified('password')) return next(); // Skip if password is not modified
    try {
        const salt = await bcrypt.genSalt(10);
        this.password = await bcrypt.hash(this.password, salt); // Hash the password
        next();
    } catch (err) {
        next(err);
    }
});

// Export the consolidated User model
module.exports = mongoose.model('User', userSchema);
