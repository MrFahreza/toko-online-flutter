import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../constants/app_strings.dart';
import '../../../constants/app_colors.dart';
import '../../../viewmodels/auth/auth_viewmodel.dart';

/// Tampilan utama untuk Autentikasi (Login).
///
/// View ini menampilkan UI untuk pemilihan peran pengguna (Buyer, CS1, CS2)
/// dan tombol login. Informasi login (email/password) otomatis terisi
/// berdasarkan peran yang dipilih.
class AuthView extends StackedView<AuthViewModel> {
  const AuthView({super.key});

  @override
  Widget builder(BuildContext context, AuthViewModel model, Widget? child) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Agar background tidak terdorong keyboard
      body: Stack(
        children: [
          // 1. Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF70BF4B), // Primary Green
                  Color(0xFF4A90E2), // Blue Accent
                ],
              ),
            ),
          ),

          // 2. Logo & Branding (Top Area)
          Positioned(
            top: 0.15.sh, // 15% dari atas
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Kotak Logo
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.white.withOpacity(0.5), width: 2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Image.asset(
                    'assets/icon/icon.png',
                    width: 50.w,
                    height: 50.w,
                  ),
                ),
                SizedBox(height: 16.h),
                // Judul Aplikasi
                Text(
                  'TOKO ONLINE',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // 3. White Card Overlay (Bottom Area: Form Login)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 0.60.sh, // Mengambil 55% tinggi layar
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(30.r)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 20,
                      offset: const Offset(0, -5)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Role Selection Header
                  Text('Pilih Akses',
                      style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500)),
                  SizedBox(height: 10.h),

                  // Role Selector Row
                  Row(
                    children: [
                      Expanded(
                          child: _buildRoleSelector(model, AppStrings.roleBuyer,
                              Icons.shopping_bag_outlined)),
                      SizedBox(width: 10.w),
                      Expanded(
                          child: _buildRoleSelector(
                              model, AppStrings.roleCS1, Icons.support_agent)),
                      SizedBox(width: 10.w),
                      Expanded(
                          child: _buildRoleSelector(model, AppStrings.roleCS2,
                              Icons.inventory_2_outlined)),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  // Fake Input Fields (Auto-filled by role)
                  _buildFakeTextField(
                      'Email', model.emailController, Icons.email_outlined),
                  SizedBox(height: 16.h),
                  _buildFakeTextField('Password', model.passwordController,
                      Icons.lock_outline,
                      isPassword: true),

                  SizedBox(height: 10.h),
                  // Link Lupa Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('Lupa Password?',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                  ),

                  const Spacer(),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: model.isBusy ? null : model.login, // Panggil fungsi login
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary, // Tombol Hijau/Cyan
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: model.isBusy
                          ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                          : Text('Login',
                          style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget helper untuk membangun kotak seleksi peran pengguna.
  ///
  /// @param model [AuthViewModel] untuk mengakses status dan fungsi `selectRole`.
  /// @param role String peran yang direpresentasikan (misalnya, 'Pembeli').
  /// @param icon [IconData] ikon yang terkait dengan peran tersebut.
  Widget _buildRoleSelector(
      AuthViewModel model, String role, IconData icon) {
    final bool isSelected = model.selectedRole == role;
    return GestureDetector(
      onTap: () => model.selectRole(role),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 80.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 1.5,
              ),
              // Tambahkan shadow jika terpilih
              boxShadow: isSelected
                  ? [
                BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4))
              ]
                  : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ikon Peran
                Icon(
                  icon,
                  color: isSelected ? AppColors.primary : Colors.grey,
                  size: 28.sp,
                ),
                SizedBox(height: 6.h),
                // Teks Peran
                Text(
                  // Ganti ' Layer ' menjadi baris baru agar rapi
                  role.replaceAll(' Layer ', '\n'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppColors.primary : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          // Ikon Centang Biru (Checkmark) di sudut jika terpilih
          if (isSelected)
            Positioned(
              top: -5,
              right: -5,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, size: 12.sp, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  /// Widget helper untuk membangun input teks *read-only* (simulasi field terisi otomatis).
  ///
  /// @param label Label input teks.
  /// @param controller [TextEditingController] yang mengontrol nilai teks.
  /// @param icon [IconData] ikon yang ditampilkan.
  /// @param isPassword Jika `true`, teks akan disamarkan.
  Widget _buildFakeTextField(
      String label, TextEditingController controller, IconData icon,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      readOnly: true, // Tidak perlu ketik manual
      obscureText: isPassword,
      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 12.sp, color: Colors.grey),
        // Suffix Icon (Simulasi status terisi/valid)
        suffixIcon: Icon(
            isPassword ? Icons.visibility_off : Icons.check_circle,
            size: 18.sp,
            color: Colors.green),
        filled: true,
        fillColor: const Color(0xFFF7F9FC),
        contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  AuthViewModel viewModelBuilder(BuildContext context) => AuthViewModel();
}