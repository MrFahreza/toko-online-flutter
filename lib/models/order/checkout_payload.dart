/// Payload yang dikirim ke backend saat melakukan checkout.
///
/// Model ini menampung informasi pengiriman yang diisi oleh pembeli
/// sebelum pesanan dibuat.
class CheckoutPayload {
  /// Nama lengkap penerima.
  final String buyerName;

  /// Nomor telepon/WhatsApp penerima.
  final String buyerPhone;

  /// Alamat lengkap pengiriman.
  final String buyerAddress;

  /// Constructor untuk membuat instance [CheckoutPayload].
  CheckoutPayload({
    required this.buyerName,
    required this.buyerPhone,
    required this.buyerAddress,
  });

  /// Mengkonversi objek menjadi Map untuk body request HTTP (JSON).
  ///
  /// @returns [Map<String, dynamic>] data payload dalam format JSON.
  Map<String, dynamic> toJson() => {
    "buyerName": buyerName,
    "buyerPhone": buyerPhone,
    "buyerAddress": buyerAddress,
  };
}