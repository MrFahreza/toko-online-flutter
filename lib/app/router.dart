import 'package:flutter/material.dart';
import 'package:toko_online_flutter/constants/route_name.dart';
import 'package:toko_online_flutter/ui/views/auth/home_view.dart';
import '../models/order/order_model.dart';
import '../models/product/product_model.dart';
import '../ui/views/auth/auth_view.dart';
import '../ui/views/auth/startup_view.dart';
import '../ui/views/pembeli/cart_view.dart';
import '../ui/views/pembeli/checkout_view.dart';
import '../ui/views/pembeli/order_detail_view.dart';
import '../ui/views/pembeli/order_history_view.dart';
import '../ui/views/pembeli/product_detail_view.dart';
import '../ui/views/pembeli/product_list_view.dart';

/// Handler untuk navigasi bernama (Named Routes).
///
/// Metode ini dipanggil setiap kali [NavigationService] memanggil rute baru.
/// Logika routing menggunakan `switch` untuk menentukan tujuan berdasarkan nama rute.
///
/// @param settings Pengaturan rute, termasuk nama rute dan argumen.
/// @returns Route<dynamic> yang berisi halaman tujuan.
Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case startupViewRoute:
      return _pageRoute(routeName: settings.name, viewToShow: const StartupView());
    case authViewRoute:
      return _pageRoute(routeName: settings.name, viewToShow: const AuthView());
    case homeViewRoute:
      return _pageRoute(routeName: settings.name, viewToShow: const HomeView());
    case productListViewRoute:
      return _pageRoute(routeName: settings.name, viewToShow: const ProductListView());

    case productDetailViewRoute:
    // Ambil argumen dan pastikan tipenya [ProductModel]
      final product = settings.arguments as ProductModel;
      return _pageRoute(
          routeName: settings.name,
          viewToShow: ProductDetailView(product: product));

    case cartViewRoute:
      return _pageRoute(routeName: settings.name, viewToShow: const CartView());

    case checkoutViewRoute:
      return _pageRoute(routeName: settings.name, viewToShow: const CheckoutView());

    case orderHistoryViewRoute:
      return _pageRoute(routeName: settings.name, viewToShow: const OrderHistoryView());

    case orderDetailViewRoute:
    // Ambil argumen dan pastikan tipenya [OrderModel]
      final order = settings.arguments as OrderModel;
      return _pageRoute(
        routeName: settings.name,
        viewToShow: OrderDetailView(order: order),
      );

    default:
    // Jika rute tidak ditemukan
      return MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(
            child: Text('No route defined for ${settings.name}'),
          ),
        ),
      );
  }
}

/// Helper untuk membuat [MaterialPageRoute] dengan menyertakan nama rute.
///
/// Ini memungkinkan [Stacked] melacak rute yang sedang aktif.
///
/// @param routeName Nama rute yang akan diset.
/// @param viewToShow Widget halaman tujuan.
/// @returns PageRoute
PageRoute _pageRoute({required String? routeName, required Widget viewToShow}) {
  return MaterialPageRoute(
      builder: (_) => viewToShow, settings: RouteSettings(name: routeName));
}