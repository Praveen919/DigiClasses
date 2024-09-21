<<<<<<< HEAD
const express = require('express');
const multer = require('multer');
const path = require('path');
const router = express.Router();
const Document = require('../models/documentModel'); // Adjust the path as needed

// Multer configuration for file storage
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, 'uploads/'); // Directory where files are stored
    },
    filename: function (req, file, cb) {
        cb(null, file.fieldname + '-' + Date.now() + path.extname(file.originalname)); // Unique file name
    }
});

const upload = multer({ storage: storage });

// Share Document (with file upload)
router.post('/', upload.single('file'), async (req, res) => {
    const { standard, documentName, message } = req.body;
    const file = req.file;

    try {
        if (!file) {
            return res.status(400).json({ error: 'No file uploaded' });
        }

        const document = new Document({
            standard,
            documentName: file.originalname, // Save the original file name
            documentPath: file.path, // Path where the file is stored
            message
        });

        await document.save();
        res.status(201).json(document);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

// Get All Documents
router.get('/documents', async (req, res) => {
    try {
        const documents = await Document.find();
        res.json(documents);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Get a Single Document by ID
router.get('/documents/:id', async (req, res) => {
    try {
        const document = await Document.findById(req.params.id);
        if (!document) {
            return res.status(404).json({ error: 'Document not found' });
        }
        res.json(document);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Update Document (supports file update)
router.put('/documents/:id', upload.single('file'), async (req, res) => {
    const { id } = req.params;
    const { standard, documentName, message } = req.body;
    const file = req.file; // New file (if any) from the request

    try {
        // Find the document by ID first
        let document = await Document.findById(id);
        if (!document) {
            return res.status(404).json({ error: 'Document not found' });
        }

        // If a new file is uploaded, update the document path and name
        if (file) {
            document.documentPath = file.path;
            document.documentName = file.originalname;
        }

        // Update other fields
        document.standard = standard || document.standard;
        document.message = message || document.message;

        // Save updated document
        await document.save();
        res.json(document);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

// Delete Document
router.delete('/documents/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const document = await Document.findByIdAndDelete(id);
        if (!document) {
            return res.status(404).json({ error: 'Document not found' });
        }
        res.json({ message: 'Document deleted' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
=======
const express = require('express');
const multer = require('multer');
const path = require('path');
const router = express.Router();
const Document = require('../models/documentModel'); // Adjust the path as needed

// Multer configuration for file storage
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, 'uploads/'); // Directory where files are stored
    },
    filename: function (req, file, cb) {
        cb(null, file.fieldname + '-' + Date.now() + path.extname(file.originalname)); // Unique file name
    }
});

const upload = multer({ storage: storage });

// Share Document (with file upload)
router.post('/', upload.single('file'), async (req, res) => {
    const { standard, documentName, message } = req.body;
    const file = req.file;

    try {
        if (!file) {
            return res.status(400).json({ error: 'No file uploaded' });
        }

        const document = new Document({
            standard,
            documentName: file.originalname, // Save the original file name
            documentPath: file.path, // Path where the file is stored
            message
        });

        await document.save();
        res.status(201).json(document);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

// Get All Documents
router.get('/documents', async (req, res) => {
    try {
        const documents = await Document.find();
        res.json(documents);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Get a Single Document by ID
router.get('/documents/:id', async (req, res) => {
    try {
        const document = await Document.findById(req.params.id);
        if (!document) {
            return res.status(404).json({ error: 'Document not found' });
        }
        res.json(document);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Update Document (supports file update)
router.put('/documents/:id', upload.single('file'), async (req, res) => {
    const { id } = req.params;
    const { standard, documentName, message } = req.body;
    const file = req.file; // New file (if any) from the request

    try {
        // Find the document by ID first
        let document = await Document.findById(id);
        if (!document) {
            return res.status(404).json({ error: 'Document not found' });
        }

        // If a new file is uploaded, update the document path and name
        if (file) {
            document.documentPath = file.path;
            document.documentName = file.originalname;
        }

        // Update other fields
        document.standard = standard || document.standard;
        document.message = message || document.message;

        // Save updated document
        await document.save();
        res.json(document);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

// Delete Document
router.delete('/documents/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const document = await Document.findByIdAndDelete(id);
        if (!document) {
            return res.status(404).json({ error: 'Document not found' });
        }
        res.json({ message: 'Document deleted' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
>>>>>>> cc5af9e141bdcffd7728c0c772999721e41a5e89
