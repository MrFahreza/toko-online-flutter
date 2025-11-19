import 'package:stacked/stacked.dart';
import 'package:dio/dio.dart';
import 'package:toko_online_flutter/app/locator.dart';
import 'package:stacked_services/stacked_services.dart';
import '../constants/api_endpoints.dart';
import '../constants/route_name.dart';
import '../models/auth/auth_model.dart';
import 'secure_storage_service.dart';
import 'api_service.dart';
import 'notification_service.dart';

/// Service untuk manajemen autentikasi dan sesi pengguna.
///
/// Kelas ini mengelola status login, token akses, dan peran pengguna
/// menggunakan [ListenableServiceMixin] untuk reaktivitas.
class AuthService with ListenableServiceMixin {
  final _apiService = locator<ApiService>();
  final _storageService = locator<SecureStorageService>();
  final _snackbarService = locator<SnackbarService>();
  final _notificationService = locator<NotificationService>();
  final _navigationService = locator<NavigationService>();

  // Nilai reaktif yang menyimpan objek pengguna yang sedang login.
  final ReactiveValue<User?> _currentUser = ReactiveValue<User?>(null);

  /// Mengembalikan objek [User] saat ini.
  User? get currentUser => _currentUser.value;

  /// Mengembalikan status login.
  ///
  /// @returns `true` jika pengguna sudah login.
  bool get isLoggedIn => _currentUser.value != null;

  /// Mengembalikan role user saat ini.
  ///
  /// @returns [UserRole] atau `null`.
  UserRole? get currentRole => _currentUser.value?.role;

  /// Constructor. Mendaftarkan [_currentUser] ke dalam list nilai reaktif.
  AuthService() {
    listenToReactiveValues([_currentUser]);
  }

  /// Mencoba login otomatis dari token yang tersimpan di [SecureStorageService].
  ///
  /// Saat ini hanya memeriksa keberadaan token. Implementasi relogin penuh
  /// (memanggil endpoint `/me`) dilewati.
  ///
  /// @returns [Future<void>]
  Future<void> tryAutoLogin() async {
    final token = await _storageService.readAccessToken();
    // Jika tidak ada token atau token kosong
    if (token == null || token.isEmpty) {
      _currentUser.value = null;
      return;
    }
    // Karena relogin penuh dilewati, kita reset state meskipun ada token lama.
    // Di aplikasi nyata, token ini akan divalidasi ke server.
    _currentUser.value = null;
  }

  /// Logika login dengan kredensial [email] dan [password].
  ///
  /// Melakukan permintaan POST ke endpoint login, menyimpan token, mengatur state
  /// pengguna, dan menghubungkan ke WebSocket.
  ///
  /// @param email Email pengguna.
  /// @param password Password pengguna.
  /// @returns [Future<bool>] `true` jika login berhasil, `false` jika gagal.
  Future<bool> login({required String email, required String password}) async {
    try {
      final response = await _apiService.httpClient.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        final AuthModel authModel = AuthModel.fromJson(response.data);
        final accessToken = authModel.data?.accessToken;
        final userApi = authModel.data?.user;

        if (accessToken == null || userApi == null) {
          throw Exception('Token atau data user kosong');
        }

        // 1. Simpan token dan set state
        await _storageService.writeAccessToken(accessToken);
        _currentUser.value = userApi;

        // 2. Koneksi WebSocket untuk notifikasi real-time berdasarkan role
        await _notificationService.connect(role: userApi.role.name);
        _snackbarService.showCustomSnackBar(
            message: 'Login berhasil sebagai ${userApi.role.name}',
            title: 'Berhasil',
            duration: const Duration(seconds: 2),
          variant: 'default',);
        return true;
      }
      return false;
    } on DioException catch (e) {
      // Tangani error Dio dan ekstrak pesan yang user-friendly
      final message = _apiService.handleError(e);
      _snackbarService.showCustomSnackBar(
        message: 'Gagal Login: $message',
        title: 'Error',
        duration: const Duration(seconds: 2),
        variant: 'default',
      );
      return false;
    } catch (e) {
      // Tangani error lain yang tidak terduga
      _snackbarService.showCustomSnackBar(
          message: 'Terjadi kesalahan tidak terduga: ${e.toString()}',
          title: 'Error',
          duration: const Duration(seconds: 2),
        variant: 'default',);
      return false;
    }
  }

  /// Memutus sesi pengguna saat ini.
  ///
  /// Menghapus token dari penyimpanan, mereset state, dan memutus koneksi WebSocket.
  ///
  /// @returns [Future<void>]
  Future<void> logout() async {
    await _storageService.deleteAccessToken();
    _currentUser.value = null; // Reset state pengguna
    _notificationService.disconnect(); // Putus koneksi real-time
    _snackbarService.showCustomSnackBar(
        message: 'Berhasil Logout.', duration: const Duration(seconds: 2),
      variant: 'default',);
    await _navigationService.replaceWith(authViewRoute);
  }
}