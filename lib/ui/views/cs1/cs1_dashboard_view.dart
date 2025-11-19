import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../../../constants/app_colors.dart';
import '../../../viewmodels/cs1/cs1_dashboard_viewmodel.dart';
import '../../../models/order/order_model.dart';
import '../../../utils/formatters.dart';
import '../../widgets/full_screen_image.dart';
import '../../widgets/order_search_box.dart';

/// Tampilan utama Dashboard untuk Customer Service Layer 1 (CS1).
///
/// Kelas ini adalah [StackedView] yang mengelola 3 tab utama: Verifikasi, Riwayat, dan Profil.
class Cs1DashboardView extends StackedView<Cs1DashboardViewModel> {
  const Cs1DashboardView({super.key});

  @override
  Widget builder(
      BuildContext context,
      Cs1DashboardViewModel model,
      Widget? child,
      ) {
    // Menggunakan IndexedStack untuk mempertahankan status state pada setiap tab
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: IndexedStack(
        index: model.selectedIndex,
        children: [
          _buildVerificationTab(context, model),
          _buildHistoryTab(model),
          _buildProfileTab(model),
        ],
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
              icon: Icon(Icons.fact_check_outlined),
              activeIcon: Icon(Icons.fact_check),
              label: 'Verifikasi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Riwayat',
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

  /// Membangun konten untuk tab **Verifikasi Pembayaran** (Index 0).
  ///
  /// Tab ini menampilkan pesanan yang statusnya 'MENUNGGU_VERIFIKASI_CS1'
  /// dan memungkinkan CS1 untuk menyetujui atau menolak bukti transfer.
  Widget _buildVerificationTab(
      BuildContext context, Cs1DashboardViewModel model) {
    return Column(
      children: [
        _buildHeader('Verifikasi Pembayaran', 'Cek bukti transfer pembeli'),

        // Widget untuk input pencarian pesanan
        OrderSearchBox(onChanged: (val) => model.searchOrder(val)),

        Expanded(
          child: model.isBusy && model.pendingOrders.isEmpty
              ? _buildSkeletonList() // Tampilkan shimmer saat memuat data awal
              : RefreshIndicator(
            onRefresh: model.refreshData, // Panggil refresh data
            color: AppColors.primary,
            child: model.pendingOrders.isEmpty
                ? _buildEmptyState('Semua aman!', 'Tidak ada pesanan menunggu.')
                : ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: model.pendingOrders.length,
              separatorBuilder: (ctx, i) => SizedBox(height: 16.h),
              // isActionable=true agar tombol Aksi (Setujui/Tolak) muncul
              itemBuilder: (ctx, i) => _buildModernOrderCard(
                  context, model.pendingOrders[i], model, true),
            ),
          ),
        ),
      ],
    );
  }

  /// Membangun konten untuk tab **Riwayat Pesanan** (Index 1).
  ///
  /// Tab ini menampilkan semua pesanan yang telah diproses CS1 dan status lainnya.
  Widget _buildHistoryTab(Cs1DashboardViewModel model) {
    return Column(
      children: [
        _buildHeader('Riwayat Pesanan', 'Daftar semua pesanan masuk'),

        // Widget untuk input pencarian pesanan
        OrderSearchBox(onChanged: (val) => model.searchOrder(val)),

        Expanded(
          child: model.isBusy && model.historyOrders.isEmpty
              ? _buildSkeletonList() // Tampilkan shimmer saat memuat data awal
              : RefreshIndicator(
            onRefresh: model.fetchHistoryOrders, // Panggil ambil data riwayat
            color: AppColors.primary,
            child: model.historyOrders.isEmpty
                ? _buildEmptyState('Kosong', 'Belum ada riwayat pesanan.')
                : ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: model.historyOrders.length,
              separatorBuilder: (ctx, i) => SizedBox(height: 12.h),
              // isActionable=false, tidak ada tombol Aksi
              itemBuilder: (ctx, i) => _buildModernOrderCard(
                  null, model.historyOrders[i], model, false),
            ),
          ),
        ),
      ],
    );
  }

