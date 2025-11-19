import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:toko_online_flutter/app/locator.dart';
import 'package:toko_online_flutter/models/order/order_model.dart';
import 'package:toko_online_flutter/services/order_service.dart';
import 'package:toko_online_flutter/services/notification_service.dart';

import '../../constants/route_name.dart';
import '../../ui/widgets/modern_dialog.dart';

/// ViewModel yang bertanggung jawab mengelola riwayat pesanan (Order History) pengguna.
///
/// Kelas ini merupakan [ReactiveViewModel] karena mendengarkan perubahan dari
/// [NotificationService] untuk memperbarui data secara real-time saat status pesanan berubah.
class OrderHistoryViewModel extends ReactiveViewModel {
  final _orderService = locator<OrderService>();
  final _dialogService = locator<DialogService>();
  final _snackbarService = locator<SnackbarService>();
  final _navigationService = locator<NavigationService>();
  final _notificationService = locator<NotificationService>();
  final _imagePicker = ImagePicker();

  // Menyimpan seluruh data pesanan yang diambil dari API.
  List<OrderModel> _allData = [];
  // Menyimpan data pesanan yang telah disaring/difilter untuk ditampilkan di UI.
  List<OrderModel> _filteredData = [];

  /// Mengembalikan daftar pesanan yang akan ditampilkan di UI (sudah difilter).
  ///
  /// @returns List<OrderModel> data pesanan hasil penyaringan.
  List<OrderModel> get data => _filteredData;

  /// Daftarkan [NotificationService] agar ViewModel ini menerima pemberitahuan
  /// secara reaktif dan otomatis memicu [notifyListeners()].
  @override
  List<ListenableServiceMixin> get listenableServices => [_notificationService];

  /// Dipanggil saat inisialisasi ViewModel.
  ///
  /// Fungsi ini mengatur pendengar notifikasi manual dan memuat data pesanan awal.
  @override
  void initialise() {
    // Setup Listener manual agar aman dari error render loop dan memuat data awal.
    _notificationService.addListener(_onNotificationReceived);
    fetchOrders();
  }

  /// Dipanggil saat ViewModel dibuang.
  ///
  /// Pastikan untuk menghapus pendengar notifikasi.
  @override
  void dispose() {
    _notificationService.removeListener(_onNotificationReceived);
    super.dispose();
  }

  /// Logika yang dijalankan saat notifikasi baru dari [NotificationService] diterima.
  ///
  /// Fungsi ini akan menampilkan snackbar dan memuat ulang data jika notifikasi
  /// adalah update status pesanan.
  void _onNotificationReceived() {
    final notif = _notificationService.newNotification;

    // Cek apakah notifikasi valid dan merupakan event update status
    if (notif != null && notif['event'] == 'status_update') {
      // Ambil pesan dari backend, default ke 'Status diperbarui'
      final msg = notif['data']['message'] ?? 'Status diperbarui';

      _snackbarService.showCustomSnackBar(
        message: msg,
        title: 'Update Pesanan',
        duration: const Duration(seconds: 2),
        variant: 'default',
      );

      // Memuat ulang data untuk mencerminkan status terbaru
      fetchOrders();
    }
  }

  /// Mengambil riwayat pesanan dari [OrderService].
  ///
  /// @returns [Future<void>] yang selesai setelah data dimuat atau terjadi kesalahan.
  Future<void> fetchOrders() async {
    setBusy(true);
    try {
      // Ambil data dari service dan simpan sebagai data asli dan data yang difilter
      _allData = await _orderService.getOrderHistory();
      _filteredData = _allData;
    } catch (e) {
      // Tampilkan error jika gagal memuat
      _snackbarService.showCustomSnackBar(
          message: 'Gagal memuat riwayat: ${e.toString().replaceAll("Exception: ", "")}',
          duration: const Duration(seconds: 2),
        variant: 'default',);
    } finally {
      setBusy(false);
      // Panggil notifyListeners() untuk update UI
      notifyListeners();
    }
  }

