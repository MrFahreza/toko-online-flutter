import 'package:dio/dio.dart';
import 'package:toko_online_flutter/app/locator.dart';
import 'package:toko_online_flutter/constants/api_endpoints.dart';
import 'package:toko_online_flutter/models/product/product_model.dart';
import 'api_service.dart';

/// Service untuk manajemen data Produk.
///
/// Kelas ini menangani interaksi dengan API untuk mengambil daftar produk
/// (dengan pagination/pencarian) dan detail produk.
class ProductService {
  final _apiService = locator<ApiService>();

  /// Mendapatkan daftar semua produk dengan dukungan pagination dan pencarian.
  ///
  /// Mengirimkan *query parameters* untuk mengontrol halaman, batas, dan kata kunci pencarian.
  ///
  /// @param page Nomor halaman (default 1).
  /// @param limit Batas item per halaman (default 10).
  /// @param search Kata kunci pencarian (berdasarkan nama produk).
  /// @returns [Future<List<ProductModel>>] Daftar produk.
  /// @throws [Exception] jika gagal.
  Future<List<ProductModel>> getProducts({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };

      // Tambahkan parameter search jika tidak null dan tidak kosong
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _apiService.httpClient.get(
        ApiEndpoints.products,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = ProductListResponse.fromJson(response.data);
        if (responseData.data != null) {
          return responseData.data!;
        }
      }
      return [];
    } on DioException catch (e) {
      final errorMessage = _apiService.handleError(e);
      throw Exception(errorMessage);
    }
  }

  /// Mendapatkan detail satu produk berdasarkan ID.
  ///
  /// @param productId ID unik produk.
  /// @returns [Future<ProductModel>] Objek detail produk.
  /// @throws [Exception] jika gagal.
  Future<ProductModel> getProductDetails(String productId) async {
    try {
      // Panggil endpoint dengan ID
      final response = await _apiService.httpClient
          .get(ApiEndpoints.productDetail(productId));

      if (response.statusCode == 200 && response.data != null) {
        // Response data tunggal berada di field 'data'
        final responseData = response.data['data'];
        return ProductModel.fromJson(responseData);
      }
      throw Exception('Gagal mendapatkan detail produk.');
    } on DioException catch (e) {
      final errorMessage = _apiService.handleError(e);
      throw Exception(errorMessage);
    }
  }
}