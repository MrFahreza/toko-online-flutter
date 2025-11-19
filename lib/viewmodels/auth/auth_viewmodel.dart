import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:toko_online_flutter/app/locator.dart';
import 'package:toko_online_flutter/services/auth_service.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../constants/app_strings.dart';
import '../../constants/route_name.dart';

/// ViewModel untuk manajemen tampilan dan logika Login/Autentikasi.
///
/// Kelas ini mengelola pilihan peran pengguna dan memicu proses login.
class AuthViewModel extends BaseViewModel {
  final _authService = locator<AuthService>();
  final _navigationService = locator<NavigationService>();
  final _snackbarService = locator<SnackbarService>();

  /// PETA KREDENSIAL SIMULASI.
  ///
  /// Data ini *hardcoded* dan hanya digunakan untuk tujuan simulasi dan pengujian.
  static const Map<String, String> _credentials = {
    AppStrings.roleBuyer: 'pembeli@example.com',
    AppStrings.roleCS1: 'cs1@example.com',
    AppStrings.roleCS2: 'cs2@example.com',
  };

  /// Password statis yang sama untuk semua role (sesuai seed backend).
  static const String _staticPassword = 'password123';

  /// Pesan error yang ditampilkan di UI saat login gagal.
  String? _errorMessage;

  /// Mengembalikan pesan error saat ini.
  String? get errorMessage => _errorMessage;

  // --- State untuk Pilihan Role ---
  /// Role yang sedang dipilih di UI (default Pembeli).
  String _selectedRole = AppStrings.roleBuyer;

  /// Mengembalikan role yang sedang dipilih.
  String get selectedRole => _selectedRole;

  /// Controller untuk simulasi tampilan email (Read Only).
  final TextEditingController emailController =
  TextEditingController(text: 'pembeli@example.com');

  /// Controller untuk simulasi tampilan password (Read Only).
  final TextEditingController passwordController =
  TextEditingController(text: '••••••••');

  /// Method untuk memilih Role (Mengupdate tampilan & field email otomatis).
  ///
  /// Fungsi ini memperbarui [selectedRole] dan mengisi otomatis field email
  /// sesuai dengan peran yang dipilih dari [_credentials].
  ///
  /// @param role String nama role yang dipilih (misal: 'CS Layer 1').
  void selectRole(String role) {
    _selectedRole = role;

    // Update dummy email
    emailController.text = _credentials[role] ?? 'user@example.com';

    notifyListeners();
  }

  /// Memulai proses login menggunakan role yang sedang dipilih.
  ///
  /// Memanggil [AuthService.login] dan menavigasi ke Home View jika berhasil.
  ///
  /// @returns [Future<void>]
  Future<void> login() async {
    _errorMessage = null;
    setBusy(true);

    // Ambil email dari Map statis dan gunakan password statis
    final email = _credentials[_selectedRole] ?? '';
    const password = _staticPassword;

    // Panggil service login
    final success = await _authService.login(email: email, password: password);

    if (success) {
      // Tampilkan snackbar sukses
      _snackbarService.showCustomSnackBar(
          message: 'Login Success!',
          title: 'Berhasil',
          variant: 'default',
          duration: const Duration(seconds: 2));
      // Navigasi ke Home (Dashboard) dan hapus stack sebelumnya
      await _navigationService.clearStackAndShow(homeViewRoute);
    } else {
      // Login gagal (error koneksi, dll)
      _errorMessage = 'Gagal terhubung. Cek server.';
    }

    setBusy(false);
  }

  /// Membersihkan [TextEditingController] saat ViewModel dibuang.
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}