  /// Melakukan pencarian dan penyaringan data pesanan berdasarkan ID pesanan.
  ///
  /// @param query Kata kunci pencarian yang dimasukkan pengguna.
  void searchOrder(String query) {
    if (query.isEmpty) {
      // Jika query kosong, tampilkan semua data asli
      _filteredData = _allData;
    } else {
      // Saring data berdasarkan ID pesanan yang cocok dengan query (case-insensitive)
      _filteredData = _allData
          .where((order) =>
          (order.id ?? '').toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    // Update UI dengan data yang sudah difilter
    notifyListeners();
  }

  /// Method yang dipanggil saat pengguna melakukan *Pull-to-Refresh* (refresh manual).
  ///
  /// @returns [Future<void>] yang selesai setelah data dimuat ulang.
  Future<void> onRefresh() async {
    await fetchOrders();
  }

  /// Menampilkan dialog konfirmasi dan memicu proses pemilihan gambar untuk upload bukti pembayaran.
  ///
  /// @param orderId ID pesanan yang akan diupload buktinya.
  /// @returns [Future<void>]
  Future<void> uploadProof(String orderId) async {
    final response = await _dialogService.showConfirmationDialog(
      title: 'Upload Bukti Pembayaran',
      description: 'Dari mana Anda ingin mengambil gambar?',
      confirmationTitle: 'Kamera',
      cancelTitle: 'Galeri',
    );

    if (response == null) return; // Pengguna membatalkan dialog

    if (response.confirmed) {
      // Pengguna memilih Kamera
      await pickAndUploadImage(orderId, ImageSource.camera);
    } else {
      // Pengguna memilih Galeri
      await pickAndUploadImage(orderId, ImageSource.gallery);
    }
  }

  /// Mengambil gambar dari sumber yang ditentukan dan mengunggahnya sebagai bukti pembayaran.
  ///
  /// @param orderId ID pesanan terkait.
  /// @param source Sumber gambar ([ImageSource.camera] atau [ImageSource.gallery]).
  /// @returns [Future<void>]
  Future<void> pickAndUploadImage(String orderId, ImageSource source) async {
    try {
      // Memilih gambar dengan kualitas 70%
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 70,
      );

      if (pickedFile == null) return; // Pengguna membatalkan pemilihan

      setBusy(true);
      _snackbarService.showCustomSnackBar(message: 'Sedang mengupload bukti...',
        variant: 'default',);

      // Konversi XFile ke File Dart
      final File imageFile = File(pickedFile.path);
      // Unggah file dan dapatkan URL publik
      final String publicUrl =
      await _orderService.uploadImageToSupabase(imageFile);

      // Kirim URL bukti pembayaran ke backend
      await _orderService.submitPaymentProof(orderId, publicUrl);

      // Refresh data setelah upload sukses
      await fetchOrders();

      _snackbarService.showCustomSnackBar(
        message: 'Bukti berhasil diupload! Menunggu verifikasi.',
        duration: const Duration(seconds: 2),
        variant: 'default',
      );
    } catch (e) {
      // Tampilkan error jika proses upload gagal
      _dialogService.showDialog(
        title: 'Gagal Upload',
        description: e.toString().replaceAll("Exception: ", ""),
      );
    } finally {
      setBusy(false);
    }
  }

  /// Menyelesaikan pesanan (mengubah status menjadi SELESAI) setelah konfirmasi pengguna.
  ///
  /// @param context [BuildContext] untuk menampilkan dialog Flutter native.
  /// @param orderId ID pesanan yang akan diselesaikan.
  /// @returns [Future<void>]
  Future<void> completeOrder(BuildContext context, String orderId) async {
    // Tampilkan Dialog Konfirmasi Modern custom
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ModernDialog(
        title: 'Pesanan Diterima?',
        description:
        'Pastikan barang sudah diterima dengan baik. Status akan berubah menjadi SELESAI dan tidak bisa dibatalkan.',
        confirmText: 'Ya, Terima',
        cancelText: 'Cek Lagi',
        onConfirm: () {}, // Logika konfirmasi dilakukan di tombol dialog
      ),
    );

    if (confirmed != true) return; // Pengguna memilih Cek Lagi

    setBusy(true);
    try {
      // Panggil Service untuk menyelesaikan pesanan
      await _orderService.completeOrder(orderId);

      _snackbarService.showCustomSnackBar(
        message: 'Terima kasih! Transaksi selesai.',
        title: 'Sukses',
        duration: const Duration(seconds: 2),
        variant: 'default',
      );

      // Refresh Data setelah sukses
      await fetchOrders();
    } catch (e) {
      // Tampilkan error jika gagal menyelesaikan pesanan
      _dialogService.showDialog(
          title: 'Gagal', description: e.toString().replaceAll("Exception: ", ""));
    } finally {
      setBusy(false);
    }
  }

  /// Navigasi ke halaman detail pesanan.
  ///
  /// @param order Objek [OrderModel] yang detailnya akan ditampilkan.
  void navigateToDetail(OrderModel order) {
    // Navigasi dengan mengirim objek OrderModel sebagai argumen
    _navigationService.navigateTo(orderDetailViewRoute, arguments: order);
  }
}