import 'package:get_it/get_it.dart';
import 'package:stacked_services/stacked_services.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';
import '../services/product_service.dart';
import '../services/secure_storage_service.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';

/// Global instance untuk service locator ([GetIt]).
///
/// Digunakan untuk mengakses instance service di seluruh aplikasi (Dependency Injection).
final locator = GetIt.instance;

/// Mendaftarkan semua service dan utilitas sebagai **Lazy Singleton**.
///
/// **Lazy Singleton** berarti instance service hanya akan dibuat saat
/// pertama kali service tersebut diminta (di-*resolve*).
///
/// Dipanggil sekali saat aplikasi startup.
void setupLocator() {
  // --- Stacked Services (UI/Navigation/Dialogs) ---
  // Daftarkan NavigationService untuk navigasi tanpa konteks
  locator.registerLazySingleton(() => NavigationService());
  // Daftarkan DialogService untuk menampilkan dialog
  locator.registerLazySingleton(() => DialogService());
  // Daftarkan SnackbarService untuk menampilkan notifikasi singkat
  locator.registerLazySingleton(() => SnackbarService());

  // --- Core Infrastructure Services ---
  // Service untuk menyimpan data sensitif secara aman
  locator.registerLazySingleton(() => SecureStorageService());
  // Service dasar untuk komunikasi HTTP/API
  locator.registerLazySingleton(() => ApiService());

  // --- Feature/Business Logic Services ---
  // Service untuk menangani logika autentikasi
  locator.registerLazySingleton(() => AuthService());
  // Service untuk menangani notifikasi real-time (misalnya, WebSockets)
  locator.registerLazySingleton(() => NotificationService());
  // Service untuk manajemen data produk
  locator.registerLazySingleton(() => ProductService());
  // Service untuk manajemen keranjang belanja
  locator.registerLazySingleton(() => CartService());
  // Service untuk manajemen pesanan dan proses checkout
  locator.registerLazySingleton(() => OrderService());
}