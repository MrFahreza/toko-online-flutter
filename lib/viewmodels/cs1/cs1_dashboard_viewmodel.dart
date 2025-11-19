import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:toko_online_flutter/app/locator.dart';
import 'package:toko_online_flutter/constants/route_name.dart';
import 'package:toko_online_flutter/models/order/order_model.dart';
import 'package:toko_online_flutter/services/order_service.dart';
import 'package:toko_online_flutter/services/notification_service.dart';
import 'package:toko_online_flutter/services/auth_service.dart';
import 'package:toko_online_flutter/ui/widgets/modern_dialog.dart';

/// ViewModel untuk manajemen tampilan dan logika Dashboard CS Layer 1 (Verifikasi).
///
/// Kelas ini adalah [ReactiveViewModel] karena mendengarkan notifikasi real-time
/// dari [NotificationService].
class Cs1DashboardViewModel extends ReactiveViewModel {
  final _orderService = locator<OrderService>();
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _snackbarService = locator<SnackbarService>();
  final _notificationService = locator<NotificationService>();
  final _authService = locator<AuthService>();

  // --- State ---
  /// Index tab yang sedang aktif (0: Verifikasi, 1: History, 2: Profile).
  int _selectedIndex = 0;

  /// ID pesanan yang sedang diproses (untuk indikator loading spesifik pada kartu pesanan).
  String? _busyOrderId;

  // Simpan Data Asli dari API (untuk keperluan filter)
  List<OrderModel> _allPendingOrders = [];
  List<OrderModel> _allHistoryOrders = [];

  // Simpan Data Terfilter (yang ditampilkan di UI)
  List<OrderModel> _pendingOrders = [];
  List<OrderModel> _historyOrders = [];

  // --- Getters ---

  /// Mengembalikan index tab yang sedang aktif.
  int get selectedIndex => _selectedIndex;

  /// Mengembalikan daftar pesanan yang menunggu verifikasi (list yang terfilter).
  List<OrderModel> get pendingOrders => _pendingOrders;

  /// Mengembalikan riwayat pesanan yang sudah diproses (list yang terfilter).
  List<OrderModel> get historyOrders => _historyOrders;

  /// Memeriksa apakah pesanan dengan ID tertentu sedang diproses.
  ///
  /// @param orderId ID pesanan.
  /// @returns `true` jika pesanan sedang sibuk.
  bool isOrderBusy(String orderId) => _busyOrderId == orderId;

  /// Daftarkan [NotificationService] agar ViewModel ini menerima pemberitahuan
  /// secara reaktif.
  @override
  List<ListenableServiceMixin> get listenableServices => [_notificationService];

  // --- Initialization & Disposal ---

  /// Dipanggil saat inisialisasi ViewModel.
  ///
  /// Fungsi ini mengatur pendengar notifikasi manual dan memuat data awal.
  @override
  void initialise() {
    // Setup Listener manual untuk menghindari error render loop
    _notificationService.addListener(_onNotificationReceived);
    refreshData();
  }

  /// Dipanggil saat ViewModel dibuang.
  ///
  /// Pastikan untuk menghapus pendengar notifikasi.
  @override
  void dispose() {
    _notificationService.removeListener(_onNotificationReceived);
    super.dispose();
  }

  // --- Search Logic ---

  /// Melakukan filter pesanan secara lokal berdasarkan ID atau nama pembeli.
  ///
  /// @param query Kata kunci pencarian.
  void searchOrder(String query) {
    if (query.isEmpty) {
      // Reset ke data asli saat query kosong
      _pendingOrders = _allPendingOrders;
      _historyOrders = _allHistoryOrders;
    } else {
      final lowerQuery = query.toLowerCase();

      // Filter Pending List (berdasarkan ID atau Nama)
      _pendingOrders = _allPendingOrders
          .where((order) =>
      (order.id ?? '').toLowerCase().contains(lowerQuery) ||
          (order.buyerName ?? '').toLowerCase().contains(lowerQuery))
          .toList();

      // Filter History List (berdasarkan ID atau Nama)
      _historyOrders = _allHistoryOrders
          .where((order) =>
      (order.id ?? '').toLowerCase().contains(lowerQuery) ||
          (order.buyerName ?? '').toLowerCase().contains(lowerQuery))
          .toList();
    }
    notifyListeners();
  }

  // --- Tab Logic ---

