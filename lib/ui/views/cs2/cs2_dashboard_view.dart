import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../constants/app_colors.dart';
import '../../../viewmodels/cs2/cs2_dashboard_viewmodel.dart';
import '../../../models/order/order_model.dart';
import '../../widgets/order_search_box.dart';

/// Tampilan utama Dashboard untuk Customer Service Layer 2 (CS2).
///
/// Kelas ini adalah [StackedView] yang mengelola 3 tab utama: Tugas (packing/kirim),
/// Riwayat Pengiriman, dan Profil. CS2 fokus pada proses logistik setelah pembayaran diverifikasi.
class Cs2DashboardView extends StackedView<Cs2DashboardViewModel> {
  const Cs2DashboardView({super.key});

  @override
  void onViewModelReady(Cs2DashboardViewModel model) => model.initialise();

  @override
  Widget builder(
      BuildContext context,
      Cs2DashboardViewModel model,
      Widget? child,
      ) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Background Abu Modern
      body: SafeArea(
        child: IndexedStack(
          index: model.selectedIndex,
          children: [
            _buildTasksTab(context, model), // Tab 0: Tugas (Proses aktif)
            _buildHistoryTab(model), // Tab 1: Riwayat (Sudah dikirim)
            _buildProfileTab(model), // Tab 2: Profil
          ],
        ),
      ),
      bottomNavigationBar: Container(
        // Tambahkan shadow pada BottomNavigationBar
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: model.selectedIndex,
          onTap: model.setIndex, // Memanggil logika pergantian tab di ViewModel
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2),
              label: 'Tugas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping_outlined),
              activeIcon: Icon(Icons.local_shipping),
              label: 'Dikirim',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  /// Membangun konten untuk tab **Tugas Logistik** (Index 0).
  ///
  /// Tab ini menampilkan pesanan yang statusnya 'MENUNGGU_DIPROSES_CS2' dan 'SEDANG_DIPROSES'.
  Widget _buildTasksTab(BuildContext context, Cs2DashboardViewModel model) {
    return Column(
      children: [
        _buildHeader(
          'Gudang & Logistik',
          'Kelola packing dan pengiriman barang',
        ),

        // Widget untuk input pencarian pesanan
        OrderSearchBox(onChanged: (val) => model.searchOrder(val)),

        Expanded(
          child: model.isBusy && model.activeOrders.isEmpty
              ? _buildSkeletonList() // Tampilkan shimmer saat memuat data awal
              : RefreshIndicator(
            onRefresh: model.refreshData,
            color: AppColors.primary,
            child: model.activeOrders.isEmpty
                ? _buildEmptyState(
              'Kerja Bagus!',
              'Tidak ada barang perlu diproses.',
            )
                : ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: model.activeOrders.length,
              separatorBuilder: (ctx, i) => SizedBox(height: 16.h),
              // isActionable=true agar tombol Aksi (Proses/Kirim) muncul
              itemBuilder: (ctx, i) => _buildModernLogisticsCard(
                context,
                model.activeOrders[i],
                model,
                true,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Membangun konten untuk tab **Riwayat Pengiriman** (Index 1).
  ///
  /// Tab ini menampilkan pesanan yang sudah berstatus 'DIKIRIM' atau 'SELESAI'.
  Widget _buildHistoryTab(Cs2DashboardViewModel model) {
    return Column(
      children: [
        _buildHeader(
          'Riwayat Pengiriman',
          'Barang yang sudah diserahkan ke kurir',
        ),

        // Widget untuk input pencarian pesanan
        OrderSearchBox(onChanged: (val) => model.searchOrder(val)),

        Expanded(
          child: model.isBusy && model.historyOrders.isEmpty
              ? _buildSkeletonList() // Tampilkan shimmer saat memuat data awal
              : RefreshIndicator(
            onRefresh: model.fetchHistoryOrders,
            color: AppColors.primary,
            child: model.historyOrders.isEmpty
                ? _buildEmptyState(
              'Kosong',
              'Belum ada riwayat pengiriman.',
            )
                : ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: model.historyOrders.length,
              separatorBuilder: (ctx, i) => SizedBox(height: 12.h),
              // isActionable=false, tidak ada tombol Aksi
              itemBuilder: (ctx, i) => _buildModernLogisticsCard(
                null,
                model.historyOrders[i],
                model,
                false,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Membangun konten untuk tab **Profil** (Index 2).
  ///
  /// Menampilkan informasi dasar CS2 dan tombol *logout*.
  Widget _buildProfileTab(Cs2DashboardViewModel model) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50.r,
            backgroundColor: Colors.orange.withOpacity(0.1),
            child: Icon(
              Icons.local_shipping,
              size: 50.sp,
              color: Colors.orange,
            ),
          ),
          SizedBox(height: 15.h),
          Text(
            'CS Layer 2',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          Text(
            'cs2@example.com',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey),
          ),
          SizedBox(height: 30.h),
          SizedBox(
            width: 200.w,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                'Keluar',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: model.logout, // Panggil fungsi logout dari ViewModel
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS HELPER ---

  /// Widget helper untuk membangun header statis di bagian atas setiap tab.
  ///
  /// @param title Judul utama.
  /// @param subtitle Deskripsi singkat.
  Widget _buildHeader(String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 15.h),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// Widget helper untuk menampilkan kondisi kosong (data tidak ditemukan).
  ///
  /// @param title Judul kondisi kosong.
  /// @param sub Subtitle/deskripsi.
  Widget _buildEmptyState(String title, String sub) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 60.sp, color: Colors.grey),
          SizedBox(height: 10.h),
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
          ),
          Text(sub, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  /// Widget helper untuk menampilkan efek *skeleton* (shimmer) saat data sedang dimuat.
  Widget _buildSkeletonList() {
    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: 4,
      separatorBuilder: (ctx, i) => SizedBox(height: 16.h),
      itemBuilder: (ctx, i) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 160.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
      ),
    );
  }

  /// Widget helper untuk membangun kartu pesanan gaya logistik/gudang.
  ///
  /// @param context Konteks (opsional, hanya jika [isActionable] true).
  /// @param order Data pesanan yang akan ditampilkan.
  /// @param model [Cs2DashboardViewModel] untuk memanggil fungsi aksi.
  /// @param isActionable Jika `true`, tombol aksi untuk memajukan status akan ditampilkan.
  Widget _buildModernLogisticsCard(
      BuildContext? context,
      OrderModel order,
      Cs2DashboardViewModel model,
      bool isActionable,
      ) {
    final isBusy = model.isOrderBusy(order.id!);

    // Logika penentuan Warna, Icon, dan Teks Tombol berdasarkan Status
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.info;
    String btnText = 'Proses';
    IconData btnIcon = Icons.arrow_forward;

    if (order.status == 'MENUNGGU_DIPROSES_CS2') {
      statusColor = Colors.purple;
      statusIcon = Icons.inventory; // Gudang
      btnText = 'Mulai Packing';
      btnIcon = Icons.inventory_2;
    } else if (order.status == 'SEDANG_DIPROSES') {
      statusColor = Colors.teal;
      statusIcon = Icons.access_time_filled; // Jam/Proses
      btnText = 'Kirim Barang';
      btnIcon = Icons.local_shipping;
    } else if (order.status == 'DIKIRIM') {
      statusColor = Colors.indigo;
      statusIcon = Icons.local_shipping;
    } else if (order.status == 'SELESAI') {
      statusColor = AppColors.primary;
      statusIcon = Icons.done_all;
    }

    return GestureDetector(
      onTap: () => model.navigateToDetail(order), // Navigasi ke detail
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // 1. Header Status Berwarna
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(16.r)),
              ),
              child: Row(
                children: [
                  Icon(statusIcon, size: 18.sp, color: statusColor),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      order.status?.replaceAll('_', ' ') ?? '-',
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                  Text(
                    '#${order.id?.substring(0, 8).toUpperCase()}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                      fontFamily: 'Monospace',
                    ),
                  ),
                ],
              ),
            ),

            // 2. Konten Detail
            Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Penerima',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              order.buyerName ?? '-',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 12.sp,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    order.buyerAddress ?? '-',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10.w),
                      // Badge Item Count
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${order.items?.length ?? 0}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'Item',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 3. Action Button (Hanya jika Task)
            if (isActionable && context != null)
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.w),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    // Tampilkan loading indicator atau icon tombol
                    icon: isBusy
                        ? SizedBox(
                      width: 16,
                      height: 16,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : Icon(btnIcon, color: Colors.white, size: 18),
                    label: Text(
                      isBusy ? 'Memproses...' : btnText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: statusColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      elevation: 0,
                    ),
                    onPressed: isBusy
                        ? null
                        : () => model.advanceOrderStatus(context, order),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Cs2DashboardViewModel viewModelBuilder(BuildContext context) =>
      Cs2DashboardViewModel();
}