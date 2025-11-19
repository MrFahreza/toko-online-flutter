import 'package:stacked/stacked.dart';

import '../../app/locator.dart';
import '../../models/auth/auth_model.dart';
import '../../services/auth_service.dart';

/// ViewModel yang bertanggung jawab untuk mengelola logika di Home View,
/// termasuk memantau status login dan peran pengguna.
///
/// ViewModel ini merupakan [ReactiveViewModel] karena mendengarkan perubahan
/// status dari [AuthService].
class HomeViewModel extends ReactiveViewModel {
  // Service untuk mengelola autentikasi pengguna.
  final AuthService _authService = locator<AuthService>();

  /// Daftarkan [AuthService] agar ViewModel ini "mendengar" setiap kali
  /// data atau status di service tersebut berubah.
  @override
  List<ListenableServiceMixin> get listenableServices => [_authService];

  /// Mengembalikan peran ([UserRole]) dari pengguna yang sedang login.
  ///
  /// @returns [UserRole] pengguna saat ini, atau `null` jika belum login.
  UserRole? get userRole => _authService.currentRole;

  /// Mengembalikan status kesiapan tampilan beranda.
  ///
  /// Siap ketika pengguna sudah login, peran sudah teridentifikasi, dan
  /// peran bukan [UserRole.UNKNOWN].
  ///
  /// @returns `true` jika data pengguna siap untuk ditampilkan.
  bool get isReady =>
      _authService.isLoggedIn && userRole != null && userRole != UserRole.UNKNOWN;

  /// Memulai proses *logout* pengguna.
  ///
  /// Setelah pemanggilan, [AuthService] akan memperbarui status login.
  void initiateLogout() {
    // Memanggil fungsi logout pada AuthService
    _authService.logout();
  }
}