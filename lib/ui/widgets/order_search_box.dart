import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Widget kustom untuk kotak pencarian pesanan (Order ID).
///
/// Widget ini menyediakan input teks dengan ikon pencarian dan menangani
/// perubahan input melalui callback [onChanged].
class OrderSearchBox extends StatelessWidget {
  /// Fungsi yang dipanggil setiap kali teks di kolom pencarian berubah.
  ///
  /// @param String Nilai teks yang baru.
  final Function(String) onChanged;

  /// Teks petunjuk yang ditampilkan di dalam kolom pencarian.
  final String hintText;

  const OrderSearchBox({
    super.key,
    required this.onChanged,
    this.hintText = 'Cari Order ID...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Margin di sekitar kotak pencarian
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        onChanged: onChanged, // Hubungkan perubahan teks ke callback
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none, // Hilangkan border default TextField
          contentPadding: EdgeInsets.symmetric(vertical: 14.h),
        ),
      ),
    );
  }
}