import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../constants/app_colors.dart';

// Import Views
import 'pembeli_home_view.dart';
import 'cart_view.dart';
import 'order_history_view.dart';
import 'profile_view.dart';

// Import ViewModel Baru
import '../../../viewmodels/pembeli/pembeli_dashboard_viewmodel.dart';
import '../../../viewmodels/auth/home_viewmodel.dart';

/// Tampilan Dashboard Utama untuk pengguna dengan peran Pembeli.
///
/// Kelas ini mengelola navigasi antar tab (Home, Keranjang, Riwayat, Profil)
/// dan menampilkan *badge* notifikasi keranjang secara reaktif.
class PembeliDashboardView extends StackedView<PembeliDashboardViewModel> {
  const PembeliDashboardView({super.key});

  @override
  Widget builder(
      BuildContext context,
      PembeliDashboardViewModel model,
      Widget? child,
      ) {
    // Daftar semua halaman yang akan ditampilkan di dalam IndexedStack.
    final List<Widget> pages = [
      const PembeliHomeView(),
      const CartView(),
      const OrderHistoryView(),
      // Menggunakan ViewModelBuilder di sini untuk memastikan ProfileView
      // mendapatkan model yang diperlukan (misalnya HomeViewModel untuk Logout)
      ViewModelBuilder<HomeViewModel>.reactive(
        viewModelBuilder: () => HomeViewModel(),
        builder: (context, model, child) => const ProfileView(),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.white,

      // Body menggunakan IndexedStack agar state tiap tab tetap terjaga (Lazy Loading)
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: IndexedStack(
          index: model.selectedIndex, // Index yang dikontrol oleh ViewModel
          children: pages,
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            // Tambahkan shadow ke atas
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5)),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: model.selectedIndex,
          onTap: model.setIndex, // Hubungkan ke ViewModel untuk ganti index
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          selectedLabelStyle:
          TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
          items: [
            // 1. Beranda
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Beranda',
            ),

            // 2. Keranjang (DENGAN BADGE)
            BottomNavigationBarItem(
              icon: _buildCartIconWithBadge(model, false), // Icon inaktif
              activeIcon: _buildCartIconWithBadge(model, true), // Icon aktif
              label: 'Keranjang',
            ),

            // 3. Riwayat
            const BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Riwayat',
            ),

            // 4. Profil
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  /// Widget helper untuk membuat ikon keranjang yang dilengkapi dengan *badge*
  /// berisi jumlah item ([cartItemCount]).
  ///
  /// @param model [PembeliDashboardViewModel] untuk mendapatkan jumlah item.
  /// @param isActive Status apakah item BNDB sedang aktif dipilih.
  /// @returns [Widget] Ikon keranjang dengan atau tanpa badge.
  Widget _buildCartIconWithBadge(
      PembeliDashboardViewModel model, bool isActive) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          // Memilih ikon keranjang yang terisi atau outline
          isActive ? Icons.shopping_cart : Icons.shopping_cart_outlined,
          size: 24.sp,
        ),

        // Tampilkan badge hanya jika jumlah item di keranjang > 0
        if (model.cartItemCount > 0)
          Positioned(
            right: -4, // Sesuaikan posisi ke kanan atas ikon
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border:
                Border.all(color: Colors.white, width: 1.5), // Border putih
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                '${model.cartItemCount}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  @override
  PembeliDashboardViewModel viewModelBuilder(BuildContext context) =>
      PembeliDashboardViewModel();

  @override
  void onViewModelReady(PembeliDashboardViewModel model) => model.initialise();
}