const express = require('express');
const StaffRights = require('../models/staffRightsModel');
const Staff = require('../models/staffModel'); // Assuming you have a Staff model
const router = express.Router();

// Fetch all staff members for the dropdown
router.get('/staff', async (req, res) => {
  try {
    const staffList = await Staff.find({}, 'firstName middleName lastName');
    res.json(staffList);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching staff list' });
  }
});

// Assign rights to a staff member
router.post('/assignRights', async (req, res) => {
  const { staffId, role } = req.body;

  try {
    // Update or create new rights for the staff member
    let staffRights = await StaffRights.findOne({ staffId });

    if (staffRights) {
      staffRights.role = role;
    } else {
      staffRights = new StaffRights({ staffId, role });
    }

    await staffRights.save();
    res.status(200).json({ message: 'Rights updated successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error assigning rights' });
  }
});

router.get('/rights', async (req, res) => {
  try {
    const staffRights = await StaffRights.find().populate('staffId', 'firstName middleName lastName'); // Populate to get staff names
    console.log(staffRights); // Debugging output
    res.json(staffRights);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching rights' });
  }
});


module.exports = router;
