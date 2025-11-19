import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';

import '../../../viewmodels/pembeli/product_list_viewmodel.dart';
import '../../../constants/app_colors.dart';
import '../../../utils/formatters.dart';
import 'package:toko_online_flutter/models/product/product_model.dart';
import '../../widgets/product_skeleton.dart';

/// Konten utama untuk menampilkan daftar produk di tab Beranda Pembeli.
///
/// Kelas ini merupakan [ViewModelWidget] yang bertanggung jawab membangun UI
/// berdasarkan data dari [ProductListViewModel], termasuk GridView produk,
/// *search box*, dan logika *load more*.
class ProductListContent extends ViewModelWidget<ProductListViewModel> {
  const ProductListContent({super.key});

  @override
  Widget build(BuildContext context, ProductListViewModel model) {
    return RefreshIndicator(
      onRefresh: model.refresh, // Panggil refresh data
      color: AppColors.primary,
      child: SingleChildScrollView(
        controller: model.scrollController, // Controller untuk deteksi *load more*
        // Selalu bisa discroll agar RefreshIndicator bekerja, bahkan saat konten sedikit
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          color: AppColors.white,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),
              _buildModernHeader(model), // Header dengan Search Box
              SizedBox(height: 16.h),

              // Section Title
              Text(
                'Rekomendasi Untukmu',
                style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87),
              ),

              // Logika Tampilan: Loading / Error / Data
              if (model.isBusy && model.products.isEmpty)
                const ProductSkeleton()
              else if (model.hasError && model.products.isEmpty)
                Container(
                    height: 200.h,
                    alignment: Alignment.center,
                    child: Text('Gagal memuat data',
                        style: TextStyle(color: Colors.grey[600])))
              else
                GridView.builder(
                  shrinkWrap: true,
                  // Penting: Nonaktifkan scroll di GridView karena sudah ada SingleChildScrollView di luar
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: model.products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.68, // Rasio untuk kartu produk
                  ),
                  itemBuilder: (context, index) {
                    final product = model.products[index];
                    return _buildTokopediaStyleCard(context, product, model);
                  },
                ),

              // Tampilkan indicator saat memuat halaman berikutnya
              if (model.isBusy && model.products.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: const Center(
                      child: CircularProgressIndicator(color: AppColors.primary)),
                ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  /// Membangun Header utama dengan *Search Box* dan sambutan.
  ///
  /// @param model [ProductListViewModel] untuk mengakses controller pencarian dan fungsi *onChanged*.
  Widget _buildModernHeader(ProductListViewModel model) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 20.h),
      decoration: BoxDecoration(
        // Gradient background
        gradient: const LinearGradient(
          colors: [Color(0xFF70BF4B), Color(0xFF9FD966)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Halo, Pembeli!',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12.sp)),
                  Text('Mau cari apa hari ini?',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const Icon(Icons.notifications_outlined, color: Colors.white),
            ],
          ),
          SizedBox(height: 15.h),
          // Search Input
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: TextField(
              controller: model.searchController,
              onChanged: model.onSearchChanged,
              style: TextStyle(fontSize: 14.sp),
              decoration: const InputDecoration(
                icon: Icon(Icons.search, color: Colors.grey),
                hintText: 'Cari di Toko Online...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun kartu produk dengan gaya menyerupai e-commerce populer (Tokopedia Style Card).
  ///
  /// @param context [BuildContext].
  /// @param product Data produk ([ProductModel]) yang akan ditampilkan.
  /// @param model [ProductListViewModel] untuk memicu navigasi ke detail produk.
  Widget _buildTokopediaStyleCard(
      BuildContext context, ProductModel product, ProductListViewModel model) {
    return GestureDetector(
      onTap: () => model.navigateToProductDetail(product), // Navigasi ke detail
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          // Shadow sangat halus
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2))
          ],
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Image
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10.r)),
                child: CachedNetworkImage(
                  imageUrl: product.thumbnailUrl ?? '',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                      color: Colors.grey[100],
                      child: const Icon(Icons.broken_image, color: Colors.grey)),
                ),
              ),
            ),
            // 2. Content
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? '-',
                    style:
                    TextStyle(fontSize: 12.sp, color: Colors.black87, height: 1.2),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    AppFormatters.formatCurrency(product.price),
                    style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  SizedBox(height: 4.h),
                  // Dummy Rating / Stock Info
                  Row(
                    children: [
                      Icon(Icons.star, size: 12.sp, color: Colors.amber),
                      SizedBox(width: 2.w),
                      Text('4.8',
                          style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
                      SizedBox(width: 4.w),
                      Text('| Stock ${product.stock ?? 0}',
                          style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  // Button "Detail"
                  SizedBox(
                    width: double.infinity,
                    height: 30.h,
                    child: OutlinedButton(
                      onPressed: () => model.navigateToProductDetail(product),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.r)),
                      ),
                      child: Text('Detail',
                          style:
                          TextStyle(fontSize: 12.sp, color: AppColors.primary)),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}