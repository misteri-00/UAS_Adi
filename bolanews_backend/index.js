const express = require('express');
const cors = require('cors');
const db = require('./db'); 
require('dotenv').config();

// IMPORT ROUTES & CONTROLLER
const authRoutes = require('./routes/authRoutes');
const authController = require('./controllers/authController'); // Untuk mengakses getMatchDetail

const app = express();

// 1. MIDDLEWARE
app.use(cors());
app.use(express.json());

// Log Request Masuk untuk mempermudah Debugging
app.use((req, res, next) => {
    console.log(`[${new Date().toLocaleTimeString()}] ${req.method} ${req.url}`);
    next();
});

// 2. MENGGUNAKAN ROUTES (Prefix: /api/auth)
app.use('/api/auth', authRoutes);

// --- ENDPOINT USERS (PUBLIC & PROFILE) ---
app.get('/api/user/:id', async (req, res) => {
    try {
        const [rows] = await db.query(
            'SELECT id, name, username, email, phoneNumber, bio, imageUrl, role FROM users WHERE id = ?', 
            [req.params.id]
        );
        if (rows.length === 0) return res.status(404).json({ message: "User tidak ditemukan" });
        res.json(rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.put('/api/user/:id', async (req, res) => {
    try {
        const userId = req.params.id;
        const { name, username, email, phoneNumber, bio, imageUrl } = req.body;
        const [result] = await db.query(
            'UPDATE users SET name=?, username=?, email=?, phoneNumber=?, bio=?, imageUrl=? WHERE id=?',
            [name, username, email, phoneNumber, bio, imageUrl, userId]
        );
        if (result.affectedRows === 0) return res.status(404).json({ message: "User tidak ditemukan" });
        res.status(200).json({ message: "Update Berhasil", id: userId });
    } catch (err) {
        res.status(500).json({ message: "Server Error", error: err.message });
    }
});

// --- ENDPOINT VIDEOS (PUBLIC GET) ---
app.get('/api/videos', async (req, res) => {
    try {
        const [rows] = await db.query('SELECT * FROM videos ORDER BY publishedAt DESC');
        res.status(200).json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// --- ENDPOINT NEWS (PUBLIC GET) ---
app.get('/api/news', async (req, res) => {
    try {
        const [rows] = await db.query('SELECT * FROM news ORDER BY publishedAt DESC');
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// --- ENDPOINT STANDINGS (PUBLIC GET) ---
app.get('/api/standings', async (req, res) => {
    try {
        const league = req.query.league;
        let query = 'SELECT * FROM standings';
        let params = [];
        if (league) {
            query += ' WHERE league = ?';
            params.push(league);
        }
        query += ' ORDER BY pts DESC';
        const [rows] = await db.query(query, params);
        res.status(200).json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// --- ENDPOINT MATCHES (PUBLIC GET) ---

// 1. Ambil List Pertandingan
app.get('/api/matches', async (req, res) => {
  try {
      const [rows] = await db.query('SELECT * FROM matches ORDER BY matchTime DESC');
      res.json(rows);
  } catch (err) {
      res.status(500).json({ error: err.message });
  }
});

// 2. Ambil Pertandingan Terbaru
// PENTING: Rute statis 'latest' harus di atas rute dinamis ':id'
app.get('/api/matches/latest', async (req, res) => {
    try {
        const [rows] = await db.query('SELECT * FROM matches ORDER BY createdAt DESC LIMIT 1');
        if (rows.length === 0) return res.status(404).json({ message: "Data pertandingan kosong" });
        let matchData = rows[0];
        
        // Parsing jika data disimpan sebagai string JSON di kolom matches
        if (typeof matchData.scorers === 'string') {
            try { matchData.scorers = JSON.parse(matchData.scorers); } catch (e) { }
        }
        if (typeof matchData.lineUps === 'string') {
            try { matchData.lineUps = JSON.parse(matchData.lineUps); } catch (e) { }
        }
        res.status(200).json(matchData);
    } catch (err) {
        res.status(500).json({ error: "Gagal mengambil data", detail: err.message });
    }
});

// 3. Ambil Detail Pertandingan (Scorers & Lineups dari tabel relasi)
app.get('/api/matches/:id', authController.getMatchDetail);


// 9. SERVER LISTENING
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log(`🚀 Server BolaPulse MySQL berjalan di http://localhost:${PORT}`);
});