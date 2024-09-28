const mongoose = require('mongoose');

const yearSchema = new mongoose.Schema({
  yearName: { type: String, required: true },
  fromDate: { type: Date, required: true },
  toDate: { type: Date, required: true },
  remarks: { type: String },
});

// Format date as dd/mm/yyyy
yearSchema.methods.toJSON = function () {
  const year = this.toObject();
  year.fromDate = formatDate(year.fromDate);
  year.toDate = formatDate(year.toDate);
  return year;
};

function formatDate(date) {
  if (!date) return null; // Handle null dates
  const day = String(date.getDate()).padStart(2, '0');
  const month = String(date.getMonth() + 1).padStart(2, '0'); // Months are 0-based
  const year = date.getFullYear();
  return `${day}/${month}/${year}`;
}

const Year = mongoose.model('Year', yearSchema);
module.exports = Year;
