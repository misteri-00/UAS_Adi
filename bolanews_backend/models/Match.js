const mongoose = require('mongoose'); // Import wajib ada di setiap file model

const matchSchema = new mongoose.Schema({
  league: String,
  week: String,
  homeTeam: String,
  homeScore: Number,
  awayTeam: String,
  awayScore: Number,
  matchTime: String,
  isLive: { type: Boolean, default: false } // Tambahkan isLive agar tidak error di UI Flutter
});

module.exports = mongoose.model('Match', matchSchema);
