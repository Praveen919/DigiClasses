const express = require('express');
const router = express.Router();
const AutoNotificationSetting = require('../models/autoNotificationSettingModel');

// Get notification settings by userId
router.get('/:userId', async (req, res) => {
  try {
    const settings = await AutoNotificationSetting.findOne({ userId: req.params.userId });
    if (!settings) {
      return res.status(404).json({ message: 'Settings not found' });
    }
    res.json(settings);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Save or update notification settings
router.post('/:userId', async (req, res) => {
  const { userId } = req.params;
  const settingsData = req.body;

  try {
    let settings = await AutoNotificationSetting.findOne({ userId });
    if (settings) {
      // Update existing settings
      Object.assign(settings, settingsData);
    } else {
      // Create new settings
      settings = new AutoNotificationSetting({ userId, ...settingsData });
    }
    await settings.save();
    res.status(200).json(settings);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
