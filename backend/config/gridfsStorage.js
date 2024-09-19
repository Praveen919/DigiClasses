const multer = require('multer');
const { GridFsStorage } = require('multer-gridfs-storage'); // Ensure this is correct
const crypto = require('crypto');
const path = require('path');

// MongoDB connection URL
const mongoURI = process.env.MONGODB_URI;

// Create storage engine
const storage = new GridFsStorage({
  url: mongoURI,
  options: { useNewUrlParser: true, useUnifiedTopology: true }, // Add options if needed
  file: (req, file) => {
    return new Promise((resolve, reject) => {
      crypto.randomBytes(16, (err, buf) => {
        if (err) {
          return reject(err);
        }
        const filename = buf.toString('hex') + path.extname(file.originalname);
        const fileInfo = {
          filename: filename,
          bucketName: 'uploads' // Set bucket name for GridFS
        };
        resolve(fileInfo);
      });
    });
  }
});

const upload = multer({ storage });

module.exports = upload;
