const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: {
    type: String,
    required: false // Bisa dibuat true jika wajib diisi
  },
  username: {
    type: String,
    required: true,
    unique: true, // Mencegah username ganda
    trim: true
  },
  email: {
    type: String,
    required: true,
    unique: true, // Mencegah email ganda
    trim: true,
    lowercase: true
  },
  password: {
    type: String,
    required: true
  },
  phoneNumber: {
    type: String,
    default: ""
  },
  bio: {
    type: String,
    default: ""
  },
  imageUrl: {
    type: String,
    default: "https://via.placeholder.com/150" // Foto default
  }
}, { timestamps: true }); // Menambahkan createdAt dan updatedAt secara otomatis

module.exports = mongoose.model('User', userSchema);