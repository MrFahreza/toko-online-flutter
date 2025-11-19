import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:toko_online_flutter/app/locator.dart';
import 'package:toko_online_flutter/services/product_service.dart';
import 'package:toko_online_flutter/services/cart_service.dart';
import 'package:toko_online_flutter/models/product/product_model.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:toko_online_flutter/constants/route_name.dart';

/// ViewModel yang bertanggung jawab mengelola daftar produk (Product List).
///
/// Kelas ini menangani fitur *pagination*, pencarian produk, dan secara reaktif
/// memantau jumlah item di keranjang belanja ([CartService]).
class ProductListViewModel extends ReactiveViewModel {
  final _productService = locator<ProductService>();
  final _cartService = locator<CartService>();
  final _navigationService = locator<NavigationService>();
  final _snackbarService = locator<SnackbarService>();

  // --- State Produk ---
  /// Daftar produk yang saat ini ditampilkan di UI.
  List<ProductModel> products = [];
  // Halaman saat ini untuk kebutuhan pagination.
  int _currentPage = 1;
  // Status loading untuk memuat halaman berikutnya.
  bool _isLoadingMore = false;
  // Menunjukkan apakah masih ada produk lain di server yang bisa dimuat.
  bool _hasMoreProducts = true;

  // --- State Search ---
  // Kata kunci pencarian yang terakhir.
  String _searchKeyword = '';
  // Timer untuk menunda eksekusi pencarian (*debounce*).
  Timer? _debounceTimer;
  /// Controller untuk input teks pencarian.
  TextEditingController searchController = TextEditingController();
  /// Controller untuk memantau pergerakan scroll (untuk *load more*).
  final ScrollController scrollController = ScrollController();

  // --- Reactivity (Badge) ---

  /// Daftarkan [CartService] agar ViewModel ini secara otomatis mendengarkan
  /// dan memperbarui jumlah item keranjang.
  @override
  List<ListenableServiceMixin> get listenableServices => [_cartService];

  /// Mengembalikan jumlah item di keranjang belanja.
  ///
  /// Nilai ini diperbarui secara otomatis oleh sistem reaktif.
  ///
  /// @returns [int] Jumlah item dalam keranjang.
  int get cartItemCount => _cartService.cartItemCount;

  // --- Inisialisasi ---

  /// Dipanggil saat inisialisasi ViewModel.
  ///
  /// Fungsi ini memuat produk awal, memuat data keranjang awal, dan mengatur
  /// pendengar scroll.
  @override
  void initialise() {
    loadProducts();
    // Panggil getCart() sekali di awal agar service punya data count terbaru.
    _cartService.getCart();
    _setupScrollListener();
  }

  // --- Logic Search ---

  /// Dipanggil setiap kali teks pencarian berubah.
  ///
  /// Menggunakan [Timer] (*debounce*) untuk menunda pemanggilan pencarian selama 500ms.
  ///
  /// @param value Teks pencarian yang baru.
  void onSearchChanged(String value) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _searchKeyword = value;
      // Memuat ulang produk dari halaman 1
      loadProducts(isRefresh: true);
    });
  }

  // --- Logic Scroll ---

  /// Mengatur pendengar pada [scrollController] untuk mendeteksi kapan harus memuat lebih banyak produk.
  void _setupScrollListener() {
    scrollController.addListener(() {
      // Jika posisi scroll sudah melewati 70% dari batas maksimal
      if (scrollController.position.pixels >
          scrollController.position.maxScrollExtent * 0.7 &&
          !_isLoadingMore &&
          _hasMoreProducts) {
        loadMoreProducts();
      }
    });
  }

  // --- Logic Load Data ---

  /// Memuat produk dari API berdasarkan halaman dan kata kunci pencarian saat ini.
  ///
  /// @param isRefresh Jika `true`, data produk saat ini akan dihapus dan dimulai dari halaman 1.
  /// @returns [Future<void>]
  Future<void> loadProducts({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      _hasMoreProducts = true;
      products.clear();
      // UI akan diupdate setelah setBusy(false)
    }

    try {
      setBusy(true);
      final newProducts = await _productService.getProducts(
        page: _currentPage,
        search: _searchKeyword,
      );

      // Cek jika tidak ada produk yang kembali
      if (newProducts.isEmpty) {
        _hasMoreProducts = false;
      } else {
        products.addAll(newProducts);
      }
      setBusy(false);
    } catch (e) {
      setBusy(false);
      _snackbarService.showCustomSnackBar(
        message: 'Gagal: ${e.toString()}',
        duration: const Duration(seconds: 2),
        variant: 'default',
      );
    }
  }

  /// Memuat halaman produk berikutnya.
  ///
  /// Dipanggil oleh pendengar scroll saat pengguna mendekati akhir daftar.
  ///
  /// @returns [Future<void>]
  Future<void> loadMoreProducts() async {
    _isLoadingMore = true;
    notifyListeners(); // Update UI untuk menampilkan loading indicator

    _currentPage++;
    try {
      final newProducts = await _productService.getProducts(
          page: _currentPage, search: _searchKeyword);

      if (newProducts.isEmpty) {
        _hasMoreProducts = false;
      } else {
        products.addAll(newProducts);
      }
    } catch (_) {
      // Abaikan error di loadMore agar tidak mengganggu pengalaman scroll
    }

    _isLoadingMore = false;
    notifyListeners(); // Update UI setelah selesai memuat
  }

  /// Memuat ulang seluruh daftar produk (digunakan untuk *Pull-to-Refresh*).
  ///
  /// @returns [Future<void>]
  Future<void> refresh() async {
    await loadProducts(isRefresh: true);
    // Refresh cart count juga untuk memastikan badge selalu terbaru
    await _cartService.getCart();
  }

  /// Navigasi ke halaman detail produk yang dipilih.
  ///
  /// @param product Objek [ProductModel] yang detailnya akan ditampilkan.
  void navigateToProductDetail(ProductModel product) {
    // Navigasi dengan mengirim objek ProductModel sebagai argumen
    _navigationService.navigateTo(productDetailViewRoute, arguments: product);
  }

  /// Dipanggil saat ViewModel dibuang.
  ///
  /// Membatalkan timer dan membuang semua controller untuk menghindari kebocoran memori.
  @override
  void dispose() {
    _debounceTimer?.cancel();
    searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}