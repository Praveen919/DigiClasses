const express = require('express');
const router = express.Router();
const AutoNotificationSetting = require('../models/autoNotificationSettingModel');

// Get notification settings by userId
router.get('/:userId', async (req, res) => {
  try {
    let settings = await AutoNotificationSetting.findOne({ userId: req.params.userId });
    if (!settings) {
      // Create a default settings entry for testing
      settings = new AutoNotificationSetting({ userId: req.params.userId });
      await settings.save(); // Save it to the database
      return res.status(201).json(settings); // Return the newly created settings
    }
    res.json(settings); // Return existing settings
  } catch (error) {
    res.status(500).json({ message: error.message }); // Handle errors
  }
});

// Save or update notification settings
router.post('/:userId', async (req, res) => {
  const { userId } = req.params;
  const settingsData = req.body; // Get the data from the request body

  try {
    let settings = await AutoNotificationSetting.findOne({ userId });
    if (settings) {
      // Update existing settings
      Object.assign(settings, settingsData);
      await settings.save(); // Save the updates
      return res.status(204).send(); // Send no content
    } else {
      // Create new settings
      settings = new AutoNotificationSetting({ userId, ...settingsData });
      await settings.save(); // Save new settings
      res.status(201).json(settings); // Return the newly created settings
    }
  } catch (error) {
    res.status(500).json({ message: error.message }); // Handle errors
  }
});

module.exports = router;
