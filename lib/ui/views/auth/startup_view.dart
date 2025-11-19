import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../viewmodels/auth/startup_viewmodel.dart';

/// Tampilan awal (Splash Screen) aplikasi.
///
/// View ini bertanggung jawab menjalankan logika inisialisasi awal (cek keamanan,
/// auto-login, dan navigasi) melalui [StartupViewModel] dan menampilkan branding.
class StartupView extends StackedView<StartupViewModel> {
  const StartupView({super.key});

  /// Dipanggil segera setelah ViewModel siap.
  ///
  /// Memicu logika inisialisasi utama aplikasi.
  @override
  void onViewModelReady(StartupViewModel model) {
    model.runStartupLogic();
  }

  @override
  Widget builder(BuildContext context, StartupViewModel model, Widget? child) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Gradient Background (Hijau-Biru)
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Outline Putih
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(20.r),
                color: Colors.white.withOpacity(0.1),
              ),
              child: Image.asset(
                'assets/icon/icon.png',
                width: 60.w,
                height: 60.w,
              ),
            ),

            SizedBox(height: 20.h),

            // Nama Aplikasi
            Text(
              'TOKO ONLINE',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2.0,
              ),
            ),

            SizedBox(height: 40.h),

            // Status: Tampilkan Error atau Loading Indicator
            if (model.startupError != null)
            // Tampilkan pesan error jika ada masalah keamanan/fatal
              Text(
                model.startupError!,
                style: TextStyle(color: Colors.white70, fontSize: 14.sp),
              )
            else
            // Tampilkan progress indicator saat logika startup berjalan
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
          ],
        ),
      ),
    );
  }

  @override
  StartupViewModel viewModelBuilder(BuildContext context) => StartupViewModel();
}