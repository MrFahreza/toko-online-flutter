import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Key yang akan digunakan untuk menyimpan token JWT
const String _accessTokenKey = 'access_token';

/// Service untuk operasi penyimpanan data sensitif menggunakan **Flutter Secure Storage**.
///
/// Service ini memastikan data seperti JWT Token disimpan di *keychain* (iOS)
/// atau *keystore* (Android) yang aman, tidak dapat diakses oleh aplikasi lain.
class SecureStorageService {
  // Instance dari FlutterSecureStorage (dibuat sebagai konstanta)
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Membaca token JWT dari penyimpanan aman.
  ///
  /// @returns [Future<String?>] Token JWT atau `null` jika tidak ada.
  Future<String?> readAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Menyimpan token JWT ke penyimpanan aman.
  ///
  /// @param token String token JWT yang diperoleh saat login.
  /// @returns [Future<void>]
  Future<void> writeAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  /// Menghapus token JWT (biasanya dipanggil saat logout).
  ///
  /// @returns [Future<void>]
  Future<void> deleteAccessToken() async {
    await _storage.delete(key: _accessTokenKey);
  }

  /// Menghapus semua data yang tersimpan di *secure storage*.
  ///
  /// @returns [Future<void>]
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}