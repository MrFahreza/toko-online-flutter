import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../constants/app_colors.dart';
import '../../../viewmodels/pembeli/cart_viewmodel.dart';
import '../../../utils/formatters.dart';
import '../../../models/cart/cart_model.dart';
import '../../widgets/cart_skeleton.dart';

/// Tampilan utama Keranjang Belanja (Cart View) untuk Pembeli.
///
/// Kelas ini menampilkan daftar item di keranjang, total harga, dan mengelola
/// interaksi seperti mengubah kuantitas atau menghapus item.
class CartView extends StackedView<CartViewModel> {
  const CartView({super.key});

  @override
  Widget builder(BuildContext context, CartViewModel model, Widget? child) {
    return Scaffold(
      backgroundColor: AppColors.white, // Latar belakang lebih bersih
      appBar: AppBar(
        title: Text(
          'Keranjang',
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
      body: model.isBusy
          ? const CartSkeleton() // Tampilkan skeleton saat loading
          : model.isEmpty
          ? _buildEmptyState() // Tampilkan state kosong
          : RefreshIndicator(
        onRefresh: model.refresh, // Panggil refresh data
        color: AppColors.primary,
        child: ListView.separated(
          // Padding bawah untuk bottom bar checkout
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 120.h),
          itemCount: model.data!.items!.length,
          separatorBuilder: (ctx, index) => SizedBox(height: 16.h),
          itemBuilder: (context, index) {
            final item = model.data!.items![index];
            return _buildModernCartItem(item, model);
          },
        ),
      ),
      // Tampilkan bottom sheet hanya jika tidak kosong dan tidak loading
      bottomSheet: !model.isEmpty && !model.isBusy ? _buildBottomBar(model) : null,
    );
  }

  /// Membangun kartu item keranjang dengan desain modern.
  ///
  /// @param item Objek [CartItemModel] yang akan ditampilkan.
  /// @param model [CartViewModel] untuk memanggil fungsi aksi.
  Widget _buildModernCartItem(CartItemModel item, CartViewModel model) {
    final isBusy = model.isItemBusy(item.id!);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(12.w),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: CachedNetworkImage(
              imageUrl: item.product?.thumbnailUrl ?? '',
              width: 70.w,
              height: 70.w,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) =>
                  Container(color: Colors.grey[200], width: 70.w, height: 70.w),
            ),
          ),
          SizedBox(width: 12.w),

          // Details Produk
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product?.name ?? 'Produk',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                Text(
                  AppFormatters.formatCurrency(item.product?.price),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),

          // Quantity Control
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Tombol Hapus Item
              GestureDetector(
                onTap: () => model.removeItem(item.id!),
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.grey[400],
                  size: 20.sp,
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: isBusy
                    ? Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: SizedBox(
                    width: 15.w,
                    height: 15.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                )
                    : Row(
                  children: [
                    // Tombol Kurangi Kuantitas
                    _qtyBtn(
                      Icons.remove,
                          () => model.updateQuantity(
                        item.id!,
                        item.quantity!,
                        -1,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        '${item.quantity}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    // Tombol Tambah Kuantitas
                    _qtyBtn(
                      Icons.add,
                          () => model.updateQuantity(
                        item.id!,
                        item.quantity!,
                        1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Widget helper untuk tombol kontrol kuantitas (+ atau -).
  ///
  /// @param icon Icon yang ditampilkan.
  /// @param onTap Fungsi yang dipanggil saat tombol diklik.
  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Icon(icon, size: 16.sp, color: Colors.grey[700]),
      ),
    );
  }

  /// Membangun bar di bagian bawah layar untuk menampilkan total harga dan tombol Checkout.
  ///
  /// @param model [CartViewModel] untuk mendapatkan data total dan fungsi navigasi.
  Widget _buildBottomBar(CartViewModel model) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Total Harga
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Harga',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
                Text(
                  AppFormatters.formatCurrency(model.totalPrice),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            // Tombol Checkout
            SizedBox(
              width: 140.w,
              height: 45.h,
              child: ElevatedButton(
                onPressed: model.navigateToCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  // Menampilkan jumlah item yang akan dibeli pada tombol
                  'Beli (${model.cartItemCount})',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Membangun tampilan saat keranjang belanja kosong.
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80.sp,
            color: Colors.grey[300],
          ),
          SizedBox(height: 10.h),
          Text(
            'Keranjang Kosong',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  CartViewModel viewModelBuilder(BuildContext context) => CartViewModel();

  @override
  void onViewModelReady(CartViewModel model) => model.initialise();
}