  /// Mengubah index tab yang aktif.
  ///
  /// Fungsi ini juga memicu pemuatan ulang data yang relevan dengan tab yang baru
  /// dibuka untuk memastikan data terbaru.
  ///
  /// @param index Index tab baru (0, 1, atau 2).
  void setIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
    // Refresh saat pindah tab (Verifikasi atau History)
    if (index == 0) fetchPendingOrders();
    if (index == 1) fetchHistoryOrders();
  }

  // --- Notification Logic ---

  /// Logika yang dijalankan saat notifikasi baru dari [NotificationService] diterima.
  ///
  /// Fungsi ini akan memicu pemuatan ulang pesanan yang menunggu jika ada tugas baru.
  void _onNotificationReceived() {
    final notif = _notificationService.newNotification;
    if (notif == null) return;

    // Handle Event: Tugas Baru Masuk (dari Pembeli yang baru upload bukti)
    if (notif['event'] == 'new_task') {
      final msg = notif['data']['message'] ?? 'Tugas Verifikasi Baru Masuk!';
      _snackbarService.showCustomSnackBar(
        message: msg,
        title: 'Info',
        duration: const Duration(seconds: 2),
        variant: 'default',
      );
      fetchPendingOrders();
    }

    // Cleanup notifikasi agar tidak diproses ulang
    _notificationService.clearNotification();
  }

  // --- Fetch Data Logic ---

  /// Memuat ulang semua data (Pending Orders dan History Orders).
  ///
  /// Digunakan untuk *pull-to-refresh* global.
  ///
  /// @returns [Future<void>]
  Future<void> refreshData() async {
    await Future.wait([
      fetchPendingOrders(),
      fetchHistoryOrders(),
    ]);
  }

  /// Memuat daftar pesanan yang menunggu verifikasi dari API.
  ///
  /// Status yang dimuat adalah 'MENUNGGU_VERIFIKASI_CS1'.
  ///
  /// @returns [Future<void>]
  Future<void> fetchPendingOrders() async {
    setBusy(true);
    try {
      _allPendingOrders = await _orderService.getPendingVerificationOrders();
      // Reset filter saat refresh (tampilkan semua)
      _pendingOrders = _allPendingOrders;
    } catch (e) {
      // Abaikan error (biarkan data kosong)
    }
    setBusy(false);
    notifyListeners();
  }

  /// Memuat riwayat pesanan yang sudah diverifikasi dari API.
  ///
  /// @returns [Future<void>]
  Future<void> fetchHistoryOrders() async {
    setBusy(true);
    try {
      _allHistoryOrders = await _orderService.getCs1OrderHistory();
      // Reset filter saat refresh
      _historyOrders = _allHistoryOrders;
    } catch (e) {
      // Abaikan error (biarkan data kosong)
    }
    setBusy(false);
    notifyListeners();
  }

  // --- Action Logic (Verification) ---

  /// Menangani persetujuan atau penolakan pembayaran.
  ///
  /// Fungsi ini menampilkan dialog konfirmasi dan memanggil API yang sesuai.
  ///
  /// @param context [BuildContext] saat ini.
  /// @param orderId ID pesanan yang diproses.
  /// @param isApprove `true` jika setuju, `false` jika tolak.
  /// @returns [Future<void>]
  Future<void> handleVerification(
      BuildContext context, String orderId, bool isApprove) async {
    // 1. Tampilkan Dialog Konfirmasi Modern
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ModernDialog(
        title: isApprove ? 'Setujui Pembayaran?' : 'Tolak Pembayaran?',
        description: isApprove
            ? 'Stok akan dikurangi dan pesanan diteruskan ke Gudang.'
            : 'Pesanan akan dibatalkan permanen.',
        confirmText: isApprove ? 'Ya, Setujui' : 'Ya, Tolak',
        cancelText: 'Batal',
        isDestructive: !isApprove, // Jika menolak, gunakan tema merah
        onConfirm: () {}, // Logika dilakukan setelah dialog pop
      ),
    );

    if (confirmed != true) return;

    // 2. Set Busy State pada item spesifik
    _busyOrderId = orderId;
    notifyListeners();

    try {
      if (isApprove) {
        // Panggil API Setuju
        await _orderService.approvePayment(orderId);
        _snackbarService.showCustomSnackBar(
            message: 'Berhasil disetujui, diteruskan ke CS2.',
            title: 'Sukses',
            duration: const Duration(seconds: 2),
          variant: 'default',);
      } else {
        // Panggil API Tolak
        await _orderService.rejectPayment(orderId);
        _snackbarService.showCustomSnackBar(
            message: 'Pesanan ditolak dan dibatalkan.',
            title: 'Info',
            duration: const Duration(seconds: 2),
          variant: 'default',);
      }

      // Muat ulang data yang berubah
      await fetchPendingOrders();
      fetchHistoryOrders();
    } catch (e) {
      // Tampilkan error
      _dialogService.showDialog(
          title: 'Error',
          description: e.toString().replaceAll("Exception: ", ""));
    } finally {
      // 3. Hapus Busy State
      _busyOrderId = null;
      notifyListeners();
    }
  }

  /// Navigasi ke halaman detail pesanan.
  ///
  /// @param order Objek [OrderModel] yang akan ditampilkan.
  void navigateToDetail(OrderModel order) {
    _navigationService.navigateTo(orderDetailViewRoute, arguments: order);
  }

  /// Memutus sesi pengguna (logout) dan menavigasi ke Auth View.
  void logout() {
    _authService.logout();
  }
}