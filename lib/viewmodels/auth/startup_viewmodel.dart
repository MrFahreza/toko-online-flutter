import 'package:stacked/stacked.dart';
import 'package:flutter_jailbreak_detection_plus/flutter_jailbreak_detection_plus.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:toko_online_flutter/app/locator.dart';
import 'package:toko_online_flutter/services/auth_service.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../constants/route_name.dart';

/// ViewModel yang bertanggung jawab mengelola logika awal saat aplikasi dimulai (Startup).
///
/// Logika meliputi pemeriksaan keamanan perangkat (Root/Jailbreak), pengaktifan
/// mode aman (anti-screenshot), dan penentuan rute navigasi.
class StartupViewModel extends BaseViewModel {
  final _authService = locator<AuthService>();
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();

  // Pesan error fatal yang terjadi selama proses startup (misalnya, keamanan).
  String? _startupError;

  /// Mengembalikan pesan error fatal yang terjadi selama proses startup.
  ///
  /// @returns [String?] Pesan error atau `null` jika tidak ada.
  String? get startupError => _startupError;

  /// Logika inisialisasi utama yang dijalankan saat aplikasi pertama kali dibuka.
  ///
  /// @returns [Future<void>]
  Future<void> runStartupLogic() async {
    // 1. Aktifkan Keamanan Layar (Anti Screenshot/Recording)
    await _enableSecureMode();

    // 2. Cek Keamanan Perangkat (Root/Jailbreak)
    await _checkSecurity();
    if (_startupError != null) return; // Hentikan jika ada error fatal

    // 3. Coba Login Otomatis
    await _authService.tryAutoLogin();

    // Beri jeda singkat untuk branding/splash screen
    await Future.delayed(const Duration(milliseconds: 1000));

    // Tentukan rute tujuan
    final targetRoute = _authService.isLoggedIn ? homeViewRoute : authViewRoute;
    // Ganti layar startup dengan layar tujuan
    _navigationService.replaceWith(targetRoute);
  }

  // --- LOGIKA SCREEN PROTECTOR ---

  /// Mengaktifkan mode aman (anti-screenshot/screen recording) pada aplikasi.
  ///
  /// Menggunakan [ScreenProtector] untuk mencegah kebocoran data.
  ///
  /// @returns [Future<void>]
  Future<void> _enableSecureMode() async {
    try {
      // Android: Mencegah Screenshot & Screen Recording
      await ScreenProtector.preventScreenshotOn();

      // iOS: Mengaktifkan Blur saat aplikasi masuk ke Recent Apps/Background
      await ScreenProtector.protectDataLeakageWithBlur();
    } catch (e) {
      // Gagal mengaktifkan secure mode, tetapi tidak fatal
    }
  }

  // --- LOGIKA ROOT DETECTION ---

  /// Melakukan pengecekan keamanan perangkat (Root/Jailbreak dan Developer Mode).
  ///
  /// Jika perangkat dianggap tidak aman, [startupError] akan diisi, dan dialog akan ditampilkan.
  ///
  /// @returns [Future<void>]
  Future<void> _checkSecurity() async {
    try {
      // Deteksi Root / Jailbreak ATAU Developer Mode
      bool isCompromised = await FlutterJailbreakDetectionPlus.jailbroken;

      if (isCompromised) {
        _startupError = 'Perangkat tidak aman (Rooted/Jailbroken).';
        await _dialogService.showDialog(
          title: 'Keamanan',
          description:
          'Aplikasi tidak dapat berjalan di perangkat yang dimodifikasi demi keamanan transaksi.',
          buttonTitle: 'Keluar',
        );
        return;
      }
    } catch (e) {
      // Fail-safe: Jika deteksi gagal, abaikan
    }
  }
}