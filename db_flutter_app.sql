-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 14 Jan 2026 pada 03.55
-- Versi server: 10.4.32-MariaDB
-- Versi PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `db_flutter_app`
--

-- --------------------------------------------------------

--
-- Struktur dari tabel `matches`
--

CREATE TABLE `matches` (
  `id` int(11) NOT NULL,
  `league` varchar(100) DEFAULT NULL,
  `homeTeam` varchar(100) DEFAULT NULL,
  `awayTeam` varchar(100) DEFAULT NULL,
  `homeLogo` text DEFAULT NULL,
  `awayLogo` text DEFAULT NULL,
  `homeScore` int(11) DEFAULT NULL,
  `awayScore` int(11) DEFAULT NULL,
  `matchTime` varchar(10) DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  `isLive` tinyint(1) DEFAULT 0,
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `matches`
--

INSERT INTO `matches` (`id`, `league`, `homeTeam`, `awayTeam`, `homeLogo`, `awayLogo`, `homeScore`, `awayScore`, `matchTime`, `status`, `isLive`, `createdAt`) VALUES
(1, 'La Liga', 'Real Madrid', 'Real Betis', 'https://upload.wikimedia.org/wikipedia/en/thumb/5/56/Real_Madrid_CF.svg/1200px-Real_Madrid_CF.svg.png', 'data:image/png;base64,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', 5, 1, 'Full Time', 'FT', 0, '2026-01-12 05:04:03'),
(2, 'Laliga', 'barcelona', 'real madrid', 'https://upload.wikimedia.org/wikipedia/id/thumb/4/47/FC_Barcelona_%28crest%29.svg/1280px-FC_Barcelona_%28crest%29.svg.png', 'https://upload.wikimedia.org/wikipedia/en/thumb/5/56/Real_Madrid_CF.svg/960px-Real_Madrid_CF.svg.png', 2, 1, 'Full Time', 'Full Time', 0, '2026-01-13 08:34:22');

-- --------------------------------------------------------

--
-- Struktur dari tabel `match_lineups`
--

CREATE TABLE `match_lineups` (
  `id` int(11) NOT NULL,
  `match_id` int(11) NOT NULL,
  `player_name` varchar(100) NOT NULL,
  `position` varchar(50) DEFAULT NULL,
  `is_starter` tinyint(1) DEFAULT 1,
  `team_type` enum('home','away') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `match_lineups`
--

INSERT INTO `match_lineups` (`id`, `match_id`, `player_name`, `position`, `is_starter`, `team_type`) VALUES
(25, 1, 'Gonzalo Garcia', NULL, 1, 'home'),
(26, 1, 'Vinicius Junior', NULL, 1, 'home'),
(27, 1, 'Rodrygo', NULL, 1, 'home'),
(28, 1, 'Eduardo Camavinga', NULL, 1, 'home'),
(29, 1, 'Aurelien Tchouameni', NULL, 1, 'home'),
(30, 1, 'Jude Bellingham', NULL, 1, 'home'),
(31, 1, 'Federico Valverde', NULL, 1, 'home'),
(32, 1, 'Raul Asencio', NULL, 1, 'home'),
(33, 1, 'A. Rüdiger', NULL, 1, 'home'),
(34, 1, 'Alvaro Carreras', NULL, 1, 'home'),
(35, 1, 'Courtois', NULL, 1, 'home'),
(36, 1, 'Cucho Hernandez', NULL, 1, 'away'),
(37, 1, 'A. Ruibal', NULL, 1, 'away'),
(38, 1, 'Pablo Fornals', NULL, 1, 'away'),
(39, 1, 'Antony', NULL, 1, 'away'),
(40, 1, 'Marc Roca', NULL, 1, 'away'),
(41, 1, 'N. Deossa', NULL, 1, 'away'),
(42, 1, 'R. Rodríguez', NULL, 1, 'away'),
(43, 1, 'Natan', NULL, 1, 'away'),
(44, 1, 'M. Bartra', NULL, 1, 'away'),
(45, 1, 'Á. Ortiz', NULL, 1, 'away'),
(46, 1, 'Á. Valles', NULL, 1, 'away'),
(47, 1, 'Courtois', NULL, 1, 'away'),
(51, 2, 'rafinha', NULL, 1, 'home'),
(52, 2, 'lewandowski', NULL, 1, 'home'),
(53, 2, 'Gonzalo Garcia', NULL, 1, 'away'),
(54, 2, 'Vinicius Junior', NULL, 1, 'away'),
(55, 2, 'Rodrygo', NULL, 1, 'away'),
(56, 2, 'Eduardo Camavinga', NULL, 1, 'away'),
(57, 2, 'Aurelien Tchouameni', NULL, 1, 'away'),
(58, 2, 'Jude Bellingham', NULL, 1, 'away'),
(59, 2, 'Federico Valverde', NULL, 1, 'away'),
(60, 2, 'Raul Asencio', NULL, 1, 'away'),
(61, 2, 'A. Rüdiger', NULL, 1, 'away'),
(62, 2, 'Alvaro Carreras', NULL, 1, 'away'),
(63, 2, 'Courtois', NULL, 1, 'away');

-- --------------------------------------------------------

--
-- Struktur dari tabel `match_scorers`
--

CREATE TABLE `match_scorers` (
  `id` int(11) NOT NULL,
  `match_id` int(11) NOT NULL,
  `player_name` varchar(100) NOT NULL,
  `minute` int(11) DEFAULT NULL,
  `team_type` enum('home','away') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `match_scorers`
--

INSERT INTO `match_scorers` (`id`, `match_id`, `player_name`, `minute`, `team_type`) VALUES
(19, 1, 'Gonzalo García', NULL, 'home'),
(20, 1, 'Gonzalo García', NULL, 'home'),
(21, 1, 'Gonzalo García', NULL, 'home'),
(22, 1, 'Raúl Asencio', NULL, 'home'),
(23, 1, 'Fran Garcia', NULL, 'home'),
(24, 1, 'Juan Camilo Hernández', NULL, 'away'),
(28, 2, 'rafinha', NULL, 'home'),
(29, 2, 'lewandowski', NULL, 'home'),
(30, 2, 'Mbapee', NULL, 'away');

-- --------------------------------------------------------

--
-- Struktur dari tabel `news`
--

CREATE TABLE `news` (
  `id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `category` varchar(50) DEFAULT NULL,
  `content` text DEFAULT NULL,
  `imageUrl` text DEFAULT NULL,
  `publishedAt` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `news`
--

INSERT INTO `news` (`id`, `title`, `category`, `content`, `imageUrl`, `publishedAt`) VALUES
(1, 'Bursa Transfer: Kylian Mbappe Resmi Bergabung ke Real Madrid', 'Transfer', 'Setelah negosiasi panjang, Mbappe akhirnya menandatangani kontrak bersama Los Blancos.', 'https://cdn.antaranews.com/cache/1200x800/2024/07/16/ND_MBAPPE_PRESIDENTE_02_1PC8187.jpg', '2026-01-07 17:00:00'),
(2, 'Bursa Transfer: Antoine Semenyo Resmi Gabung Manchester City', 'Transfer', 'Manchester City telah menyelesaikan transfer Antoine Semenyo dari Bournemouth dengan biaya sekitar ?62,5 juta, menambah kekuatan lini serang tim di tengah bursa transfer Januari 2026.', 'https://akcdn.detik.net.id/community/media/visual/2026/01/09/antoine-semenyo-1767950676544.webp?w=600&q=90', '2026-01-09 17:00:00'),
(3, 'Bursa Transfer: Joshua Kimmich Masuk Radar Manchester United', 'Rumor Transfer', 'Manchester United dikabarkan tertarik mendatangkan Joshua Kimmich dari Bayern Munchen untuk memperkuat lini tengah.', 'https://d2x51gyc4ptf2q.cloudfront.net/content/uploads/2024/03/29104742/Man-Utd-Kimmich.jpg', '2026-01-08 17:00:00'),
(4, 'Liga Inggris: Arsenal Perpanjang Kontrak Bukayo Saka', 'Liga Inggris', 'Arsenal resmi memperpanjang kontrak Bukayo Saka hingga 2029. Keputusan ini diambil untuk menjaga stabilitas skuad.', 'https://static.promediateknologi.id/crop/0x0:0x0/0x0/webp/photo/p2/01/2026/01/10/1000343972-1537458163.jpg', '2026-01-08 17:00:00'),
(5, 'Serie A: Inter Milan Menang Dramatis di Derby Della Madonnina', 'Serie A', 'Inter Milan berhasil mengalahkan AC Milan dengan skor tipis 2-1 dalam laga Derby Della Madonnina.', 'https://cdn.antaranews.com/cache/1200x800/2025/02/03/20250202-inter-milan-de-vrij-01.jpg.webp', '2026-01-07 17:00:00'),
(6, 'La Liga: Barcelona Incar Wonderkid Brasil di Bursa Januari', 'Rumor Transfer', 'Barcelona dikabarkan tengah memantau seorang wonderkid asal Brasil yang tampil impresif di liga domestik.', 'https://cdn0-production-images-kly.akamaized.net/7BLw7VrCgExn9AZJLz8Vh2YddxU=/1200x675/smart/filters:quality(75):strip_icc():format(jpeg)/kly-media-production/medias/5400092/original/030189200_1762062905-000_76BL2XW.jpg', '2026-01-07 17:00:00');

-- --------------------------------------------------------

--
-- Struktur dari tabel `standings`
--

CREATE TABLE `standings` (
  `id` int(11) NOT NULL,
  `teamName` varchar(100) NOT NULL,
  `mp` int(11) NOT NULL,
  `w` int(11) NOT NULL,
  `d` int(11) NOT NULL,
  `l` int(11) NOT NULL,
  `goals` varchar(20) DEFAULT NULL,
  `pts` int(11) NOT NULL,
  `league` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `standings`
--

INSERT INTO `standings` (`id`, `teamName`, `mp`, `w`, `d`, `l`, `goals`, `pts`, `league`) VALUES
(1, 'Arsenal', 21, 15, 4, 2, '40:14', 49, 'Premier League'),
(2, 'Manchester City', 21, 13, 4, 4, '45:19', 40, 'Premier League'),
(3, 'Aston Villa', 21, 13, 4, 4, '33:24', 43, 'Premier League'),
(4, 'Liverpool', 21, 10, 5, 6, '32:28', 35, 'Premier League'),
(5, 'Brentford', 21, 10, 3, 8, '35:28', 33, 'Premier League'),
(6, 'Newcastle United', 21, 9, 5, 7, '32:27', 32, 'Premier League'),
(7, 'Manchester United', 21, 8, 8, 5, '36:32', 32, 'Premier League'),
(8, 'Chelsea', 21, 8, 7, 6, '34:24', 31, 'Premier League'),
(9, 'Fulham', 21, 9, 4, 8, '30:30', 31, 'Premier League'),
(10, 'Sunderland', 21, 7, 9, 5, '21:22', 30, 'Premier League'),
(11, 'Brighton', 21, 7, 8, 6, '31:28', 29, 'Premier League'),
(12, 'Everton', 21, 8, 5, 8, '23:25', 29, 'Premier League'),
(13, 'Crystal Palace', 21, 7, 7, 7, '22:23', 28, 'Premier League'),
(14, 'Tottenham Hotspur', 21, 7, 6, 8, '30:27', 27, 'Premier League'),
(15, 'Bournemouth', 21, 6, 8, 7, '34:40', 26, 'Premier League'),
(16, 'Leeds United', 21, 5, 7, 9, '29:37', 22, 'Premier League'),
(17, 'Nottingham Forest', 21, 6, 3, 12, '21:34', 21, 'Premier League'),
(18, 'West Ham United', 21, 3, 5, 13, '22:43', 14, 'Premier League'),
(19, 'Burnley', 21, 3, 4, 14, '22:41', 13, 'Premier League'),
(20, 'Wolverhampton', 21, 1, 4, 16, '15:41', 7, 'Premier League'),
(21, 'Barcelona', 19, 16, 1, 2, '53:20', 49, 'La Liga'),
(22, 'Real Madrid', 19, 14, 3, 2, '41:17', 45, 'La Liga'),
(23, 'Villarreal', 18, 12, 3, 3, '34:16', 39, 'La Liga'),
(24, 'Atletico Madrid', 19, 11, 5, 3, '34:17', 38, 'La Liga'),
(25, 'Espanyol', 18, 10, 3, 5, '22:19', 33, 'La Liga'),
(26, 'Real Betis', 19, 7, 8, 4, '31:25', 29, 'La Liga'),
(27, 'Celta Vigo', 18, 6, 8, 4, '24:20', 26, 'La Liga'),
(28, 'Athletic Bilbao', 19, 7, 3, 9, '17:25', 24, 'La Liga'),
(29, 'Elche', 18, 5, 7, 6, '24:23', 22, 'La Liga'),
(30, 'Real Sociedad', 19, 5, 6, 8, '24:27', 21, 'La Liga'),
(31, 'Getafe', 19, 6, 3, 10, '15:25', 21, 'La Liga'),
(32, 'Sevilla', 18, 6, 2, 10, '24:29', 20, 'La Liga'),
(33, 'Alaves', 19, 5, 5, 9, '15:21', 20, 'La Liga'),
(34, 'Osasuna', 18, 5, 4, 9, '18:21', 19, 'La Liga'),
(35, 'Rayo Vallecano', 18, 4, 7, 7, '14:21', 19, 'La Liga'),
(36, 'Mallorca', 18, 4, 6, 8, '20:26', 18, 'La Liga'),
(37, 'Girona', 18, 4, 6, 8, '17:34', 18, 'La Liga'),
(38, 'Valencia', 18, 3, 7, 8, '17:30', 16, 'La Liga'),
(39, 'Levante', 17, 3, 4, 10, '20:29', 13, 'La Liga'),
(40, 'Real Oviedo', 19, 2, 7, 10, '9:28', 13, 'La Liga'),
(41, 'Bayern Munich', 15, 13, 2, 0, '55:11', 41, 'Bundesliga'),
(42, 'Borussia Dortmund', 16, 9, 6, 1, '29:15', 33, 'Bundesliga'),
(43, 'Bayer Leverkusen', 15, 9, 2, 4, '33:20', 29, 'Bundesliga'),
(44, 'RB Leipzig', 15, 9, 2, 4, '30:19', 29, 'Bundesliga'),
(45, 'Hoffenheim', 15, 8, 3, 4, '29:20', 27, 'Bundesliga'),
(46, 'VfB Stuttgart', 15, 8, 2, 5, '25:22', 26, 'Bundesliga'),
(47, 'Eintracht Frankfurt', 16, 7, 5, 4, '33:33', 26, 'Bundesliga'),
(48, 'Freiburg', 16, 5, 6, 5, '26:27', 21, 'Bundesliga'),
(49, 'Union Berlin', 16, 6, 3, 7, '20:24', 21, 'Bundesliga'),
(50, 'FC Kolin', 16, 4, 5, 7, '24:26', 17, 'Bundesliga'),
(51, 'Hamburger SV', 16, 4, 5, 7, '17:26', 17, 'Bundesliga'),
(52, 'Werder Bremen', 15, 4, 5, 6, '18:28', 17, 'Bundesliga'),
(53, 'Borussia M?nchengladbach', 15, 4, 4, 7, '18:24', 16, 'Bundesliga'),
(54, 'Wolfsburg', 15, 4, 3, 8, '23:28', 15, 'Bundesliga'),
(55, 'Augsburg', 15, 4, 2, 9, '17:28', 14, 'Bundesliga'),
(56, 'St. Pauli', 15, 3, 3, 9, '13:26', 12, 'Bundesliga'),
(57, 'Heidenheim', 16, 3, 3, 10, '15:36', 12, 'Bundesliga'),
(58, 'Mainz 05', 16, 2, 5, 9, '14:26', 11, 'Bundesliga'),
(59, 'Inter', 18, 14, 0, 4, '40:15', 42, 'Serie A'),
(60, 'AC Milan', 18, 11, 6, 1, '29:14', 39, 'Serie A'),
(61, 'Napoli', 18, 12, 2, 4, '28:15', 38, 'Serie A'),
(62, 'Juventus', 19, 10, 6, 3, '27:16', 36, 'Serie A'),
(63, 'AS Roma', 19, 12, 0, 7, '22:12', 36, 'Serie A'),
(64, 'Como', 19, 9, 6, 4, '26:13', 33, 'Serie A'),
(65, 'Bologna', 19, 8, 5, 6, '26:19', 29, 'Serie A'),
(66, 'Atalanta', 19, 7, 7, 5, '23:19', 28, 'Serie A'),
(67, 'Udinese', 20, 7, 5, 8, '22:32', 26, 'Serie A'),
(68, 'Lazio', 19, 6, 7, 6, '20:16', 25, 'Serie A'),
(69, 'Sassuolo', 19, 6, 5, 8, '23:25', 23, 'Serie A'),
(70, 'Torino', 19, 6, 5, 8, '21:30', 23, 'Serie A'),
(71, 'Cremonese', 19, 5, 7, 7, '20:23', 22, 'Serie A'),
(72, 'Cagliari', 19, 4, 7, 8, '21:27', 19, 'Serie A'),
(73, 'Parma', 18, 4, 6, 8, '12:21', 18, 'Serie A'),
(74, 'Lecce', 18, 4, 5, 9, '12:25', 17, 'Serie A'),
(75, 'Genoa', 19, 3, 7, 9, '19:29', 16, 'Serie A'),
(76, 'Fiorentina', 19, 2, 7, 10, '20:30', 13, 'Serie A'),
(77, 'Verona', 18, 2, 7, 9, '15:30', 13, 'Serie A'),
(78, 'Pisa', 20, 1, 10, 9, '15:30', 13, 'Serie A'),
(79, 'Lens', 17, 13, 1, 3, '31:13', 40, 'Ligue 1'),
(80, 'PSG', 17, 12, 3, 2, '37:15', 39, 'Ligue 1'),
(81, 'Marseille', 17, 10, 2, 5, '36:17', 32, 'Ligue 1'),
(82, 'LOSC', 17, 10, 2, 5, '33:22', 32, 'Ligue 1'),
(83, 'Lyon', 17, 9, 3, 5, '25:17', 30, 'Ligue 1'),
(84, 'Rennes', 17, 8, 6, 3, '29:24', 30, 'Ligue 1'),
(85, 'Strasbourg', 17, 7, 3, 7, '26:21', 24, 'Ligue 1'),
(86, 'Toulouse', 17, 6, 5, 6, '24:22', 23, 'Ligue 1'),
(87, 'Monaco', 17, 7, 2, 8, '27:30', 23, 'Ligue 1'),
(88, 'Angers', 17, 6, 4, 7, '18:20', 22, 'Ligue 1'),
(89, 'Brest', 17, 6, 4, 7, '23:27', 22, 'Ligue 1'),
(90, 'Lorient', 17, 4, 7, 6, '20:29', 19, 'Ligue 1'),
(91, 'Le Havre', 17, 4, 6, 7, '15:23', 18, 'Ligue 1'),
(92, 'Nice', 17, 5, 3, 9, '20:30', 18, 'Ligue 1'),
(93, 'Paris', 17, 4, 4, 9, '22:31', 16, 'Ligue 1'),
(94, 'Nantes', 17, 3, 5, 9, '16:28', 14, 'Ligue 1'),
(95, 'Auxerre', 17, 3, 3, 11, '14:27', 12, 'Ligue 1'),
(96, 'Metz', 17, 3, 3, 11, '18:38', 12, 'Ligue 1');

-- --------------------------------------------------------

--
-- Struktur dari tabel `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `phoneNumber` varchar(20) DEFAULT NULL,
  `bio` text DEFAULT NULL,
  `imageUrl` varchar(255) DEFAULT NULL,
  `role` enum('admin','user') DEFAULT 'user',
  `createdAt` datetime DEFAULT NULL,
  `updatedAt` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `users`
--

INSERT INTO `users` (`id`, `name`, `username`, `email`, `password`, `phoneNumber`, `bio`, `imageUrl`, `role`, `createdAt`, `updatedAt`) VALUES
(2, 'Budi Santoso', 'budi_bola', 'budi@gmail.com', '$2b$10$JB294aZdYjfLWcVSMhtU.uaVedU3ClthW2ZUBQK6LhYIQkHDpzVIG', '08123456r872897', 'Pecinta sepak bola sejati', 'https://ui-avatars.com/api/?name=Budi+Santoso&background=random', 'admin', '2026-01-11 10:00:00', '2026-01-11 17:27:06'),
(3, 'Siti Aminah', 'sitiaminah', 'siti@gmail.com', '$2b$10$JB294aZdYjfLWcVSMhtU.uaVedU3ClthW2ZUBQK6LhYIQkHDpzVIG', '08987654321', 'Pantau terus skor liga  boss', 'https://i.pinimg.com/originals/94/83/4f/94834f37041bac2e55c612df7a6c0b8d.jpg', 'user', '2026-01-11 11:00:00', '2026-01-11 11:00:00'),
(10, 'admin', 'admin', 'admin@gmail.com', '$2b$10$Ktk/P/BOL.YU3Zd1k0qMgOUlTk3ZPke6eh5UsJNd2IJENwGpjXwQK', NULL, NULL, NULL, 'admin', NULL, NULL),
(11, 'user', 'havhd', 'user@gmail.com', '$2b$10$h98/s1H97gFdccnzXI7kceCLuDvY5IEaZBetmbdwT6eHYKgnCXtsK', '98767639', 'test user', 'https://i.pinimg.com/originals/94/83/4f/94834f37041bac2e55c612df7a6c0b8d.jpg', 'user', NULL, NULL);

-- --------------------------------------------------------

--
-- Struktur dari tabel `videos`
--

CREATE TABLE `videos` (
  `id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `category` varchar(50) DEFAULT NULL,
  `videoUrl` varchar(255) NOT NULL,
  `thumbnailUrl` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `duration` varchar(10) DEFAULT NULL,
  `publishedAt` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `videos`
--

INSERT INTO `videos` (`id`, `title`, `category`, `videoUrl`, `thumbnailUrl`, `description`, `duration`, `publishedAt`) VALUES
(1, 'Real Madrid 5-1 Real Betis | LaLiga 25/26 Match Highlights', 'LaLiga', 'https://www.youtube.com/watch?v=jtmBmjpPsXo', 'https://img.youtube.com/vi/jtmBmjpPsXo/maxresdefault.jpg', 'Saksikan pesta gol Real Madrid saat mengalahkan Real Betis dengan skor telak 5-1 dalam lanjutan LaLiga musim 25/26. Bintang muda Gonzalo Garcia tampil luar biasa dengan mencetak hat-trick. Gol lainnya dicetak oleh Asencio dan Fran Garcia.', '08:04', '2026-01-04 00:00:00'),
(2, 'HIGHLIGHTS | FC BARCELONA 3 vs 2 REAL MADRID | SPANISH SUPER CUP FINAL | EL CLASICO 🔵🔴', 'Highlights', 'https://youtu.be/9V2guLT3S14?si=6MxEYASRbcdob3ru', 'https://img.youtube.com/vi/9V2guLT3S14/maxresdefault.jpg', 'Barcelona juara Piala Super Spanyol hancurkan ambisi besar Real Madrid. Blaugrana lagi-lagi memenangkan Piala Super Spanyol untuk kedua kalinya berturut-turut di pertandingan El Clasico. Kemenangan ini menjadi yang bersejarah lantaran Hansi Flick mencatatkan berbagai rekor', '04:08', '2026-01-12 20:55:15'),
(3, 'HIGHLIGHT LENGKAP | Man City 10–1 Exeter City | City cetak sepuluh gol luar biasa di putaran ketiga Piala FA!', 'Highlights', 'https://youtu.be/I1g3etLad3M?si=RMt9brntKLcDKhwn', 'https://img.youtube.com/vi/I1g3etLad3M/maxresdefault.jpg', 'Manchester City mencetak dua digit gol saat kami mengalahkan Exeter City 10–1 di ajang Piala FA, dengan Antoine Semenyo dan Ryan McAidoo sama-sama mencetak gol pada laga debut mereka.\n\nMax Alleyne, yang baru tampil untuk kedua kalinya, membuka keunggulan melalui gol jarak dekat sebelum tendangan keras Rodri menggandakan keunggulan tim.\n\nCuplikan lengkap dari pertandingan bersejarah ini dapat disaksikan pada video di atas.', '09:06', '2026-01-12 21:26:57'),
(4, 'INTER–NAPOLI 2–2 | HIGHLIGHTS | Kedua Tim Berbagi Satu Poin dalam Perebutan Puncak Klasemen | SERIE A 2025/26', 'Highlights', 'https://youtu.be/LvN22ggXYeU?si=pmg_5AoeK0JQcZ7_', 'https://img.youtube.com/vi/LvN22ggXYeU/maxresdefault.jpg', 'Gol Dimarco dan Çalhanoglu untuk Inter serta dua gol McTominay bagi Napoli memastikan hasil imbang di San Siro, membuat posisi klasemen tetap tidak berubah seiring berlanjutnya persaingan menuju puncak klasemen | Serie A 2025/26', '02:43', '2026-01-12 22:11:13'),
(5, 'Awal Terbang Memasuki Tahun Baru! | FC Bayern vs VfL Wolfsburg | Highlight | Pekan ke-16 – Bundesliga', 'Highlights', 'https://youtu.be/wxEEXk-3qj0?si=YAy73HocZBsSQn_e', 'https://img.youtube.com/vi/wxEEXk-3qj0/maxresdefault.jpg', 'Video ini menampilkan cuplikan pertandingan Bundesliga Pekan ke-16 antara FC Bayern Munich melawan VfL Wolfsburg, di mana Bayern meraih kemenangan telak dengan skor 8-1 di Allianz Arena.', '04:04', '2026-01-12 22:22:29'),
(6, 'LOSC–OL: Gol perdana Endrick dan tiket lolos ke babak 16 besar Piala Prancis (1–2)', 'Highlights', 'https://youtu.be/DhmpZGKZ2w8?si=4jV47YlUTNtXolX5', 'https://img.youtube.com/vi/DhmpZGKZ2w8/maxresdefault.jpg', 'OL menang 2–1 atas LOSC berkat gol Afonso Moreira dan Endrick, sekaligus memastikan tiket ke babak 16 besar Piala Prancis.', '02:57', '2026-01-12 22:28:18'),
(7, 'TWO GOALS in Stoppage Time! | Frankfurt vs Dortmund', 'Bundesliga', 'https://youtu.be/VnanTS331xk', 'https://img.youtube.com/vi/VnanTS331xk/0.jpg', 'Highlights dramatis Bundesliga.', '14:19', NULL),
(8, 'SASSUOLO–JUVENTUS 0–3 | HIGHLIGHT LENGKAP | SERIE A 2025/26', 'Highlights', 'https://youtu.be/2lafUjzFVaE?si=Z5uj-S7Kiqt3p_5u', 'https://img.youtube.com/vi/2lafUjzFVaE/maxresdefault.jpg', 'Saksikan kembali momen-momen terbaik dari pertandingan antara Sassuolo dan Juventus, yang berakhir 0–3 berkat gol Muharemovic (gol bunuh diri), Miretti, dan David | Serie A 2025/26', '20:07', '2026-01-12 23:21:12'),
(10, 'FC RED BULL SALZBURG 0–5 FC BAYERN MÜNCHEN', 'Highlights', 'https://youtu.be/0uNsS8fy4kA', 'https://img.youtube.com/vi/0uNsS8fy4kA/maxresdefault.jpg', 'Kemenangan telak Bayern', '08:33', '2026-01-07 00:00:00'),
(11, 'Highlight Serie A: Fiorentina 1-1 AC Milan | Duel Sengit di Artemio Franchi', 'Highlights', 'https://www.youtube.com/watch?v=eCT22olgnV0', 'https://img.youtube.com/vi/eCT22olgnV0/maxresdefault.jpg', 'Pertandingan berakhir imbang 1-1. Fiorentina sempat memimpin lewat gol Pietro Comuzzo pada menit ke-68, namun Christopher Nkunku berhasil menyelamatkan AC Milan dari kekalahan melalui gol penyeimbang di menit akhir.', '20:24', '2026-01-12 23:55:40'),
(12, 'Highlight Piala FA: Charlton 1-5 Chelsea | Debut Manis Liam Rosenior', 'Highlights', 'https://www.youtube.com/watch?v=muelEjq9oHg', 'https://img.youtube.com/vi/muelEjq9oHg/maxresdefault.jpg', 'Chelsea menang telak 5-1 atas Charlton Athletic. Gol-gol kemenangan dicetak oleh Kiwior (stoppage time babak pertama), Tosin Adarabioyo, Marc Guiu, Pedro Neto, dan penalti Enzo Fernandez. Charlton sempat membalas lewat Miles Leaburn.', '06:02', '2026-01-13 00:02:10'),
(13, 'Highlight Piala FA: Tottenham 1-2 Aston Villa | Villa Bungkam Spurs di London', 'Highlights', 'https://www.youtube.com/watch?v=dF2s2ocEHvs', 'https://img.youtube.com/vi/dF2s2ocEHvs/maxresdefault.jpg', 'Aston Villa berhasil menyingkirkan Tottenham Hotspur dari Piala FA dengan skor 2-1. Gol kemenangan dicetak oleh Emiliano Buendia dan Morgan Rogers pada babak pertama. Tottenham hanya mampu membalas satu gol melalui Odobert di babak kedua', '06:01', '2026-01-13 00:18:08'),
(14, 'Highlight Premier League: Burnley 2-2 Manchester United | Drama 4 Gol di Turf Moor', 'Highlights', 'https://www.youtube.com/watch?v=CFbx_Yvp1kU', 'https://img.youtube.com/vi/CFbx_Yvp1kU/maxresdefault.jpg', 'Pertandingan sengit antara Burnley dan Manchester United berakhir imbang 2-2. Benjamin Šeško sempat membalikkan keadaan untuk United dengan dua golnya, namun gol spektakuler Jaidon Anthony di menit akhir menyelamatkan satu poin bagi tuan rumah', '02:51', '2026-01-13 09:00:52');

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `matches`
--
ALTER TABLE `matches`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `match_lineups`
--
ALTER TABLE `match_lineups`
  ADD PRIMARY KEY (`id`),
  ADD KEY `match_id` (`match_id`);

--
-- Indeks untuk tabel `match_scorers`
--
ALTER TABLE `match_scorers`
  ADD PRIMARY KEY (`id`),
  ADD KEY `match_id` (`match_id`);

--
-- Indeks untuk tabel `news`
--
ALTER TABLE `news`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `standings`
--
ALTER TABLE `standings`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indeks untuk tabel `videos`
--
ALTER TABLE `videos`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `matches`
--
ALTER TABLE `matches`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT untuk tabel `match_lineups`
--
ALTER TABLE `match_lineups`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=64;

--
-- AUTO_INCREMENT untuk tabel `match_scorers`
--
ALTER TABLE `match_scorers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT untuk tabel `news`
--
ALTER TABLE `news`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT untuk tabel `standings`
--
ALTER TABLE `standings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=97;

--
-- AUTO_INCREMENT untuk tabel `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT untuk tabel `videos`
--
ALTER TABLE `videos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `match_lineups`
--
ALTER TABLE `match_lineups`
  ADD CONSTRAINT `match_lineups_ibfk_1` FOREIGN KEY (`match_id`) REFERENCES `matches` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `match_scorers`
--
ALTER TABLE `match_scorers`
  ADD CONSTRAINT `match_scorers_ibfk_1` FOREIGN KEY (`match_id`) REFERENCES `matches` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
