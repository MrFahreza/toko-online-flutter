import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:toko_online_flutter/app/locator.dart';
import 'package:toko_online_flutter/constants/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Mengatur konfigurasi UI kustom untuk Snackbar menggunakan [SnackbarService] dari Stacked.
///
/// Fungsi ini mendaftarkan satu varian Snackbar ('default') dengan desain modern,
/// yang dilengkapi shadow, border radius, ikon, dan muncul di bagian atas layar.
void setupSnackbarUi() {
  final service = locator<SnackbarService>();

  // Konfigurasi Custom UI untuk Snackbar
  service.registerCustomSnackbarConfig(
    variant: 'default', // Varian default untuk digunakan di seluruh aplikasi
    config: SnackbarConfig(
      backgroundColor: Colors.white,
      textColor: Colors.black87,
      // Style untuk Judul Snackbar
      titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16.sp,
          color: AppColors.black),
      // Style untuk Pesan Snackbar
      messageTextStyle: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
      borderRadius: 12.0,
      // Shadow halus untuk efek kartu
      boxShadows: [
        BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4))
      ],
      // Ikon sukses
      icon: Icon(Icons.check_circle, color: AppColors.primary, size: 24.sp),
      shouldIconPulse: true,
      snackPosition: SnackPosition.TOP, // Muncul di atas (gaya modern)
      margin: EdgeInsets.all(16.w),
      barBlur: 0.5,
      overlayColor: Colors.black26, // Sedikit dim background di belakang snackbar
    ),
  );
}