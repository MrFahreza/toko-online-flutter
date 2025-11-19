import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';

/// Widget kustom yang menampilkan dialog modern dengan gaya terpusat.
///
/// Dialog ini dapat digunakan untuk konfirmasi atau notifikasi penting.
/// Warna dan ikon dapat disesuaikan untuk menunjukkan aksi destruktif (merah) atau normal (hijau/biru).
class ModernDialog extends StatelessWidget {
  /// Judul utama dialog (misalnya, 'Konfirmasi' atau 'Peringatan').
  final String title;

  /// Deskripsi atau isi pesan utama dialog.
  final String description;

  /// Teks pada tombol konfirmasi utama (misalnya, 'Ya, Lanjutkan').
  final String confirmText;

  /// Teks pada tombol batal (misalnya, 'Batal' atau 'Cek Lagi').
  final String cancelText;

  /// Fungsi yang akan dipanggil saat tombol konfirmasi ditekan.
  final VoidCallback onConfirm;

  /// Menentukan apakah dialog ini bersifat destruktif (misalnya, penolakan atau pembatalan).
  ///
  /// Jika `true`, warna dominan akan menjadi merah. Defaultnya adalah `false` (menggunakan warna utama aplikasi).
  final bool isDestructive;

  const ModernDialog({
    super.key,
    required this.title,
    required this.description,
    required this.confirmText,
    required this.cancelText,
    required this.onConfirm,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    // Tentukan warna tema: Merah jika destruktif, atau warna primer aplikasi
    final themeColor = isDestructive ? Colors.red : AppColors.primary;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      elevation: 0,
      backgroundColor: Colors.transparent, // Latar belakang transparan
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: const [
            BoxShadow(
                color: Colors.black26, blurRadius: 10.0, offset: Offset(0.0, 10.0)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Icon Circle Header
            Container(
              padding: EdgeInsets.all(15.w),
              decoration: BoxDecoration(
                color: themeColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                // Pilih ikon berdasarkan status destruktif
                isDestructive ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                size: 40.sp,
                color: themeColor,
              ),
            ),
            SizedBox(height: 15.h),

            // Title & Desc
            Text(title,
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700)),
            SizedBox(height: 10.h),
            Text(description,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
            SizedBox(height: 20.h),

            // Buttons
            Row(
              children: [
                // Tombol Batal
                Expanded(
                  child: OutlinedButton(
                    // Pop dengan nilai 'false' (Batal)
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(cancelText, style: const TextStyle(color: Colors.black)),
                  ),
                ),
                SizedBox(width: 10.w),
                // Tombol Konfirmasi Utama
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Pop dengan nilai 'true' (Konfirmasi)
                      Navigator.of(context).pop(true);
                      // Panggil callback konfirmasi
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      elevation: 0,
                    ),
                    child: Text(confirmText,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}