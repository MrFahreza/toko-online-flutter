import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:toko_online_flutter/app/locator.dart';
import 'package:toko_online_flutter/models/product/product_model.dart';
import 'package:toko_online_flutter/services/cart_service.dart';

/// ViewModel yang bertanggung jawab mengelola logika di halaman detail produk.
///
/// Termasuk mengelola kuantitas pesanan dan proses menambahkan produk ke keranjang belanja.
class ProductDetailViewModel extends BaseViewModel {
  /// Model data produk yang sedang ditampilkan.
  final ProductModel product;

  /// Controller untuk mengelola input teks kuantitas secara manual.
  final TextEditingController qtyController = TextEditingController(text: '1');

  /// Membuat instance [ProductDetailViewModel] dengan produk yang diberikan.
  ///
  /// @param product Objek [ProductModel] detail.
  ProductDetailViewModel(this.product);

  final _snackbarService = locator<SnackbarService>();
  final _cartService = locator<CartService>();

  // Kuantitas produk yang dipilih pengguna.
  int _quantity = 1;

  /// Mengembalikan kuantitas produk yang dipilih saat ini.
  ///
  /// @returns [int] Jumlah barang.
  int get quantity => _quantity;

  /// Dipanggil saat ViewModel dibuang.
  ///
  /// Pastikan untuk membuang [qtyController] untuk menghindari kebocoran memori.
  @override
  void dispose() {
    qtyController.dispose();
    super.dispose();
  }

  /// Memperbarui kuantitas pesanan saat tombol '+' atau '-' ditekan.
  ///
  /// @param delta Nilai perubahan kuantitas (+1 atau -1).
  void updateQuantity(int delta) {
    // Ambil nilai dari text field saat ini (jika user baru mengetik)
    int currentVal = int.tryParse(qtyController.text) ?? _quantity;
    int newQty = currentVal + delta;

    // Kuantitas minimum adalah 1
    if (newQty < 1) newQty = 1;

    _quantity = newQty;
    // Sinkronkan text field dengan nilai kuantitas yang baru
    qtyController.text = _quantity.toString();

    // Pindahkan kursor ke akhir teks agar UX enak saat diklik berulang
    qtyController.selection =
        TextSelection.fromPosition(TextPosition(offset: qtyController.text.length));
    notifyListeners();
  }

  /// Memperbarui nilai kuantitas saat pengguna mengetik manual di TextField.
  ///
  /// @param value String nilai teks dari TextField.
  void onQuantityTyped(String value) {
    // Kita biarkan user mengetik apa saja; validasi ketat dilakukan saat klik tombol Beli.
    if (value.isEmpty) {
      // Jika kosong, anggap 0 untuk tujuan validasi
      _quantity = 0;
    } else {
      final parsed = int.tryParse(value);
      if (parsed != null) {
        _quantity = parsed;
      }
      // Jika tidak valid (bukan angka), biarkan _quantity tetap pada nilai terakhir
    }
    notifyListeners();
  }

  /// Menambahkan produk ke keranjang belanja dengan kuantitas yang dipilih.
  ///
  /// Akan melakukan validasi kuantitas sebelum memanggil service.
  ///
  /// @returns [Future<void>]
  Future<void> addToCart() async {
    // 1. VALIDASI INPUT
    if (_quantity <= 0) {
      _snackbarService.showCustomSnackBar(
        message: 'Jumlah pesanan minimal 1 barang!',
        title: 'Input Tidak Valid',
        duration: const Duration(seconds: 2),
        variant: 'default',
      );
      // Reset ke 1 agar user sadar
      _quantity = 1;
      qtyController.text = '1';
      notifyListeners();
      return;
    }

    // 2. Mulai Loading
    setBusy(true);
    try {
      // Panggil service untuk menambahkan ke keranjang
      await _cartService.addToCart(
        productId: product.id!,
        quantity: _quantity,
      );

      _snackbarService.showCustomSnackBar(
        message: 'Berhasil ditambahkan ke keranjang!',
        title: 'Sukses',
        duration: const Duration(seconds: 2),
        variant: 'default',
      );
    } catch (e) {
      // Tampilkan error jika gagal
      _snackbarService.showCustomSnackBar(
        message: e.toString().replaceAll("Exception: ", ""),
        title: 'Gagal',
        duration: const Duration(seconds: 2),
        variant: 'default',
      );
    } finally {
      setBusy(false);
    }
  }
}