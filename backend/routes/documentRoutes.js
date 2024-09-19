// routes/documentRoutes.js

const express = require('express');
const router = express.Router();
const Document = require('../models/documentModel'); // Adjust path as needed

// Share Document
router.post('/', async (req, res) => {
    const { standard, documentName } = req.body;
    try {
        const document = new Document({ standard, documentName });
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

// Update Document
router.put('/documents/:id', async (req, res) => {
    const { id } = req.params;
    const { standard, documentName } = req.body;
    try {
        const document = await Document.findByIdAndUpdate(id, { standard, documentName }, { new: true });
        if (!document) {
            return res.status(404).json({ error: 'Document not found' });
        }
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
