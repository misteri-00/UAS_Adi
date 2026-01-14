const mongoose = require('mongoose');

const newsSchema = new mongoose.Schema({
  title: String,
  category: String,
  content: String,
  imageUrl: String,
  publishedAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('News', newsSchema);