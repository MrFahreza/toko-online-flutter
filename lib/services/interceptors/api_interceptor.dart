import 'package:dio/dio.dart';
import '../../app/locator.dart';
import '../secure_storage_service.dart';

/// Interceptor Dio untuk menyuntikkan JWT Token ke header request.
///
/// Interceptor ini membaca Access Token dari [SecureStorageService]
/// dan menambahkannya ke header `Authorization: Bearer <token>`.
class ApiInterceptor extends Interceptor {
  // Ambil instance SecureStorageService dari locator untuk membaca token
  final SecureStorageService _storageService = locator<SecureStorageService>();

  /// Dipanggil sebelum request dikirim. Menambahkan header Authorization.
  ///
  /// Logika ini memastikan setiap permintaan ke API yang memerlukan otorisasi
  /// membawa token yang valid.
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // 1. Baca token dari penyimpanan aman
    final token = await _storageService.readAccessToken();

    // 2. Jika token ada, tambahkan ke header sebagai Bearer Token
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Lanjutkan request
    super.onRequest(options, handler);
  }

  /// Dipanggil saat response diterima.
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Logika kustom bisa ditambahkan di sini, misalnya dekripsi data.
    super.onResponse(response, handler);
  }

  /// Dipanggil saat terjadi error (misal 401, 403).
  ///
  /// Di sini dapat ditambahkan logika penanganan error global, seperti
  /// *auto-logout* jika status code adalah 401 (Unauthorized).
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Kode yang dikomentari dihilangkan sesuai permintaan:
    // if (err.response?.statusCode == 401) {
    //   locator<AuthService>().logout();
    // }
    super.onError(err, handler);
  }
}