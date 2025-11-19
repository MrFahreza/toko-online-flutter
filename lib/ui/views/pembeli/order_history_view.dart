import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../constants/app_colors.dart';
import '../../../utils/formatters.dart';
import '../../../viewmodels/pembeli/order_history_viewmodel.dart';
import '../../../models/order/order_model.dart';
import '../../widgets/order_history_skeleton.dart';
import '../../widgets/order_search_box.dart';

/// Tampilan Riwayat Pesanan (Order History View) untuk Pembeli.
///
/// Kelas ini menampilkan daftar semua transaksi yang pernah dilakukan,
/// mendukung pencarian, *pull-to-refresh*, dan aksi seperti upload bukti pembayaran.
class OrderHistoryView extends StackedView<OrderHistoryViewModel> {
  const OrderHistoryView({super.key});

  @override
  void onViewModelReady(OrderHistoryViewModel model) => model.initialise();

  @override
  Widget builder(
      BuildContext context,
      OrderHistoryViewModel model,
      Widget? child,
      ) {
    return Scaffold(
      backgroundColor: AppColors.white, // Background abu-abu muda
      appBar: AppBar(
        title: Text(
          'Riwayat Pesanan',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // Input Pencarian
          OrderSearchBox(onChanged: (val) => model.searchOrder(val)),
          Expanded(
            child: model.isBusy && model.data.isEmpty
                ? const OrderHistorySkeleton() // Tampilkan skeleton saat loading
                : RefreshIndicator(
              onRefresh: model.onRefresh,
              color: AppColors.primary,
              child: model.data.isEmpty
                  ? _buildEmptyState() // Tampilkan state kosong
                  : ListView.separated(
                padding: EdgeInsets.all(16.w),
                itemCount: model.data.length,
                separatorBuilder: (ctx, i) =>
                    SizedBox(height: 16.h),
                itemBuilder: (ctx, i) {
                  final order = model.data[i];
                  // Kartu riwayat dengan style modern
                  return _buildModernHistoryCard(
                    context,
                    order,
                    model,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget helper untuk menampilkan kondisi saat riwayat pesanan kosong.
  Widget _buildEmptyState() {
    return Center(
      child: Text('Belum ada transaksi', style: TextStyle(color: Colors.grey)),
    );
  }

  /// Widget helper untuk membangun kartu riwayat pesanan dengan detail dan tombol aksi.
  ///
  /// @param context [BuildContext] untuk menampilkan dialog.
  /// @param order Objek [OrderModel] data pesanan.
  /// @param model [OrderHistoryViewModel] untuk memanggil fungsi aksi.
  Widget _buildModernHistoryCard(
      BuildContext context,
      OrderModel order,
      OrderHistoryViewModel model,
      ) {
    Color statusColor;
    // Penentuan warna status
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

    String statusText = order.status ?? '-';

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Warna (ID Pesanan dan Status)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
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
                      statusText.replaceAll('_', ' '), // Teks status yang rapi
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

            // 2. Content (Total Harga & Ringkasan Item)
            Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Belanja',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),
                      Text(
                        AppFormatters.formatCurrency(order.totalPrice),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  // Menampilkan nama produk pertama dan jumlah item lainnya
                  if ((order.items?.length ?? 0) > 0)
                    Text(
                      '${order.items![0].product?.name} ${(order.items!.length > 1 ? "+ ${order.items!.length - 1} lainnya" : "")}',
                      style: TextStyle(fontSize: 12.sp, color: Colors.black54),
                    ),
                ],
              ),
            ),

            // 3. Action Buttons (Khusus Pembeli)
            if (statusText == 'MENUNGGU_UPLOAD_BUKTI')
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.w),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(
                      Icons.upload_file,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Upload Bukti',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      elevation: 0,
                    ),
                    onPressed: () =>
                        _showImageSourceActionSheet(context, model, order.id!),
                  ),
                ),
              ),

            // Tombol Konfirmasi Pesanan Diterima
            if (statusText == 'DIKIRIM')
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.w),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    child: const Text('Pesanan Diterima'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    onPressed: () => model.completeOrder(
                      context,
                      order.id!,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Menampilkan *Action Sheet* (Bottom Modal) untuk memilih sumber gambar
  /// (Galeri atau Kamera) untuk upload bukti pembayaran.
  ///
  /// @param context [BuildContext] untuk menampilkan modal.
  /// @param model [OrderHistoryViewModel] untuk memicu fungsi upload.
  /// @param orderId ID pesanan yang akan diunggah buktinya.
  void _showImageSourceActionSheet(
      BuildContext context,
      OrderHistoryViewModel model,
      String orderId,
      ) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri'),
                onTap: () {
                  Navigator.of(context).pop();
                  // Panggil fungsi upload dengan sumber Galeri
                  model.pickAndUploadImage(orderId, ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Kamera'),
                onTap: () {
                  Navigator.of(context).pop();
                  // Panggil fungsi upload dengan sumber Kamera
                  model.pickAndUploadImage(orderId, ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  OrderHistoryViewModel viewModelBuilder(BuildContext context) =>
      OrderHistoryViewModel();
}