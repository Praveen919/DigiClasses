<<<<<<< HEAD
const express = require('express');
const router = express.Router();
const ClassBatch = require('../models/classBatchModel');

// Create a new class/batch
router.post('/classbatch', async (req, res) => {
    try {
        const { classBatchName, strength, fromTime, toTime } = req.body;

        const newClassBatch = new ClassBatch({
            classBatchName,
            strength,
            fromTime,
            toTime
        });

        await newClassBatch.save();
        res.status(201).json({ message: 'Class/Batch created successfully!' });
    } catch (error) {
        res.status(400).json({ message: 'Error creating class/batch', error });
    }
});

// Get all class/batches
router.get('/', async (req, res) => {
    try {
        const classBatches = await ClassBatch.find();
        res.json(classBatches);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Get a specific class/batch by ID
router.get('/:id', async (req, res) => {
    try {
        const classBatch = await ClassBatch.findById(req.params.id);
        if (!classBatch) {
            return res.status(404).json({ message: 'ClassBatch not found' });
        }
        res.json(classBatch);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Update a class/batch by ID
router.put('/:id', async (req, res) => {
    try {
        const updatedClassBatch = await ClassBatch.findByIdAndUpdate(
            req.params.id,
            req.body,
            { new: true, runValidators: true }
        );
        if (!updatedClassBatch) {
            return res.status(404).json({ message: 'ClassBatch not found' });
        }
        res.json(updatedClassBatch);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
});

// Delete a class/batch by ID
router.delete('/:id', async (req, res) => {
    try {
        const deletedClassBatch = await ClassBatch.findByIdAndDelete(req.params.id);
        if (!deletedClassBatch) {
            return res.status(404).json({ message: 'ClassBatch not found' });
        }
        res.json({ message: 'ClassBatch deleted' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

module.exports = router;
=======
const express = require('express');
const router = express.Router();
const ClassBatch = require('../models/classBatchModel');

// Create a new class/batch
router.post('/classbatch', async (req, res) => {
    try {
        const { classBatchName, strength, fromTime, toTime } = req.body;

        const newClassBatch = new ClassBatch({
            classBatchName,
            strength,
            fromTime,
            toTime
        });

        await newClassBatch.save();
        res.status(201).json({ message: 'Class/Batch created successfully!' });
    } catch (error) {
        res.status(400).json({ message: 'Error creating class/batch', error });
    }
});

// Get all class/batches
router.get('/', async (req, res) => {
    try {
        const classBatches = await ClassBatch.find();
        res.json(classBatches);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Get a specific class/batch by ID
router.get('/:id', async (req, res) => {
    try {
        const classBatch = await ClassBatch.findById(req.params.id);
        if (!classBatch) {
            return res.status(404).json({ message: 'ClassBatch not found' });
        }
        res.json(classBatch);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Update a class/batch by ID
router.put('/:id', async (req, res) => {
    try {
        const updatedClassBatch = await ClassBatch.findByIdAndUpdate(
            req.params.id,
            req.body,
            { new: true, runValidators: true }
        );
        if (!updatedClassBatch) {
            return res.status(404).json({ message: 'ClassBatch not found' });
        }
        res.json(updatedClassBatch);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
});

// Delete a class/batch by ID
router.delete('/:id', async (req, res) => {
    try {
        const deletedClassBatch = await ClassBatch.findByIdAndDelete(req.params.id);
        if (!deletedClassBatch) {
            return res.status(404).json({ message: 'ClassBatch not found' });
        }
        res.json({ message: 'ClassBatch deleted' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

module.exports = router;
>>>>>>> cc5af9e141bdcffd7728c0c772999721e41a5e89
