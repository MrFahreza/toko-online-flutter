import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../constants/app_colors.dart';
import '../../../viewmodels/pembeli/product_list_viewmodel.dart';
import 'product_list_content.dart';

/// Tampilan Beranda untuk pengguna Pembeli.
///
/// View ini adalah salah satu tab di dalam [PembeliDashboardView].
/// View ini menggunakan [ProductListViewModel] untuk memuat dan mengelola
/// daftar produk, pencarian, dan *load more*.
class PembeliHomeView extends StackedView<ProductListViewModel> {
  const PembeliHomeView({super.key});

  @override
  Widget builder(
      BuildContext context,
      ProductListViewModel model,
      Widget? child,
      ) {
    return Scaffold(
      backgroundColor: AppColors.white,
      // APP BAR yang dikomentari dihilangkan, namun perlu dicatat bahwa
      // fungsionalitas badge (model.cartItemCount) kini ditangani di
      // PembeliDashboardView yang meng-host view ini.

      // Menggunakan Widget [ProductListContent] yang terpisah
      // untuk menampung logika tampilan daftar produk, pencarian, dan scroll.
      body: ProductListContent(),
    );
  }

  @override
  ProductListViewModel viewModelBuilder(BuildContext context) =>
      ProductListViewModel();

  @override
  void onViewModelReady(ProductListViewModel model) => model.initialise();
}