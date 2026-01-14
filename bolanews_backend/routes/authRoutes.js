const express = require('express');
const router = express.Router();

// Import controller
const authController = require('../controllers/authController');

// ==========================================
// 1. AUTH & USER ROUTES
// ==========================================
router.post('/register', authController.register);
router.post('/login', authController.login);
router.get('/users', authController.getAllUsers);
router.delete('/users/:id', authController.deleteUser);
router.put('/users/role/:id', authController.updateRole);

// ==========================================
// 2. NEWS (BERITA) ROUTES
// ==========================================
router.post('/news', authController.createNews);
router.put('/news/:id', authController.updateNews);
router.delete('/news/:id', authController.deleteNews);

// ==========================================
// 3. MATCH (PERTANDINGAN) ROUTES
// ==========================================

// Rute Statis didahulukan
router.get('/matches', authController.getAllMatches); 
router.get('/matches/latest', authController.getAllMatches);

// Rute Dinamis (menggunakan :id) diletakkan DI BAWAH rute statis
// Ini untuk memastikan 'latest' tidak dianggap sebagai sebuah 'id'
router.get('/matches/:id', authController.getMatchDetail);

router.post('/matches', authController.createMatch);
router.put('/matches/:id', authController.updateMatch);
router.delete('/matches/:id', authController.deleteMatch);

// ==========================================
// 4. VIDEO ROUTES
// ==========================================
router.get('/videos', authController.getAllVideos);
router.post('/videos', authController.addVideo);
router.put('/videos/:id', authController.updateVideo);
router.delete('/videos/:id', authController.deleteVideo);

// ==========================================
// 5. STANDINGS ROUTES
// ==========================================
router.get('/standings', authController.getAllStandings); 
router.put('/standings/:id', authController.updateStanding);

module.exports = router;