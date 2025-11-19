import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../constants/app_colors.dart';
import '../../../viewmodels/auth/home_viewmodel.dart'; // Kita gunakan HomeViewModel utk logout

/// Tampilan Profil sederhana untuk pengguna Pembeli.
///
/// View ini menampilkan informasi dasar pengguna dan menyediakan tombol untuk *logout*.
/// View ini menggunakan [HomeViewModel] untuk memicu fungsi *logout*.
class ProfileView extends ViewModelWidget<HomeViewModel> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, HomeViewModel model) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Avatar Profil
          CircleAvatar(
            radius: 40.r,
            backgroundColor: AppColors.primary.withOpacity(0.2),
            child: Icon(Icons.shopping_bag_outlined,
                size: 40.sp, color: AppColors.primary),
          ),
          SizedBox(height: 10.h),
          // Nama Peran/Pengguna
          Text(
            'Pembeli',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          // Email (Placeholder)
          Text(
            'pembeli@example.com',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey),
          ),
          SizedBox(height: 30.h),

          // Tombol Logout
          SizedBox(
            width: 200.w,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text('Keluar Aplikasi',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              onPressed: model.initiateLogout, // Panggil fungsi logout dari ViewModel
            ),
          ),
        ],
      ),
    );
  }
}