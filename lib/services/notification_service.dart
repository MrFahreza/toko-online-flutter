import 'package:stacked/stacked.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:toko_online_flutter/app/locator.dart';
import 'package:toko_online_flutter/models/auth/auth_model.dart';
import 'package:toko_online_flutter/services/api_service.dart';
import 'package:toko_online_flutter/services/secure_storage_service.dart';

/// Service untuk koneksi WebSocket (Socket.io) dan distribusi notifikasi real-time.
///
/// Kelas ini mengelola siklus hidup koneksi socket dan memublikasikan notifikasi
/// masuk menggunakan [ListenableServiceMixin].
class NotificationService with ListenableServiceMixin {
  final _apiService = locator<ApiService>();
  final _storageService = locator<SecureStorageService>();

  // Nilai reaktif yang menyimpan payload notifikasi terbaru.
  final ReactiveValue<Map<String, dynamic>?> _newNotification =
  ReactiveValue<Map<String, dynamic>?>(null);

  /// Instance socket koneksi. Nullable untuk pengelolaan lifecycle.
  IO.Socket? _socket;

  /// Mengembalikan payload notifikasi terbaru.
  ///
  /// Payload berisi `{'event': 'nama_event', 'data': payload_data}`.
  Map<String, dynamic>? get newNotification => _newNotification.value;

  /// Constructor. Mendaftarkan [_newNotification] ke list nilai reaktif.
  NotificationService() {
    listenToReactiveValues([_newNotification]);
  }

  /// Membuat dan memaksa koneksi WebSocket baru dengan token JWT.
  ///
  /// Fungsi ini memutuskan koneksi lama, mengambil token, dan inisiasi koneksi
  /// baru ke server Socket.io.
  ///
  /// @param role Peran pengguna (CS1, CS2, PEMBELI) yang digunakan untuk *joining room*.
  /// @returns [Future<void>]
  Future<void> connect({required String role}) async {
    final token = await _storageService.readAccessToken();

    if (token == null || token.isEmpty || role.isEmpty) return;

    // 1. PAKSA PUTUS KONEKSI LAMA (JIKA ADA)
    disconnect();

    try {
      // 2. BUAT KONEKSI BARU DENGAN OPSI 'FORCE NEW'
      _socket = IO.io(
        _apiService.socketApiUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setExtraHeaders({'Authorization': 'Bearer $token'})
            .setQuery({'token': token})
            .enableForceNew() // Paksa instance baru (Fix Stale Connection)
            .build(),
      );

      _socket!.connect();

      _socket!.onConnect((_) {
        // Setup Listeners saat koneksi berhasil
        _setupListeners(role);
      });

      // Error Handling (Hanya log, bukan print)
      _socket!.onDisconnect((_) {});
      _socket!.onError((err) {});
      _socket!.onConnectError((err) {});
    } catch (e) {
      // Failed to connect socket
    }
  }

  /// Menyiapkan listener untuk event WebSocket berdasarkan peran (role).
  ///
  /// Menggunakan `.off()` di awal untuk mencegah penumpukan listener.
  ///
  /// @param role String peran pengguna (misal: "CS1").
  void _setupListeners(String role) {
    // Hapus listener lama dulu untuk keamanan ganda
    _socket!.off('new_task');
    _socket!.off('status_update');
    _socket!.off('order_finished');

    // Listener untuk CS (CS1 & CS2)
    if (role == UserRole.CS1.name || role == UserRole.CS2.name) {
      // Diterima saat pembeli baru upload bukti pembayaran
      _socket!.on('new_task', (data) {
        _newNotification.value = {'event': 'new_task', 'data': data};
      });

      // CS2 juga perlu tahu jika order selesai (oleh Pembeli)
      if (role == UserRole.CS2.name) {
        _socket!.on('order_finished', (data) {
          _newNotification.value = {'event': 'order_finished', 'data': data};
        });
      }
    }

    // Listener untuk Pembeli
    if (role == UserRole.PEMBELI.name) {
      // Diterima saat CS1/CS2 mengubah status pesanan
      _socket!.on('status_update', (data) {
        _newNotification.value = {'event': 'status_update', 'data': data};
      });
    }
  }

  /// Membersihkan state notifikasi ([_newNotification]) agar tidak diproses ulang
  /// oleh ViewModels.
  void clearNotification() {
    _newNotification.value = null;
  }

  /// Memutus koneksi WebSocket secara total dan membersihkan sumber daya.
  ///
  /// Dipanggil saat logout atau inisiasi koneksi baru.
  void disconnect() {
    try {
      if (_socket != null) {
        _socket!.disconnect();
        _socket!.dispose(); // Hancurkan object socket
        _socket = null; // Null-kan variabel
      }
    } catch (_) {
      // Abaikan error saat dispose
    }
    _newNotification.value = null;
  }
}