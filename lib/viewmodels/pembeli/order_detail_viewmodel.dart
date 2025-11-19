import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

import '../../constants/app_colors.dart';
import '../../models/order/order_model.dart';

/// ViewModel yang bertanggung jawab untuk menampilkan detail spesifik dari sebuah pesanan.
///
/// ViewModel ini menyediakan *helper* untuk memformat data (seperti tanggal dan status)
/// agar siap ditampilkan di UI.
class OrderDetailViewModel extends BaseViewModel {
  /// Objek pesanan ([OrderModel]) yang akan ditampilkan detailnya.
  final OrderModel order;

  /// Membuat instance [OrderDetailViewModel] dengan pesanan yang diberikan.
  ///
  /// @param order Objek pesanan yang berisi semua data detail.
  OrderDetailViewModel(this.order);

  /// Mengembalikan tanggal pembuatan pesanan dalam format 'dd MMM yyyy, HH:mm'.
  ///
  /// Mengembalikan '-' jika tanggal pembuatan ([order.createdAt]) adalah `null`.
  ///
  /// @returns String representasi tanggal yang sudah diformat.
  String get formattedDate {
    // Memeriksa apakah data tanggal tersedia
    if (order.createdAt == null) return '-';

    // Format tanggal ke format yang mudah dibaca
    return DateFormat('dd MMM yyyy, HH:mm').format(order.createdAt!);
  }

  /// Mengembalikan objek [Color] yang sesuai dengan status pesanan saat ini.
  ///
  /// Warna digunakan untuk visualisasi status di UI (misalnya, merah untuk dibatalkan,
  /// hijau/biru untuk selesai/proses).
  ///
  /// @returns [Color] yang merepresentasikan status pesanan.
  Color get statusColor {
    // Menentukan warna berdasarkan nilai status
    switch (order.status) {
      case 'MENUNGGU_UPLOAD_BUKTI':
        return Colors.orange;
      case 'MENUNGGU_VERIFIKASI_CS1':
        return Colors.blue;
      case 'MENUNGGU_DIPROSES_CS2':
        return Colors.purple;
      case 'SEDANG_DIPROSES':
        return Colors.teal;
      case 'DIKIRIM':
        return Colors.indigo;
      case 'SELESAI':
        return AppColors.primary;
      case 'DIBATALKAN':
        return Colors.red;
      default:
        return AppColors.grey;
    }
  }

  /// Mengembalikan teks status pesanan yang sudah diformat.
  ///
  /// Nilai underscore (`_`) pada status akan diganti dengan spasi untuk tampilan yang lebih baik.
  /// Mengembalikan '-' jika status adalah `null`.
  ///
  /// @returns String teks status yang ramah pengguna.
  String get statusText => order.status?.replaceAll('_', ' ') ?? '-';
}