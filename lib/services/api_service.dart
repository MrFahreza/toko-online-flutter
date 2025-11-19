import 'dart:io';

import 'package:dio/dio.dart';
import 'interceptors/api_interceptor.dart';

// Variabel compile-time yang di-inject saat build
const String _baseUrl =
String.fromEnvironment('BASE_URL', defaultValue: 'http://localhost:3000');
const String _socketUrl =
String.fromEnvironment('SOCKET_URL', defaultValue: 'http://localhost:3001');

/// Service untuk manajemen klien HTTP ([Dio]) dan menangani konfigurasi API.
///
/// Kelas ini menginisialisasi Dio dengan Interceptor dan menyediakan fungsi
/// penanganan error global.
class ApiService {
  late final Dio _dio;
  late final String _baseApiUrl;
  late final String _socketApiUrl;

  /// Mengembalikan instance Dio yang sudah dikonfigurasi.
  Dio get httpClient => _dio;

  /// Mengembalikan URL dasar API REST.
  String get baseApiUrl => _baseApiUrl;

  /// Mengembalikan URL untuk koneksi WebSocket.
  String get socketApiUrl => _socketApiUrl;

  /// Constructor untuk inisialisasi [ApiService].
  ApiService() {
    // Set URL dari variabel environment/compile-time
    _baseApiUrl = _baseUrl;
    _socketApiUrl = _socketUrl;

    // Konfigurasi dasar Dio
    final BaseOptions options = BaseOptions(
      baseUrl: _baseApiUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Inisialisasi Dio
    _dio = Dio(options);

    // Tambahkan Interceptor JWT untuk otorisasi otomatis
    _dio.interceptors.add(ApiInterceptor());
  }

  /// Menangani [DioException] dan mengurai pesan error yang bersih.
  ///
  /// Fungsi ini mencoba mengekstrak pesan error dari body response (misalnya dari backend NestJS),
  /// atau memberikan pesan yang ramah pengguna untuk kegagalan jaringan/timeout.
  ///
  /// @param error Objek [DioException] yang dilempar.
  /// @returns Pesan error string yang mudah dibaca.
  dynamic handleError(DioException error) {
    // 1. Coba ekstrak pesan dari body response (JSON)
    if (error.response?.data != null) {
      try {
        final responseData = error.response!.data;
        // NestJS backend mengirim pesan di field 'message'
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          return responseData['message'];
        }
      } catch (_) {
        // Jika gagal parsing body
        return 'Kesalahan data pada server.';
      }
    }

    // 2. Tangani kesalahan jaringan (timeout, koneksi terputus, dll.)
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Waktu koneksi habis. Mohon cek koneksi internet Anda.';

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          return 'Sesi berakhir, token tidak valid, atau kredensial salah.';
        } else if (statusCode == 403) {
          return 'Anda tidak memiliki izin (Forbidden).';
        }
        return 'Terjadi kesalahan pada server ($statusCode).';

      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return 'Tidak ada koneksi internet atau server tidak dapat dijangkau.';
        }
        return 'Kesalahan tidak terduga.';

      default:
        return 'Gagal terhubung ke server.';
    }
  }
}