  /// Membangun konten untuk tab **Profil** (Index 2).
  ///
  /// Menampilkan informasi dasar CS1 dan tombol *logout*.
  Widget _buildProfileTab(Cs1DashboardViewModel model) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50.r,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Icon(
              Icons.support_agent,
              size: 50.sp,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 15.h),
          Text(
            'CS Layer 1',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          Text(
            'cs1@example.com',
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

  /// Widget helper untuk membangun header statis di bagian atas setiap tab.
  ///
  /// @param title Judul utama (misalnya, 'Verifikasi Pembayaran').
  /// @param subtitle Deskripsi singkat (misalnya, 'Cek bukti transfer pembeli').
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
          Icon(Icons.inbox_outlined, size: 60.sp, color: Colors.grey),
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
      itemCount: 5,
      separatorBuilder: (ctx, i) => SizedBox(height: 16.h),
      itemBuilder: (ctx, i) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 180.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
      ),
    );
  }

  /// Widget helper untuk membangun kartu pesanan dengan desain modern.
  ///
  /// @param context Konteks untuk navigasi ke tampilan gambar layar penuh.
  /// @param order Data pesanan yang akan ditampilkan.
  /// @param model [Cs1DashboardViewModel] untuk memanggil fungsi aksi.
  /// @param isActionable Jika `true`, tombol 'Setujui'/'Tolak' akan ditampilkan.
  Widget _buildModernOrderCard(
      BuildContext? context,
      OrderModel order,
      Cs1DashboardViewModel model,
      bool isActionable,
      ) {
    final isBusy = model.isOrderBusy(order.id!);
    Color statusColor;

    // Menentukan warna berdasarkan status pesanan
    switch (order.status) {
      case 'MENUNGGU_UPLOAD_BUKTI':
        statusColor = Colors.orange;
        break;
      case 'MENUNGGU_VERIFIKASI_CS1':
        statusColor = Colors.blue;
        break;
      case 'MENUNGGU_DIPROSES_CS2':
        statusColor = Colors.purple;
        break;
      case 'SEDANG_DIPROSES':
        statusColor = Colors.teal;
        break;
      case 'DIKIRIM':
        statusColor = Colors.indigo;
        break;
      case 'SELESAI':
        statusColor = AppColors.primary;
        break;
      case 'DIBATALKAN':
        statusColor = Colors.red;
        break;
      default:
        statusColor = AppColors.grey;
    }

    return GestureDetector(
      onTap: () => model.navigateToDetail(order),
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
            // Header Status Pesanan
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(16.r)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '#${order.id?.substring(0, 8).toUpperCase()}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                      fontFamily: 'Monospace',
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      order.status?.replaceAll('_', ' ') ?? '-',
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Area Bukti Pembayaran (dapat diklik untuk zoom)
                  GestureDetector(
                    onTap: (order.paymentProofUrl != null && context != null)
                        ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullScreenImageView(
                          imageUrl: order.paymentProofUrl!,
                        ),
                      ),
                    )
                        : null,
                    child: Container(
                      width: 60.w,
                      height: 60.w,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8.r),
                        image: order.paymentProofUrl != null
                            ? DecorationImage(
                          image: CachedNetworkImageProvider(
                            order.paymentProofUrl!,
                          ),
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                      child: order.paymentProofUrl == null
                          ? const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                      )
                          : const Center(
                        child: Icon(Icons.zoom_in, color: Colors.white70),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Detail Pesanan Singkat
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.buyerName ?? 'Tanpa Nama',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '${order.items?.length ?? 0} Barang',
                          style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          AppFormatters.formatCurrency(order.totalPrice),
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Tombol Aksi (Hanya muncul di tab Verifikasi)
            if (isActionable && context != null)
              Padding(
                padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.w),
                child: Row(
                  children: [
                    // Tombol Tolak
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isBusy
                            ? null
                            : () => model.handleVerification(
                          context,
                          order.id!,
                          false, // Menolak
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.redAccent),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          foregroundColor: Colors.redAccent,
                        ),
                        child: const Text('Tolak'),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    // Tombol Setujui
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isBusy
                            ? null
                            : () => model.handleVerification(
                          context,
                          order.id!,
                          true, // Menyetujui
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          elevation: 0,
                        ),
                        child: isBusy
                            ? SizedBox(
                          // Tampilkan loading indicator jika sedang busy
                          width: 16.w,
                          height: 16.w,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : const Text(
                          'Setujui',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Cs1DashboardViewModel viewModelBuilder(BuildContext context) =>
      Cs1DashboardViewModel();

  @override
  void onViewModelReady(Cs1DashboardViewModel model) => model.initialise();
}