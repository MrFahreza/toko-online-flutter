import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../models/auth/auth_model.dart';
import '../../../viewmodels/auth/home_viewmodel.dart';
import '../pembeli/pembeli_dashboard_view.dart';
import '../cs1/cs1_dashboard_view.dart';
import '../cs2/cs2_dashboard_view.dart';

/// Tampilan utama yang bertindak sebagai **Router Akses**.
///
/// Kelas ini bertanggung jawab menentukan tampilan dashboard mana yang harus dimuat
/// berdasarkan peran pengguna ([UserRole]) yang sedang login, yang diambil dari [HomeViewModel].
class HomeView extends StackedView<HomeViewModel> {
  const HomeView({super.key});

  @override
  Widget builder(BuildContext context, HomeViewModel model, Widget? child) {
    // Jika data dari AuthService (status login dan role) belum siap, tampilkan loading.
    if (!model.isReady) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Tentukan Dashboard berdasarkan Peran Pengguna yang Aktif
    switch (model.userRole) {
      case UserRole.PEMBELI:
      // Arahkan ke Dashboard Pembeli
        return const PembeliDashboardView();
      case UserRole.CS1:
      // Arahkan ke Dashboard CS Layer 1
        return const Cs1DashboardView();
      case UserRole.CS2:
      // Arahkan ke Dashboard CS Layer 2
        return const Cs2DashboardView();
      case UserRole.UNKNOWN:
      // Tangani kasus jika role tidak teridentifikasi meskipun sudah login
        return const Scaffold(
          body: Center(child: Text("Akses tidak valid (Role UNKNOWN)")),
        );
      default:
      // Tangani kasus role yang tidak ditangani dalam switch
        return const Scaffold(
          body: Center(child: Text("Role tidak dikenali")),
        );
    }
  }

  @override
  HomeViewModel viewModelBuilder(BuildContext context) => HomeViewModel();
}