import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Widget *Skeleton* (Shimmer Loading) untuk tampilan Riwayat Pesanan.
///
/// Widget ini menampilkan placeholder berbentuk kartu untuk menunjukkan
/// bahwa data riwayat pesanan sedang dimuat.
class OrderHistorySkeleton extends StatelessWidget {
  const OrderHistorySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      // Warna dasar dan highlight untuk efek shimmer
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: 3, // Tampilkan 3 kartu dummy
        separatorBuilder: (ctx, i) => SizedBox(height: 16.h),
        itemBuilder: (ctx, i) {
          // Kartu dummy yang akan ber-shimmer
          return Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              // Background harus di set warna untuk mengisi area container
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.white),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Baris Atas (Placeholder ID & Status)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(width: 100.w, height: 14.h, color: Colors.white),
                    // Placeholder Badge Status
                    Container(
                        width: 80.w,
                        height: 24.h,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20))),
                  ],
                ),
                SizedBox(height: 15.h),
                // Placeholder Label 'Total'
                Container(width: 80.w, height: 12.h, color: Colors.white),
                SizedBox(height: 5.h),
                // Placeholder Jumlah Harga
                Container(width: 120.w, height: 18.h, color: Colors.white),
                SizedBox(height: 15.h),
                // Placeholder Tombol Aksi
                Container(
                    width: double.infinity,
                    height: 40.h,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8))),
              ],
            ),
          );
        },
      ),
    );
  }
}