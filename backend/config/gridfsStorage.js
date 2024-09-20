const multer = require('multer');
const { GridFsStorage } = require('multer-gridfs-storage');
const crypto = require('crypto');
const path = require('path');
require('dotenv').config(); // Ensure environment variables are loaded

// MongoDB connection URL from environment variable
const mongoURI = process.env.MONGODB_URI;

// Create GridFS storage engine
const storage = new GridFsStorage({
  url: mongoURI,
  options: { useNewUrlParser: true, useUnifiedTopology: true }, // Necessary MongoDB options
  file: (req, file) => {
    return new Promise((resolve, reject) => {
      // Generate a random filename using crypto
      crypto.randomBytes(16, (err, buf) => {
        if (err) {
          return reject(err);
        }
        // Create a unique filename by appending the original file extension
        const filename = `${buf.toString('hex')}${path.extname(file.originalname)}`;

        // Set file information for GridFS
        const fileInfo = {
          filename: filename,
          bucketName: 'uploads' // Collection in MongoDB where files will be stored
        };
        resolve(fileInfo); // Return the file information
      });
    });
  }
});

// File filter to allow only specific image formats
const fileFilter = (req, file, cb) => {
  const allowedMimeTypes = ['image/jpeg', 'image/png', 'image/gif'];
  if (allowedMimeTypes.includes(file.mimetype)) {
    cb(null, true); // Accept the file
  } else {
    cb(new Error('Invalid file type. Only JPEG, PNG, and GIF are allowed.'), false); // Reject the file
  }
};

// Setup multer with the storage engine and file filter
const upload = multer({
  storage,
  fileFilter,
  limits: { fileSize: 5 * 1024 * 1024 } // Limit file size to 5MB
});

module.exports = upload;
