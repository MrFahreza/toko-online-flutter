import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Widget *Skeleton* (Shimmer Loading) untuk tampilan Daftar Produk (Grid).
///
/// Widget ini menampilkan placeholder berbentuk kartu produk dalam GridView
/// untuk memberikan umpan balik visual saat data produk sedang dimuat.
class ProductSkeleton extends StatelessWidget {
  const ProductSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      // Warna dasar dan highlight untuk efek shimmer
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        shrinkWrap: true,
        // Nonaktifkan scroll karena biasanya dibungkus oleh SingleChildScrollView
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6, // Tampilkan 6 item dummy untuk mengisi grid
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemBuilder: (context, index) {
          // Kartu dummy (placeholder)
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Placeholder Area Gambar Produk
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.vertical(top: Radius.circular(15.r)),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Placeholder Teks Nama Produk
                      Container(height: 14.h, width: 100.w, color: Colors.white),
                      SizedBox(height: 4.h),
                      // Placeholder Teks Harga
                      Container(height: 14.h, width: 60.w, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}