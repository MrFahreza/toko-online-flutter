import 'dart:async';

import 'package:stacked/stacked.dart';
import 'package:toko_online_flutter/app/locator.dart';
import 'package:toko_online_flutter/constants/route_name.dart';
import 'package:toko_online_flutter/models/cart/cart_model.dart';
import 'package:toko_online_flutter/services/cart_service.dart';
import 'package:stacked_services/stacked_services.dart';

/// ViewModel untuk manajemen tampilan dan logika Keranjang Belanja.
///
/// Kelas ini adalah [ReactiveViewModel] karena mendengarkan perubahan status
/// dari [CartService] (Single Source of Truth).
class CartViewModel extends ReactiveViewModel {
  final _cartService = locator<CartService>();
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();

  /// ID item yang sedang diproses (untuk indikator loading item spesifik).
  String? _busyItemId;

  /// Mengembalikan ID item yang sedang sibuk diproses.
  String? get busyItemId => _busyItemId;

  // Timer untuk menunda eksekusi update quantity (debouncing).
  Timer? _debounceTimer;

  /// Daftarkan [CartService] agar ViewModel ini secara otomatis mendengarkan
  /// dan memperbarui UI setiap kali data keranjang berubah.
  @override
  List<ListenableServiceMixin> get listenableServices => [_cartService];

  /// Mengembalikan data keranjang ([CartModel]) saat ini.
  CartModel? get data => _cartService.cart;

  /// Mengembalikan jumlah item unik di keranjang.
  ///
  /// @returns [int] Jumlah total item.
  int get cartItemCount => _cartService.cartItemCount;

  /// Menghitung total harga dari semua item di keranjang.
  ///
  /// @returns [double] Total harga dari semua produk.
  double get totalPrice {
    final items = data?.items;
    if (items == null) return 0;
    // Menggunakan fold untuk menjumlahkan subtotal setiap item
    return items.fold(
        0, (sum, item) => sum + ((item.product?.price ?? 0) * (item.quantity ?? 0)));
  }

  /// Mengembalikan status apakah keranjang kosong.
  ///
  /// @returns `true` jika tidak ada item di keranjang.
  bool get isEmpty => data?.items == null || data!.items!.isEmpty;

  /// Memeriksa apakah item keranjang tertentu sedang diproses (busy).
  ///
  /// @param itemId ID CartItem yang diperiksa.
  /// @returns `true` jika ID item cocok dengan [_busyItemId].
  bool isItemBusy(String itemId) => _busyItemId == itemId;

  /// Memuat data keranjang awal jika belum ada.
  void initialise() {
    if (_cartService.cart == null) {
      _cartService.getCart();
    }
  }

  /// Mengupdate jumlah item keranjang dengan teknik Optimistic Update dan Debouncing.
  ///
  /// Perubahan kuantitas langsung di-update di UI, kemudian dikirim ke API setelah jeda singkat.
  ///
  /// @param cartItemId ID item keranjang.
  /// @param currentQty Jumlah saat ini.
  /// @param delta Perubahan jumlah (+1 atau -1).
  /// @returns [Future<void>]
  Future<void> updateQuantity(String cartItemId, int currentQty, int delta) async {
    final newQty = currentQty + delta;
    if (newQty < 1) return; // Batasan: kuantitas minimal 1

    // 1. Cari index item untuk update lokal
    final itemIndex = data?.items?.indexWhere((i) => i.id == cartItemId) ?? -1;
    if (itemIndex == -1) return;

    // Simpan nilai lama untuk rollback jika terjadi error
    final oldQty = data!.items![itemIndex].quantity;

    // Update LOCAL STATE (Optimistic - Perubahan kuantitas instan di UI)
    data!.items![itemIndex].quantity = newQty;
    notifyListeners();

    // 2. Batalkan timer sebelumnya jika pengguna menekan tombol lagi
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    // 3. Mulai Timer baru (Tunggu 500ms sebelum kirim ke API)
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        // Kirim request FINAL ke API
        await _cartService.updateItemQuantity(cartItemId, newQty);
      } catch (e) {
        // Rollback jika gagal terhubung ke API
        data!.items![itemIndex].quantity = oldQty;
        notifyListeners();
        _dialogService.showDialog(title: 'Gagal', description: 'Koneksi error');
      }
    });
  }

  /// Menghapus item dari keranjang.
  ///
  /// Menetapkan *busy state* pada item spesifik selama proses penghapusan.
  ///
  /// @param cartItemId ID item keranjang yang akan dihapus.
  /// @returns [Future<void>]
  Future<void> removeItem(String cartItemId) async {
    _busyItemId = cartItemId;
    notifyListeners();

    try {
      await _cartService.removeFromCart(cartItemId);
    } catch (e) {
      await _dialogService.showDialog(
        title: 'Gagal Menghapus',
        description: 'Cek koneksi Anda.',
      );
    } finally {
      _busyItemId = null;
      notifyListeners();
    }
  }

  /// Navigasi ke halaman checkout.
  ///
  /// Menampilkan dialog peringatan jika keranjang kosong.
  void navigateToCheckout() {
    if (isEmpty) {
      _dialogService.showDialog(
          title: 'Keranjang Kosong',
          description: 'Silakan tambahkan produk terlebih dahulu.');
      return;
    }
    _navigationService.navigateTo(checkoutViewRoute);
  }

  /// Memuat ulang data keranjang dari service.
  ///
  /// Digunakan untuk *pull-to-refresh*.
  ///
  /// @returns [Future<void>]
  Future<void> refresh() async {
    await _cartService.getCart();
  }

  /// Membersihkan timer debounce saat ViewModel dibuang.
  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}