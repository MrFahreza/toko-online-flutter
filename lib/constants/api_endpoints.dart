/// Kelas yang berisi semua string endpoint API yang digunakan di aplikasi.
///
/// Semua properti didefinisikan sebagai `static const String` atau `static String Function()`
/// untuk kemudahan akses tanpa inisialisasi.
class ApiEndpoints {
  // --- Auth & Users ---

  /// Endpoint untuk proses login pengguna (POST).
  static const String login = '/auth/login';

  // --- Products ---

  /// Endpoint untuk mendapatkan daftar semua produk (GET).
  static const String products = '/products';

  /// Endpoint untuk mendapatkan detail produk spesifik (GET).
  ///
  /// @param id ID unik produk.
  static String productDetail(String id) => '/products/$id';

  // --- Cart ---

  /// Endpoint untuk mendapatkan detail keranjang belanja pengguna (GET).
  static const String cart = '/cart';

  /// Endpoint untuk menambahkan produk baru ke keranjang (POST).
  static const String cartAdd = '/cart/add';

  /// Endpoint untuk menghapus item dari keranjang (DELETE).
  static const String cartRemove = '/cart/remove';

  /// Endpoint untuk mengubah kuantitas item di keranjang (PUT).
  ///
  /// @param cartItemId ID unik item keranjang yang akan diubah.
  static String cartSetQuantity(String cartItemId) => '/cart/item/$cartItemId';

  // --- Orders ---

  /// Endpoint untuk membuat pesanan baru dari keranjang (Checkout - POST).
  static const String checkout = '/orders/checkout';

  /// Endpoint untuk mendapatkan riwayat pesanan Pembeli (GET).
  static const String orderHistory = '/orders/history';

  /// Endpoint untuk Pembeli mengupload bukti bayar.
  static String uploadProof(String orderId) => '/orders/$orderId/upload-proof';

  // CS Layer 1

  /// Endpoint untuk mendapatkan daftar pesanan yang menunggu verifikasi pembayaran (GET).
  static const String pendingVerificationList = '/orders/pending/verification';

  /// Endpoint untuk menyetujui bukti pembayaran (PUT).
  ///
  /// @param orderId ID pesanan yang akan disetujui.
  static String approvePayment(String orderId) => '/orders/$orderId/approve-payment';

  /// Endpoint untuk menolak bukti pembayaran dan membatalkan pesanan (PUT).
  ///
  /// @param orderId ID pesanan yang akan ditolak.
  static String rejectPayment(String orderId) => '/orders/$orderId/reject-payment';

  /// Endpoint untuk mendapatkan riwayat pesanan yang telah diproses oleh CS1 (GET).
  static const String cs1HistoryList = '/orders/cs1/history';

  // CS Layer 2

  /// Endpoint untuk mendapatkan daftar pesanan yang menunggu diproses gudang (GET).
  static const String pendingProcessingList = '/orders/pending/processing';

  /// Endpoint untuk mendapatkan riwayat pesanan yang telah diproses oleh CS2 (GET).
  static const String cs2HistoryList = '/orders/cs2/history';

  /// Endpoint untuk memajukan status pesanan (misalnya, Mulai Packing, Dikirim) (PUT).
  ///
  /// @param orderId ID pesanan yang akan diupdate.
  static String updateStatus(String orderId) => '/orders/$orderId/update-status';

  // Pembeli Action

  /// Endpoint untuk konfirmasi bahwa pembeli telah menerima pesanan (PUT).
  ///
  /// @param orderId ID pesanan yang akan diselesaikan.
  static String completeByBuyer(String orderId) => '/orders/$orderId/complete-by-buyer';
}