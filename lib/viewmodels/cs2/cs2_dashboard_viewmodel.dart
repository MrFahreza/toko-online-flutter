// --- START FILE: lib/viewmodels/cs2_dashboard_viewmodel.dart ---

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

/// ViewModel untuk manajemen tampilan dan logika Dashboard CS Layer 2 (Logistik/Gudang).
class Cs2DashboardViewModel extends ReactiveViewModel {
  final _orderService = locator<OrderService>();
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _snackbarService = locator<SnackbarService>();
  final _notificationService = locator<NotificationService>();
  final _authService = locator<AuthService>();

  // --- State ---
  /// Index tab yang sedang aktif.
  int _selectedIndex = 0;
  /// ID pesanan yang sedang diproses.
  String? _busyOrderId;

  // Data Asli (Source of Truth dari API)
  List<OrderModel> _allActiveOrders = [];
  List<OrderModel> _allHistoryOrders = [];

  // Data Terfilter (Yang ditampilkan di UI)
  List<OrderModel> _activeOrders = [];
  List<OrderModel> _historyOrders = [];

  // --- Getters ---
  int get selectedIndex => _selectedIndex;
  /// Mengembalikan daftar pesanan yang aktif (Tugas & Sedang Diproses).
  List<OrderModel> get activeOrders => _activeOrders;
  /// Mengembalikan riwayat pesanan yang sudah dikirim atau selesai.
  List<OrderModel> get historyOrders => _historyOrders;
  /// Memeriksa apakah pesanan tertentu sedang diproses.
  /// @param orderId ID pesanan.
  bool isOrderBusy(String orderId) => _busyOrderId == orderId;

  @override
  List<ListenableServiceMixin> get listenableServices => [_notificationService];

  @override
  void initialise() {
    _notificationService.addListener(_onNotificationReceived);
    refreshData();
  }

  @override
  void dispose() {
    _notificationService.removeListener(_onNotificationReceived);
    super.dispose();
  }

  // --- Search Logic ---
  /// Melakukan filter pesanan secara lokal berdasarkan ID atau nama pembeli.
  /// @param query Kata kunci pencarian.
  void searchOrder(String query) {
    if (query.isEmpty) {
      // Jika search kosong, kembalikan ke data asli
      _activeOrders = _allActiveOrders;
      _historyOrders = _allHistoryOrders;
    } else {
      final lowerQuery = query.toLowerCase();

      // Filter Active Orders (Tugas)
      _activeOrders = _allActiveOrders.where((order) =>
      (order.id ?? '').toLowerCase().contains(lowerQuery) ||
          (order.buyerName ?? '').toLowerCase().contains(lowerQuery)
      ).toList();

      // Filter History Orders (Riwayat)
      _historyOrders = _allHistoryOrders.where((order) =>
      (order.id ?? '').toLowerCase().contains(lowerQuery) ||
          (order.buyerName ?? '').toLowerCase().contains(lowerQuery)
      ).toList();
    }
    notifyListeners();
  }

  /// Mengubah index tab yang aktif.
  /// @param index Index tab baru.
  void setIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
    // Refresh data saat pindah tab agar selalu update
    if (index == 0) fetchActiveOrders();
    if (index == 1) fetchHistoryOrders();
  }

  // --- Notification Logic ---
  /// Dipanggil saat [NotificationService] menerima event baru.
  void _onNotificationReceived() {
    final notif = _notificationService.newNotification;
    if (notif == null) return;

    // Handle Event: Tugas Baru Masuk (dari CS1)
    if (notif['event'] == 'new_task') {
      final msg = notif['data']['message'] ?? 'Paket masuk!';
      _snackbarService.showCustomSnackBar(
        message: msg,
        title: 'Gudang',
        duration: const Duration(seconds: 2),
        variant: 'default',
      );
      fetchActiveOrders();
    }

    // Handle Event: Order Selesai (dari Pembeli)
    if (notif['event'] == 'order_finished') {
      final msg = notif['data']['message'] ?? 'Pesanan Selesai';
      _snackbarService.showCustomSnackBar(
        message: msg,
        title: 'History Update',
        duration: const Duration(seconds: 2),
        variant: 'default',
      );
      fetchHistoryOrders();
    }

    _notificationService.clearNotification();
  }

  /// Memuat ulang semua data (Aktif dan History).
  Future<void> refreshData() async {
    await Future.wait([fetchActiveOrders(), fetchHistoryOrders()]);
  }

  /// Memuat daftar pesanan aktif (tugas) dari API.
  Future<void> fetchActiveOrders() async {
    setBusy(true);
    try {
      _allActiveOrders = await _orderService.getPendingProcessingOrders();
      // Reset filter
      _activeOrders = _allActiveOrders;
    } catch (e) { /* Silent Error */ }
    setBusy(false);
    notifyListeners();
  }

  /// Memuat riwayat pesanan (Dikirim/Selesai) dari API.
  Future<void> fetchHistoryOrders() async {
    setBusy(true);
    try {
      _allHistoryOrders = await _orderService.getCs2OrderHistory();
      // Reset filter
      _historyOrders = _allHistoryOrders;
    } catch (e) { /* Silent Error */ }
    setBusy(false);
    notifyListeners();
  }

  /// Memajukan status pesanan (Packing -> Kirim).
  ///
  /// @param context BuildContext saat ini.
  /// @param order Objek [OrderModel] yang diproses.
  Future<void> advanceOrderStatus(BuildContext context, OrderModel order) async {
    String nextStatus;
    String title;
    String desc;

    // Flow: MENUNGGU -> SEDANG DIPROSES -> DIKIRIM
    if (order.status == 'MENUNGGU_DIPROSES_CS2') {
      nextStatus = 'SEDANG_DIPROSES';
      title = 'Mulai Packing?';
      desc = 'Status pesanan akan berubah menjadi "Sedang Diproses".';
    } else if (order.status == 'SEDANG_DIPROSES') {
      nextStatus = 'DIKIRIM';
      title = 'Kirim Barang?';
      desc = 'Barang akan diserahkan ke kurir logistik. Status menjadi "Dikirim".';
    } else {
      return;
    }

    // Gunakan Modern Dialog yang konsisten dengan CS1
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ModernDialog(
        title: title,
        description: desc,
        confirmText: 'Ya, Lanjut',
        cancelText: 'Batal',
        onConfirm: () {},
      ),
    );

    if (confirmed != true) return;

    _busyOrderId = order.id;
    notifyListeners();

    try {
      await _orderService.updateOrderStatus(order.id!, nextStatus);
      _snackbarService.showCustomSnackBar(
          message: nextStatus == 'DIKIRIM' ? 'Barang berhasil dikirim!' : 'Mulai packing...',
          title: 'Sukses',
          duration: const Duration(seconds: 2),
        variant: 'default',
      );
      await refreshData();
    } catch (e) {
      _dialogService.showDialog(title: 'Gagal Update', description: e.toString());
    } finally {
      _busyOrderId = null;
      notifyListeners();
    }
  }

  /// Navigasi ke halaman detail pesanan.
  /// @param order Objek [OrderModel] yang akan ditampilkan.
  void navigateToDetail(OrderModel order) {
    _navigationService.navigateTo(orderDetailViewRoute, arguments: order);
  }

  /// Memutus sesi pengguna (logout).
  void logout() {
    _authService.logout();
  }
}
// --- END FILE: lib/viewmodels/cs2_dashboard_viewmodel.dart ---