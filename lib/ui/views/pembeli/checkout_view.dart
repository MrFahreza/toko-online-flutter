import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Penting untuk FilteringTextInputFormatter
import 'package:stacked/stacked.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../viewmodels/pembeli/checkout_viewmodel.dart';
import '../../../constants/app_colors.dart';

/// Tampilan proses Checkout (Konfirmasi Pengiriman).
///
/// Kelas ini adalah [StackedView] yang mengumpulkan informasi pengiriman
/// (Nama, HP, Alamat) dari pembeli sebelum membuat pesanan.
class CheckoutView extends StackedView<CheckoutViewModel> {
  const CheckoutView({super.key});

  @override
  Widget builder(
      BuildContext context,
      CheckoutViewModel model,
      Widget? child,
      ) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Background Modern Abu-abu Muda
      appBar: AppBar(
        title: Text('Pengiriman',
            style: TextStyle(
                color: Colors.black,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: model.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Informasi Penerima'),
              SizedBox(height: 12.h),

              // Container Form Putih dengan Shadow Halus untuk Info Penerima
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  children: [
                    // 1. NAMA LENGKAP
                    _buildModernTextField(
                      controller: model.nameController,
                      label: 'Nama Lengkap',
                      hint: 'Contoh: Reza Fahlevi',
                      icon: Icons.person_outline,
                      // Validasi: Hanya Huruf A-z dan Spasi
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Nama wajib diisi';
                        if (value.length < 3) return 'Nama terlalu pendek';
                        return null;
                      },
                    ),

                    SizedBox(height: 20.h),

                    // 2. NOMOR HP (+62 Otomatis)
                    _buildModernTextField(
                      controller: model.phoneController,
                      label: 'Nomor WhatsApp',
                      hint: '8123456789', // Hint tanpa 0
                      icon: Icons.phone_android,
                      prefixText: '+62 ', // Visual +62 mati (tidak bisa dihapus user)
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly, // Hanya angka
                        LengthLimitingTextInputFormatter(13), // Max panjang wajar
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Nomor HP wajib diisi';
                        // Validasi: Tidak boleh diawali 0 (karena sudah ada +62)
                        if (value.startsWith('0'))
                          return 'Format salah. Jangan awali dengan 0.';
                        if (value.length < 9)
                          return 'Nomor HP tidak valid (terlalu pendek)';
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),
              _buildSectionTitle('Alamat Pengiriman'),
              SizedBox(height: 12.h),

              // Container Alamat
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: _buildModernTextField(
                  controller: model.addressController,
                  label: 'Alamat Lengkap',
                  hint: 'Nama jalan, nomor rumah, RT/RW, Kelurahan...',
                  icon: Icons.location_on_outlined,
                  maxLines: 4,
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Alamat wajib diisi'
                      : null,
                ),
              ),

              SizedBox(height: 100.h), // Spacer untuk bottom button
            ],
          ),
        ),
      ),

      /// Bar di bagian bawah layar untuk tombol "Buat Pesanan".
      bottomSheet: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5))
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: model.isBusy ? null : model.processCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                elevation: 0,
              ),
              child: model.isBusy
                  ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5))
                  : Text('Buat Pesanan',
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }

  /// Widget helper untuk menampilkan judul bagian (Section Title).
  ///
  /// @param title Teks judul bagian.
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
          fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }

  /// Widget yang dapat digunakan kembali untuk membuat input teks dengan desain modern.
  ///
  /// @param controller [TextEditingController] yang terkait.
  /// @param label Teks label untuk input.
  /// @param hint Teks petunjuk untuk input.
  /// @param icon Icon di awal input.
  /// @param maxLines Jumlah maksimum baris teks.
  /// @param keyboardType Tipe keyboard.
  /// @param inputFormatters Daftar [TextInputFormatter] untuk membatasi input.
  /// @param validator Fungsi validasi input.
  /// @param prefixText Teks yang muncul sebelum input (misalnya, '+62 ').
  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    String? prefixText,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: TextStyle(
          fontSize: 14.sp, color: Colors.black87, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 22.sp),
        // Bagian Prefix +62
        prefixText: prefixText,
        prefixStyle: TextStyle(
            color: Colors.black87,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold),

        // Styling Border Modern
        filled: true,
        fillColor: const Color(0xFFF9F9F9), // Sedikit abu di dalam input
        contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none, // Hilangkan border default
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
      ),
    );
  }

  @override
  CheckoutViewModel viewModelBuilder(BuildContext context) => CheckoutViewModel();
}