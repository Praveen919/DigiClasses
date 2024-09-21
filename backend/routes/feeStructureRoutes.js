// routes/feeStructureRoutes.js

const express = require('express');
const router = express.Router();
const FeeStructure = require('../models/feeStructureModel'); // Adjust path as needed

// Create Fee Structure
router.post('/', async (req, res) => {
    try {
        const feeStructure = new FeeStructure(req.body);
        await feeStructure.save();
        res.status(201).send(feeStructure);
    } catch (error) {
        res.status(400).send(error);
    }
});

// Get All Fee Structures
router.get('/', async (req, res) => {
    try {
        const feeStructures = await FeeStructure.find();
        res.status(200).send(feeStructures);
    } catch (error) {
        res.status(500).send(error);
    }
});

// Update Fee Structure
router.put('/:id', async (req, res) => {
    try {
        const feeStructure = await FeeStructure.findByIdAndUpdate(req.params.id, req.body, { new: true, runValidators: true });
        if (!feeStructure) {
            return res.status(404).send('Fee structure not found');
        }
        res.send(feeStructure);
    } catch (error) {
        res.status(400).send(error);
    }
});

// Delete Fee Structure
router.delete('/:id', async (req, res) => {
    try {
        const feeStructure = await FeeStructure.findByIdAndDelete(req.params.id);
        if (!feeStructure) {
            return res.status(404).send('Fee structure not found');
        }
        res.send(feeStructure);
    } catch (error) {
        res.status(500).send(error);
    }
});

module.exports = router;
