import 'package:dio/dio.dart';
import 'package:stacked/stacked.dart';
import 'package:toko_online_flutter/app/locator.dart';
import 'package:toko_online_flutter/constants/api_endpoints.dart';
import 'package:toko_online_flutter/models/cart/cart_model.dart';
import 'package:toko_online_flutter/services/api_service.dart';
import 'package:toko_online_flutter/services/auth_service.dart';
import 'package:toko_online_flutter/models/auth/auth_model.dart';

/// Service untuk manajemen keranjang belanja, terproteksi hanya untuk [UserRole.PEMBELI].
///
/// Kelas ini mengelola state keranjang belanja dan interaksi dengan endpoint Cart API.
class CartService with ListenableServiceMixin {
  final _apiService = locator<ApiService>();
  final _authService = locator<AuthService>();

  // Nilai reaktif yang menyimpan model keranjang saat ini.
  final ReactiveValue<CartModel?> _cart = ReactiveValue<CartModel?>(null);

  /// Mengembalikan model keranjang saat ini.
  CartModel? get cart => _cart.value;

  /// Mengembalikan jumlah item unik di keranjang.
  ///
  /// @returns [int] Jumlah item unik (bukan total kuantitas).
  int get cartItemCount => _cart.value?.items?.length ?? 0;

  /// Constructor. Mendaftarkan [_cart] ke dalam list nilai reaktif.
  CartService() {
    listenToReactiveValues([_cart]);
  }

  /// Memperbarui nilai [_cart] dan memicu pemberitahuan ke pendengar.
  void _updateCart(CartModel? cart) {
    _cart.value = cart;
  }

  /// Mengurai [Response] dari API menjadi objek [CartModel].
  ///
  /// @param response Response Dio dari API.
  /// @returns [CartModel] yang telah diparsing.
  /// @throws [Exception] jika data keranjang kosong atau format salah.
  CartModel _parseCartResponse(Response response) {
    if (response.statusCode == 200 && response.data != null) {
      final responseData = response.data['data'];
      if (responseData != null) {
        return CartModel.fromJson(responseData);
      }
    }
    throw Exception("Data keranjang kosong atau format salah");
  }

  /// Getter helper untuk memeriksa apakah user yang login adalah Pembeli.
  bool get _isBuyer {
    return _authService.currentRole == UserRole.PEMBELI;
  }

  /// Mengambil data keranjang dari API.
  ///
  /// Melewati API call jika user bukan Pembeli untuk menghindari error 403.
  ///
  /// @returns [Future<CartModel?>] model keranjang, atau `null` jika kosong/gagal.
  Future<CartModel?> getCart() async {
    if (!_isBuyer) return null;

    try {
      final response = await _apiService.httpClient.get(ApiEndpoints.cart);
      final cart = _parseCartResponse(response);
      _updateCart(cart);
      return cart;
    } on DioException catch (e) {
      // Jika error 404 (belum punya cart) atau 403 (akses ditolak), kita anggap keranjang kosong.
      if (e.response?.statusCode == 404 || e.response?.statusCode == 403) {
        _updateCart(null);
        return null;
      }
      return null;
    }
  }

  /// Menambahkan item ke keranjang.
  ///
  /// @param productId ID Produk.
  /// @param quantity Jumlah yang ditambahkan.
  /// @returns [Future<CartModel?>] model keranjang yang diperbarui.
  /// @throws [Exception] jika terjadi error API atau jika user bukan Pembeli.
  Future<CartModel?> addToCart(
      {required String productId, required int quantity}) async {
    if (!_isBuyer) throw Exception('Hanya Pembeli yang bisa belanja.');

    try {
      final response = await _apiService.httpClient.post(
        ApiEndpoints.cartAdd,
        data: {'productId': productId, 'quantity': quantity},
      );
      final cart = _parseCartResponse(response);
      _updateCart(cart);
      return cart;
    } on DioException catch (e) {
      final msg = _apiService.handleError(e);
      throw Exception(msg);
    }
  }

  /// Menghapus item dari keranjang.
  ///
  /// @param cartItemId ID unik CartItem yang akan dihapus.
  /// @returns [Future<CartModel?>] model keranjang yang diperbarui.
  /// @throws [Exception] jika terjadi error API.
  Future<CartModel?> removeFromCart(String cartItemId) async {
    if (!_isBuyer) return null;

    try {
      final response = await _apiService.httpClient.post(
        ApiEndpoints.cartRemove,
        data: {'cartItemId': cartItemId},
      );
      final cart = _parseCartResponse(response);
      _updateCart(cart);
      return cart;
    } on DioException catch (e) {
      final msg = _apiService.handleError(e);
      throw Exception(msg);
    }
  }

  /// Mengupdate jumlah item di keranjang (Set Quantity).
  ///
  /// @param cartItemId ID unik CartItem.
  /// @param quantity Jumlah total yang diinginkan.
  /// @returns [Future<CartModel?>] model keranjang yang diperbarui.
  /// @throws [Exception] jika terjadi error API.
  Future<CartModel?> updateItemQuantity(
      String cartItemId, int quantity) async {
    if (!_isBuyer) return null;

    try {
      final response = await _apiService.httpClient.patch(
        ApiEndpoints.cartSetQuantity(cartItemId),
        data: {'quantity': quantity},
      );
      final cart = _parseCartResponse(response);
      _updateCart(cart);
      return cart;
    } on DioException catch (e) {
      final msg = _apiService.handleError(e);
      throw Exception(msg);
    }
  }
}