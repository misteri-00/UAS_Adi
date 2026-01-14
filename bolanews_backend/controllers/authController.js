const db = require('../db'); 
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// ==========================================
// 1. LOGIKA AUTH & USER MANAGEMENT
// ==========================================

exports.register = async (req, res) => {
    try {
        const { name, username, email, password } = req.body;
        const [existing] = await db.query('SELECT id FROM users WHERE email = ? OR username = ?', [email, username]);
        if (existing.length > 0) {
            return res.status(400).json({ message: "Email atau Username sudah digunakan" });
        }
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);
        const [result] = await db.query(
            'INSERT INTO users (name, username, email, password, phoneNumber, bio, imageUrl, role) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
            [name, username, email, hashedPassword, '', '', '', 'user']
        );
        res.status(201).json({ message: "Registrasi Berhasil!", userId: result.insertId.toString() });
    } catch (error) {
        res.status(500).json({ message: "Server Error", error: error.message });
    }
};

exports.login = async (req, res) => {
    try {
        const { email, password } = req.body;
        const [rows] = await db.query('SELECT * FROM users WHERE email = ? OR username = ?', [email.trim(), email.trim()]);
        if (rows.length === 0) return res.status(400).json({ message: "User tidak ditemukan" });

        const user = rows[0];
        const isMatch = await bcrypt.compare(password.trim(), user.password);
        if (!isMatch) return res.status(400).json({ message: "Password salah" });

        const token = jwt.sign(
            { id: user.id, role: user.role }, 
            process.env.JWT_SECRET || 'secret_bola_pulse', 
            { expiresIn: '1d' }
        );

        res.json({
            token,
            userId: user.id.toString(),
            user: { id: user.id.toString(), name: user.name, username: user.username, email: user.email, role: user.role }
        });
    } catch (error) {
        res.status(500).json({ message: "Server Error", error: error.message });
    }
};

exports.getAllUsers = async (req, res) => {
    try {
        const [rows] = await db.query('SELECT id, name, username, email, role, createdAt FROM users ORDER BY createdAt DESC');
        res.json(rows);
    } catch (error) {
        res.status(500).json({ message: "Gagal mengambil data user", error: error.message });
    }
};

exports.createUser = async (req, res) => {
    try {
        const { name, username, email, password, role } = req.body;
        const [existing] = await db.query('SELECT id FROM users WHERE email = ?', [email]);
        if (existing.length > 0) return res.status(400).json({ message: "Email sudah digunakan" });

        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);
        await db.query('INSERT INTO users (name, username, email, password, role) VALUES (?, ?, ?, ?, ?)', [name, username, email, hashedPassword, role || 'user']);
        res.status(201).json({ message: "User berhasil dibuat" });
    } catch (error) {
        res.status(500).json({ message: "Server Error", error: error.message });
    }
};

exports.updateRole = async (req, res) => {
    try {
        const { id } = req.params;
        const { role } = req.body;
        const [result] = await db.query('UPDATE users SET role = ? WHERE id = ?', [role, id]);
        if (result.affectedRows === 0) return res.status(404).json({ message: "User tidak ditemukan" });
        res.json({ message: "Role diperbarui menjadi " + role });
    } catch (error) {
        res.status(500).json({ message: "Gagal update role", error: error.message });
    }
};

exports.deleteUser = async (req, res) => {
    try {
        const { id } = req.params;
        const [result] = await db.query('DELETE FROM users WHERE id = ?', [id]);
        if (result.affectedRows === 0) return res.status(404).json({ message: "User tidak ditemukan" });
        res.json({ message: "User berhasil dihapus" });
    } catch (error) {
        res.status(500).json({ message: "Gagal menghapus user", error: error.message });
    }
};

// ==========================================
// 2. LOGIKA NEWS (BERITA)
// ==========================================

exports.createNews = async (req, res) => {
    try {
        const { title, imageUrl, category, content } = req.body;
        await db.query(
            'INSERT INTO news (title, imageUrl, category, content, publishedAt) VALUES (?, ?, ?, ?, ?)',
            [title, imageUrl, category, content, new Date()]
        );
        res.status(201).json({ message: "Berita berhasil diterbitkan" });
    } catch (error) {
        res.status(500).json({ message: "Gagal tambah berita", error: error.message });
    }
};

