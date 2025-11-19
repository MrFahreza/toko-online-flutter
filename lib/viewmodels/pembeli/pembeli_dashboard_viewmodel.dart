import 'package:stacked/stacked.dart';
import 'package:toko_online_flutter/app/locator.dart';
import 'package:toko_online_flutter/services/cart_service.dart';

/// ViewModel utama untuk mengelola Tampilan Dashboard Pembeli.
///
/// Kelas ini bertanggung jawab mengelola indeks tab navigasi dan status
/// keranjang belanja secara reaktif melalui [CartService] untuk badge notifikasi.
class PembeliDashboardViewModel extends ReactiveViewModel {
  /// Service yang bertanggung jawab mengelola data keranjang belanja.
  final _cartService = locator<CartService>();

  // --- Implementasi Reaktivitas ---

  /// Daftarkan [CartService] agar ViewModel ini secara otomatis mendengarkan
  /// dan memperbarui UI setiap kali jumlah item keranjang berubah.
  @override
  List<ListenableServiceMixin> get listenableServices => [_cartService];

  /// Mengembalikan jumlah total item yang ada di keranjang belanja.
  ///
  /// Nilai ini diakses langsung dari [CartService] dan akan diperbarui secara reaktif
  /// setiap kali data keranjang berubah.
  ///
  /// @returns [int] Jumlah item dalam keranjang.
  int get cartItemCount => _cartService.cartItemCount;

  // --- Logika Navigasi ---

  // Index tab yang sedang aktif (misalnya, 0 = Home, 1 = Cart, dst.).
  int _selectedIndex = 0;

  /// Mengembalikan indeks tab navigasi yang saat ini dipilih.
  ///
  /// @returns [int] Index tab yang aktif.
  int get selectedIndex => _selectedIndex;

  /// Dipanggil saat inisialisasi ViewModel.
  ///
  /// Fungsi ini memuat data keranjang awal HANYA SEKALI, memastikan [cartItemCount]
  /// memiliki nilai awal yang benar sebelum perubahan reaktif terjadi.
  @override
  void initialise() {
    // Memuat data keranjang awal dari API
    _cartService.getCart();
  }

  /// Mengubah index tab navigasi yang sedang aktif.
  ///
  /// @param index Index baru (0, 1, 2, ...) yang dipilih pengguna.
  void setIndex(int index) {
    // Memperbarui state index
    _selectedIndex = index;
    // Memicu update UI untuk mengganti tab
    notifyListeners();
  }
}