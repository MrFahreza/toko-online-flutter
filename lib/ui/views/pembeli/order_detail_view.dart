import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../viewmodels/pembeli/order_detail_viewmodel.dart';
import '../../../constants/app_colors.dart';
import '../../../utils/formatters.dart';
import '../../../models/order/order_model.dart';

/// Tampilan Detail Pesanan (Order Detail View) untuk menampilkan semua informasi
/// terkait satu transaksi tertentu.
///
/// Kelas ini menerima objek [OrderModel] dan menggunakan [OrderDetailViewModel]
/// untuk memformat data tampilan.
class OrderDetailView extends StackedView<OrderDetailViewModel> {
  /// Objek pesanan yang detailnya akan ditampilkan.
  final OrderModel order;
  const OrderDetailView({super.key, required this.order});

  @override
  Widget builder(
      BuildContext context,
      OrderDetailViewModel model,
      Widget? child,
      ) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text('Detail Pesanan',
            style: TextStyle(color: AppColors.black, fontSize: 18.sp)),
        backgroundColor: AppColors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppColors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Status & Tanggal
            _buildStatusHeader(model),
            const Divider(height: 30),

            // 2. Info Pengiriman
            Text('Informasi Pengiriman',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 10.h),
            _buildInfoRow(Icons.person_outline, model.order.buyerName),
            _buildInfoRow(Icons.phone_android, model.order.buyerPhone),
            _buildInfoRow(Icons.location_on_outlined, model.order.buyerAddress),
            const Divider(height: 30),

            // 3. Daftar Barang
            Text('Daftar Barang',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 10.h),
            // Menggunakan operator 'spread' untuk menampilkan daftar item
            ...?model.order.items?.map((item) => _buildOrderItem(item)),

            const Divider(height: 30),

            // 4. Ringkasan Pembayaran
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Pembayaran',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                Text(
                  AppFormatters.formatCurrency(model.order.totalPrice),
                  style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary),
                ),
              ],
            ),

            const Divider(height: 30),

            // 5. Bukti Pembayaran (Jika ada)
            if (model.order.paymentProofUrl != null) ...[
              Text('Bukti Pembayaran',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 10.h),
              // Pembungkus gambar yang dapat diklik untuk zoom
              GestureDetector(
                onTap: () => _showImageDialog(context, model.order.paymentProofUrl!),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: CachedNetworkImage(
                    imageUrl: model.order.paymentProofUrl!,
                    width: double.infinity,
                    height: 200.h,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                        height: 200.h,
                        color: Colors.grey[200],
                        child: const Center(child: CupertinoActivityIndicator())),
                    errorWidget: (context, url, error) => Container(
                        height: 200.h,
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image)),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ]
          ],
        ),
      ),
    );
  }

  /// Menampilkan dialog pop-up yang berisi gambar bukti pembayaran dalam ukuran penuh.
  ///
  /// @param context [BuildContext] untuk menampilkan dialog.
  /// @param imageUrl URL publik dari gambar bukti pembayaran.
  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent, // Latar belakang transparan
        insetPadding: const EdgeInsets.all(10), // Sedikit padding dari layar
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            // Gambar Utuh
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain, // Pastikan gambar terlihat utuh
                placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),

            // Tombol Close (X)
            Positioned(
              top: 5,
              right: 5,
              child: GestureDetector(
                onTap: () => Navigator.of(ctx).pop(),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget helper untuk menampilkan header yang berisi ID Pesanan, Tanggal, dan Status.
  ///
  /// @param model [OrderDetailViewModel] untuk mendapatkan data pesanan dan properti helper.
  Widget _buildStatusHeader(OrderDetailViewModel model) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID',
                style: TextStyle(color: AppColors.grey, fontSize: 12.sp)),
            Text('#${model.order.id?.substring(0, 8)}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
            SizedBox(height: 4.h),
            Text(model.formattedDate,
                style: TextStyle(color: AppColors.grey, fontSize: 12.sp)),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: model.statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: model.statusColor.withOpacity(0.5)),
          ),
          child: Text(
            model.statusText,
            style: TextStyle(
                color: model.statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 10.sp),
          ),
        ),
      ],
    );
  }

  /// Widget helper untuk membangun baris informasi teks dengan ikon.
  ///
  /// @param icon Icon yang ditampilkan di awal baris.
  /// @param text Teks yang ditampilkan (misalnya, nama atau alamat).
  Widget _buildInfoRow(IconData icon, String? text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: AppColors.grey),
          SizedBox(width: 10.w),
          Expanded(child: Text(text ?? '-', style: TextStyle(fontSize: 14.sp))),
        ],
      ),
    );
  }

  /// Widget helper untuk menampilkan detail satu item produk dalam pesanan.
  ///
  /// @param item Objek [OrderItemModel] yang akan ditampilkan.
  Widget _buildOrderItem(OrderItemModel item) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: CachedNetworkImage(
              imageUrl: item.product?.thumbnailUrl ?? '',
              width: 50.w,
              height: 50.w,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) =>
                  Container(width: 50.w, height: 50.w, color: Colors.grey),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product?.name ?? '-',
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                Text(
                    '${item.quantity} x ${AppFormatters.formatCurrency(item.price)}',
                    style: TextStyle(color: AppColors.grey, fontSize: 12.sp)),
              ],
            ),
          ),
          // Subtotal item
          Text(
            AppFormatters.formatCurrency(
                (item.price ?? 0) * (item.quantity ?? 0)),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
          ),
        ],
      ),
    );
  }

  @override
  OrderDetailViewModel viewModelBuilder(BuildContext context) =>
      OrderDetailViewModel(order);
}