exports.updateNews = async (req, res) => {
    try {
        const { id } = req.params;
        const { title, imageUrl, category, content } = req.body;
        await db.query('UPDATE news SET title=?, imageUrl=?, category=?, content=? WHERE id=?', [title, imageUrl, category, content, id]);
        res.status(200).json({ message: "Berita diperbarui" });
    } catch (error) {
        res.status(500).json({ message: "Gagal update berita", error: error.message });
    }
};

exports.deleteNews = async (req, res) => {
    try {
        const { id } = req.params;
        await db.query('DELETE FROM news WHERE id = ?', [id]);
        res.json({ message: "Berita berhasil dihapus" });
    } catch (error) {
        res.status(500).json({ message: "Gagal hapus berita", error: error.message });
    }
};

// ==========================================
// 3. LOGIKA MATCHES (PERTANDINGAN)
// ==========================================

exports.getAllMatches = async (req, res) => {
    try {
        // Hanya ambil kolom dari tabel matches saja
        const sql = `
            SELECT id, league, homeTeam, awayTeam, homeLogo, awayLogo, 
                   homeScore, awayScore, matchTime, status, isLive, createdAt
            FROM matches 
            ORDER BY createdAt DESC
        `;

        const [rows] = await db.query(sql);
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

exports.createMatch = async (req, res) => {
    const conn = await db.getConnection();
    try {
        await conn.beginTransaction();
        const { league, homeTeam, awayTeam, homeLogo, awayLogo, homeScore, awayScore, matchTime, status, isLive, scorers, lineUps } = req.body;

        const [m] = await conn.query(
            'INSERT INTO matches (league, homeTeam, awayTeam, homeLogo, awayLogo, homeScore, awayScore, matchTime, status, isLive) VALUES (?,?,?,?,?,?,?,?,?,?)',
            [league, homeTeam, awayTeam, homeLogo, awayLogo, homeScore||0, awayScore||0, matchTime, status||'Upcoming', isLive||0]
        );

        if (scorers && scorers.length > 0) {
            for (let s of scorers) await conn.query('INSERT INTO match_scorers (match_id, player_name, team_type) VALUES (?,?,?)', [m.insertId, s.player_name, s.team_type]);
        }
        if (lineUps && lineUps.length > 0) {
            for (let l of lineUps) await conn.query('INSERT INTO match_lineups (match_id, player_name, team_type) VALUES (?,?,?)', [m.insertId, l.player_name, l.team_type]);
        }

        await conn.commit();
        res.status(201).json({ message: "Match Created", matchId: m.insertId });
    } catch (error) {
        await conn.rollback();
        res.status(500).json({ error: error.message });
    } finally { conn.release(); }
};

exports.updateMatch = async (req, res) => {
    const conn = await db.getConnection();
    try {
        await conn.beginTransaction();
        const { id } = req.params;
        const { league, homeTeam, awayTeam, homeLogo, awayLogo, homeScore, awayScore, matchTime, status, isLive, scorers, lineUps } = req.body;

        await conn.query(
            'UPDATE matches SET league=?, homeTeam=?, awayTeam=?, homeLogo=?, awayLogo=?, homeScore=?, awayScore=?, matchTime=?, status=?, isLive=? WHERE id=?',
            [league, homeTeam, awayTeam, homeLogo, awayLogo, homeScore, awayScore, matchTime, status, isLive, id]
        );

        await conn.query('DELETE FROM match_scorers WHERE match_id = ?', [id]);
        await conn.query('DELETE FROM match_lineups WHERE match_id = ?', [id]);

        if (scorers && scorers.length > 0) {
            for (let s of scorers) await conn.query('INSERT INTO match_scorers (match_id, player_name, team_type) VALUES (?,?,?)', [id, s.player_name, s.team_type]);
        }
        if (lineUps && lineUps.length > 0) {
            for (let l of lineUps) await conn.query('INSERT INTO match_lineups (match_id, player_name, team_type) VALUES (?,?,?)', [id, l.player_name, l.team_type]);
        }

        await conn.commit();
        res.json({ message: "Match Updated" });
    } catch (error) {
        await conn.rollback();
        res.status(500).json({ error: error.message });
    } finally { conn.release(); }
};

exports.deleteMatch = async (req, res) => {
    try {
        const { id } = req.params;
        await db.query('DELETE FROM match_scorers WHERE match_id = ?', [id]);
        await db.query('DELETE FROM match_lineups WHERE match_id = ?', [id]);
        await db.query('DELETE FROM matches WHERE id = ?', [id]);
        res.json({ message: "Match Deleted" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// ==========================================
// 4. LOGIKA VIDEOS
// ==========================================

exports.getAllVideos = async (req, res) => {
    try {
        const [rows] = await db.query('SELECT * FROM videos ORDER BY publishedAt DESC');
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: "Gagal ambil video", detail: err.message });
    }
};

exports.addVideo = async (req, res) => {
    try {
        const { title, category, thumbnailUrl, videoUrl, duration, description, publishedAt } = req.body;
        const sql = `INSERT INTO videos (title, category, thumbnailUrl, videoUrl, duration, description, publishedAt) VALUES (?,?,?,?,?,?,?)`;
        const [result] = await db.query(sql, [title, category, thumbnailUrl, videoUrl, duration, description, publishedAt || new Date()]);
        res.status(201).json({ id: result.insertId, message: "Video ditambahkan" });
    } catch (err) {
        res.status(500).json({ error: "Gagal", detail: err.message });
    }
};

exports.updateVideo = async (req, res) => {
    try {
        const { id } = req.params;
        const { title, category, thumbnailUrl, videoUrl, duration, description } = req.body;
        const sql = `UPDATE videos SET title=?, category=?, thumbnailUrl=?, videoUrl=?, duration=?, description=? WHERE id=?`;
        await db.query(sql, [title, category, thumbnailUrl, videoUrl, duration, description, id]);
        res.json({ message: "Video diperbarui" });
    } catch (err) {
        res.status(500).json({ error: "Gagal", detail: err.message });
    }
};

exports.deleteVideo = async (req, res) => {
    try {
        const { id } = req.params;
        await db.query('DELETE FROM videos WHERE id = ?', [id]);
        res.json({ message: "Video dihapus" });
    } catch (err) {
        res.status(500).json({ error: "Gagal", detail: err.message });
    }
};

// ==========================================
// 5. LOGIKA STANDINGS (KLASEMEN)
// ==========================================

exports.getAllStandings = async (req, res) => {
    try {
        const [rows] = await db.query('SELECT * FROM standings ORDER BY pts DESC');
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.updateStanding = async (req, res) => {
    const { id } = req.params;
    const { mp, w, d, l, pts } = req.body;
    try {
        await db.query('UPDATE standings SET mp=?, w=?, d=?, l=?, pts=? WHERE id=?', [mp, w, d, l, pts, id]);
        res.json({ message: "Update success" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.getMatchDetail = async (req, res) => {
    try {
        const { id } = req.params;

        // 1. Ambil data dasar pertandingan
        const [matchRows] = await db.query('SELECT * FROM matches WHERE id = ?', [id]);
        
        if (matchRows.length === 0) {
            return res.status(404).json({ message: "Match not found" });
        }

        const matchData = matchRows[0];

        // 2. Ambil data pencetak gol (Scorers)
        const [scorerRows] = await db.query(
            'SELECT player_name, team_type FROM match_scorers WHERE match_id = ?', 
            [id]
        );

        // 3. Ambil data pemain (Lineups)
        const [lineupRows] = await db.query(
            'SELECT player_name, team_type FROM match_lineups WHERE match_id = ?', 
            [id]
        );

        // Gabungkan semua data menjadi satu objek JSON
        res.json({
            ...matchData,
            scorers_list: scorerRows, // Mengirim sebagai Array objek langsung
            lineups_list: lineupRows  // Mengirim sebagai Array objek langsung
        });

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};