const express = require('express');
const router = express.Router();
const AutoWhatsappSetting = require('../models/autoWhatsappSettingModel');

// Fetch settings for a specific user
router.get('/:userId', async (req, res) => {
  try {
    const settings = await AutoWhatsappSetting.findOne({ userId: req.params.userId });
    if (!settings) {
      return res.status(404).json({ message: 'Settings not found' });
    }
    res.json(settings);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Update settings for a specific user
router.post('/:userId', async (req, res) => {
  try {
    const settings = await AutoWhatsappSetting.findOneAndUpdate(
      { userId: req.params.userId },
      req.body,
      { new: true, upsert: true }
    );
    res.json(settings);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
