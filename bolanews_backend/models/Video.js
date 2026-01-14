const mongoose = require('mongoose');

const VideoSchema = new mongoose.Schema({
    title: { type: String, required: true },
    category: { type: String, default: 'Football' },
    videoUrl: { type: String, required: true }, // Contoh: https://www.youtube.com/watch?v=XXXXX
    description: { type: String },
    publishedAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Video', VideoSchema);