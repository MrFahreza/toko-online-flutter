import 'package:flutter/material.dart';

/// Definisi konstanta warna yang digunakan di seluruh aplikasi.
class AppColors {
  /// Warna primer aplikasi (Hijau/Main Green).
  /// Digunakan untuk elemen utama seperti tombol, ikon aktif, dan header.
  static const Color primary = Color(0xFF70BF4B);

  /// Warna sekunder/aksi (Oranye Terbakar).
  /// Digunakan untuk tombol aksi yang menonjol, badge, atau harga.
  static const Color secondary = Color(0xFFD96704);

  /// Warna aksen hijau yang lebih terang.
  /// Cocok untuk gradien atau highlight latar belakang ringan.
  static const Color accentGreen = Color(0xFF9FD966);

  /// Warna aksen oranye yang lebih cerah.
  /// Digunakan untuk notifikasi atau status (misalnya, *pending*).
  static const Color accentOrange = Color(0xFFF2994B);

  /// Warna hitam gelap untuk teks utama dan elemen penting.
  static const Color black = Color(0xFF0D0D0D);

  /// Warna putih standar.
  static const Color white = Colors.white;

  /// Warna abu-abu standar, sering digunakan untuk teks sekunder atau border.
  static const Color grey = Color(0xFF9E9E9E);
}