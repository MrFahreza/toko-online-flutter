import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Widget *Skeleton* (Shimmer Loading) untuk tampilan Keranjang Belanja.
///
/// Widget ini digunakan untuk memberikan umpan balik visual kepada pengguna
/// bahwa data keranjang sedang dimuat.
class CartSkeleton extends StatelessWidget {
  const CartSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      // Warna dasar dan highlight untuk efek shimmer
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        itemCount: 4, // Tampilkan 4 item dummy
        separatorBuilder: (ctx, index) => SizedBox(height: 15.h),
        itemBuilder: (context, index) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Placeholder Gambar Produk (Kotak)
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              SizedBox(width: 15.w),
              // Placeholder Detail Teks
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Baris Teks 1 (Nama Produk)
                    Container(width: 150.w, height: 14.h, color: Colors.white),
                    SizedBox(height: 8.h),
                    // Baris Teks 2 (Harga Satuan)
                    Container(width: 100.w, height: 14.h, color: Colors.white),
                    SizedBox(height: 15.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Placeholder Harga Total
                        Container(
                            width: 80.w, height: 20.h, color: Colors.white),
                        // Placeholder Tombol Qty
                        Container(
                            width: 60.w, height: 20.h, color: Colors.white),
                      ],
                    )
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}