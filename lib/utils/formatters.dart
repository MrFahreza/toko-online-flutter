import 'package:intl/intl.dart';

/// Kelas utilitas yang menyediakan fungsi-fungsi statis untuk memformat data,
/// khususnya untuk pemformatan mata uang.
class AppFormatters {
  /// Instance statis dan final dari [NumberFormat] untuk pemformatan mata uang Rupiah.
  ///
  /// Dibuat sekali (*singleton*) untuk efisiensi. Menggunakan locale 'id_ID',
  /// simbol 'Rp ', dan tanpa digit desimal.
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID', // Locale Indonesia
    symbol: 'Rp ',    // Simbol Rupiah
    decimalDigits: 0, // Tidak ada desimal
  );

  /// Merupakan method untuk memformat angka ([num], double/int) menjadi string mata uang Rupiah.
  ///
  /// Jika nilai ([value]) adalah `null`, akan mengembalikan "Rp 0".
  ///
  /// Contoh: 100000 -> "Rp 100.000"
  ///
  /// @param value Angka yang akan diformat. Dapat berupa `int` atau `double`.
  /// @returns [String] Nilai mata uang Rupiah yang telah diformat.
  static String formatCurrency(num? value) {
    if (value == null) {
      return 'Rp 0';
    }
    return _currencyFormatter.format(value);
  }
}