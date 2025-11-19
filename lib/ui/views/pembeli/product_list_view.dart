import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../constants/app_colors.dart';
import '../../../utils/formatters.dart';
import '../../../viewmodels/pembeli/product_list_viewmodel.dart';
import 'package:toko_online_flutter/models/product/product_model.dart';

/// Tampilan Daftar Produk (Product List View) yang menampilkan produk dalam GridView.
///
/// View ini mengelola logika *loading*, *error state*, dan *load more* (pagination)
/// menggunakan [ProductListViewModel].
class ProductListView extends StackedView<ProductListViewModel> {
  const ProductListView({super.key});

  @override
  Widget builder(
      BuildContext context,
      ProductListViewModel model,
      Widget? child,
      ) {
    // Tampilkan indikator loading fullscreen jika data awal sedang dimuat
    if (model.isBusy && model.products.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    // Tampilkan pesan error jika terjadi kesalahan dan tidak ada data yang dimuat
    if (model.hasError && model.products.isEmpty) {
      // Menggunakan modelError yang sudah di-dispose di ViewModel sebelumnya,
      // asumsikan properti ini sudah direkayasa untuk keamanan:
      return Center(child: Text('Error: Gagal memuat data.'));
    }

    // Tampilan utama
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: RefreshIndicator(
          onRefresh: model.refresh, // Hubungkan ke fungsi refresh
          color: AppColors.primary,
          child: SingleChildScrollView(
            controller: model.scrollController, // Controller untuk deteksi load more
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            physics: const AlwaysScrollableScrollPhysics(), // Memungkinkan pull-to-refresh
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello Pembeli!',
                  style: TextStyle(fontSize: 16.sp, color: AppColors.black),
                ),
                Text(
                  'Temukan produk terbaik Anda',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 2.h),

                // Placeholder Search Bar
                _buildSearchBar(),

                SizedBox(height: 3.h),

                // Judul "Popular Items"
                Text(
                  'Popular Items',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(height: 1.5.h),

                // Grid Daftar Produk
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(), // Nonaktifkan scroll di GridView
                  itemCount: model.products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.7,
                  ),
                  itemBuilder: (context, index) {
                    final product = model.products[index];
                    return _buildProductCard(context, product, model);
                  },
                ),

                // Tampilkan loading spinner di bawah jika sedang load more
                if (model.isBusy && model.products.isNotEmpty)
                  _buildLoadingMoreIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Widget helper untuk membangun tampilan *placeholder* Search Bar.
  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppColors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.grey),
          SizedBox(width: 2.w),
          Text('Search...', style: TextStyle(color: AppColors.grey)),
        ],
      ),
    );
  }

  /// Widget helper untuk membangun kartu produk individual dalam GridView.
  ///
  /// @param context [BuildContext].
  /// @param product Data produk ([ProductModel]) yang akan ditampilkan.
  /// @param model [ProductListViewModel] untuk memicu navigasi.
  Widget _buildProductCard(
      BuildContext context,
      ProductModel product,
      ProductListViewModel model,
      ) {
    return GestureDetector(
      onTap: () => model.navigateToProductDetail(product), // Navigasi ke detail
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: [
            BoxShadow(color: AppColors.black.withOpacity(0.05), blurRadius: 5),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Produk
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: product.thumbnailUrl != null
                    ? CachedNetworkImage(
                  imageUrl: product.thumbnailUrl!,
                  fit: BoxFit.cover,
                  // Tampilkan placeholder saat loading
                  placeholder: (context, url) => Container(
                    color: AppColors.grey.withOpacity(0.1),
                    child:
                    const Center(child: CupertinoActivityIndicator()),
                  ),
                  // Tampilkan icon error jika gagal load
                  errorWidget: (context, url, error) =>
                  const Icon(Icons.error),
                )
                    : Container(color: AppColors.grey.withOpacity(0.3)), // Placeholder
              ),
            ),

            SizedBox(height: 1.h),

            // Nama Produk
            Text(
              product.name ?? 'Nama Produk',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: 0.5.h),

            // Harga
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppFormatters.formatCurrency(product.price),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
                // (Bagian Tombol Add to Cart dihapus sesuai kode asli)
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Widget helper untuk menampilkan indikator loading saat memuat halaman berikutnya.
  Widget _buildLoadingMoreIndicator() {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }

  @override
  ProductListViewModel viewModelBuilder(BuildContext context) =>
      ProductListViewModel();

  /// Panggil initialise saat ViewModel siap untuk memuat data awal.
  @override
  void onViewModelReady(ProductListViewModel model) {
    model.initialise();
  }
}