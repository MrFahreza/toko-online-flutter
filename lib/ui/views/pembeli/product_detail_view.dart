import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../constants/app_colors.dart';
import '../../../models/product/product_model.dart';
import '../../../utils/formatters.dart';
import '../../../viewmodels/pembeli/product_detail_viewmodel.dart';
import '../../widgets/full_screen_image.dart';

/// Tampilan Detail Produk (Product Detail View) untuk menampilkan informasi
/// lengkap satu produk dan memungkinkan pengguna menambahkannya ke keranjang.
class ProductDetailView extends StackedView<ProductDetailViewModel> {
  /// Objek produk yang detailnya akan ditampilkan.
  final ProductModel product;
  const ProductDetailView({super.key, required this.product});

  @override
  Widget builder(
      BuildContext context, ProductDetailViewModel model, Widget? child) {
    return Scaffold(
      backgroundColor: Colors.white,
      // AppBar Transparan/Minimalis
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {}, // Placeholder share
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. GAMBAR PRODUK (Dapat di-Zoom)
                    Center(
                      child: GestureDetector(
                        // Fitur Zoom Image saat gambar diklik
                        onTap: () {
                          if (model.product.thumbnailUrl != null) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => FullScreenImageView(
                                        imageUrl: model.product.thumbnailUrl!)));
                          }
                        },
                        child: Container(
                          height: 250.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Hero(
                            tag: 'product_${model.product.id}',
                            child: model.product.thumbnailUrl != null
                                ? CachedNetworkImage(
                              imageUrl: model.product.thumbnailUrl!,
                              fit: BoxFit.contain,
                              placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) =>
                              const Icon(Icons.broken_image,
                                  size: 50, color: Colors.grey),
                            )
                                : const Icon(Icons.image,
                                size: 80, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // 2. HEADER (Nama & Rating)
                    Text(
                      model.product.name ?? 'Nama Produk',
                      style: TextStyle(
                          fontSize: 22.sp, fontWeight: FontWeight.bold, height: 1.2),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        // Badge Rating
                        Container(
                          padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                              color: Colors.amber[100],
                              borderRadius: BorderRadius.circular(6.r)),
                          child: Row(
                            children: [
                              Icon(Icons.star, size: 14.sp, color: Colors.amber[800]),
                              SizedBox(width: 4.w),
                              Text('4.8',
                                  style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber[900])),
                            ],
                          ),
                        ),
                        SizedBox(width: 10.w),
                        // Status Stok
                        Text('Stock ${model.product.stock ?? 0}',
                            style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    // 3. HARGA
                    Text(
                      AppFormatters.formatCurrency(model.product.price),
                      style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary),
                    ),

                    SizedBox(height: 24.h),
                    const Divider(),
                    SizedBox(height: 16.h),

                    // 4. DESKRIPSI
                    Text('Deskripsi Produk',
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8.h),
                    Text(
                      'Ini adalah produk berkualitas tinggi yang dirancang untuk memenuhi kebutuhan Anda. Dibuat dengan bahan pilihan dan proses yang teliti.',
                      style: TextStyle(
                          fontSize: 14.sp, color: Colors.black54, height: 1.5),
                    ),
                    SizedBox(height: 40.h), // Spacer bawah
                  ],
                ),
              ),
            ),

            // 5. BOTTOM BAR (Quantity & Buy Button)
            _buildModernBottomBar(model),
          ],
        ),
      ),
    );
  }

  /// Membangun bar di bagian bawah layar yang berisi kontrol kuantitas dan tombol "Beli Sekarang".
  ///
  /// @param model [ProductDetailViewModel] untuk memanggil fungsi update kuantitas dan `addToCart`.
  Widget _buildModernBottomBar(ProductDetailViewModel model) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5))
        ],
      ),
      child: Row(
        children: [
          // QUANTITY SELECTOR (Input Manual dengan tombol +/-)
          Container(
            height: 45.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                // Tombol Kurangi (-)
                _iconBtn(Icons.remove, () => model.updateQuantity(-1)),

                // TEXT FIELD QUANTITY
                SizedBox(
                  width: 40.w,
                  child: TextField(
                    controller: model.qtyController,
                    onChanged: model.onQuantityTyped,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style:
                    TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    // Hanya izinkan angka
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),

                // Tombol Tambah (+)
                _iconBtn(Icons.add, () => model.updateQuantity(1)),
              ],
            ),
          ),

          SizedBox(width: 16.w),

          // BUY BUTTON
          Expanded(
            child: SizedBox(
              height: 45.h,
              child: ElevatedButton(
                onPressed: model.isBusy ? null : model.addToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors
                      .secondary, // Warna Orange/Secondary agar mencolok
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                  elevation: 0,
                ),
                child: model.isBusy
                    ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5))
                    : Text(
                  'Beli Sekarang',
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget helper untuk tombol ikon di dalam kontrol kuantitas.
  ///
  /// @param icon Icon yang ditampilkan.
  /// @param onTap Fungsi yang dipanggil saat tombol diklik.
  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 35.w,
        height: double.infinity,
        alignment: Alignment.center,
        child: Icon(icon, size: 18.sp, color: Colors.grey[700]),
      ),
    );
  }

  @override
  ProductDetailViewModel viewModelBuilder(BuildContext context) =>
      ProductDetailViewModel(product);
}