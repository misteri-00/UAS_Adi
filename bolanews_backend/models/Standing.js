const mongoose = require('mongoose');

const StandingSchema = new mongoose.Schema({
    rank: Number,
    teamName: String,
    mp: Number,    // Main (Matches Played)
    w: Number,     // Menang (Won)
    d: Number,     // Seri (Draw)
    l: Number,     // Kalah (Lost)
    goals: String, // Gol (Format "GM:GK")
    pts: Number,   // Poin
    league: String // Contoh: "Premier League"
});

module.exports = mongoose.model('Standing', StandingSchema);