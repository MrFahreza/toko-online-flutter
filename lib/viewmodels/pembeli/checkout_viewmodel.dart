import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:toko_online_flutter/app/locator.dart';
import 'package:toko_online_flutter/services/order_service.dart';
import '../../models/order/checkout_payload.dart';
import '../../constants/route_name.dart';

/// ViewModel untuk manajemen form dan logika Checkout.
///
/// Kelas ini mengelola input dari pengguna (nama, HP, alamat) dan memproses
/// pembuatan pesanan melalui [OrderService].
class CheckoutViewModel extends BaseViewModel {
  final _orderService = locator<OrderService>();
  final _navigationService = locator<NavigationService>();
  final _snackbarService = locator<SnackbarService>();

  /// Controller untuk input nama pembeli.
  final nameController = TextEditingController();

  /// Controller untuk input nomor HP/WhatsApp.
  final phoneController = TextEditingController();

  /// Controller untuk input alamat pengiriman.
  final addressController = TextEditingController();

  /// Kunci form ([GlobalKey]) untuk memicu validasi form di UI.
  final formKey = GlobalKey<FormState>();

  /// Memproses data checkout dan memanggil API pembuatan pesanan.
  ///
  /// Fungsi ini melakukan validasi, memformat nomor telepon, dan mengirim
  /// payload ke [OrderService].
  ///
  /// @returns [Future<void>]
  Future<void> processCheckout() async {
    // Memastikan form lolos validasi
    if (!formKey.currentState!.validate()) return;

    setBusy(true);

    // LOGIKA KHUSUS: Gabungkan +62 dengan input user jika belum ada
    String formattedPhone = phoneController.text;
    if (!formattedPhone.startsWith('+62')) {
      formattedPhone = '+62$formattedPhone';
    }

    // Buat payload dari data form
    final payload = CheckoutPayload(
      buyerName: nameController.text,
      buyerPhone: formattedPhone, // Gunakan nomor yang sudah diformat
      buyerAddress: addressController.text,
    );

    try {
      // Panggil API Checkout
      await _orderService.checkout(payload);

      _snackbarService.showCustomSnackBar(
          message: 'Pesanan berhasil dibuat! Segera lakukan pembayaran.',
          title: 'Sukses',
          duration: const Duration(seconds: 3),
        variant: 'default',);

      // Clear stack dan kembali ke Home (Dashboard)
      await _navigationService.clearStackAndShow(homeViewRoute);
    } catch (e) {
      // Tampilkan pesan error dari Exception
      _snackbarService.showCustomSnackBar(
        message: e.toString().replaceAll("Exception: ", ""),
        title: 'Gagal Checkout',
        duration: const Duration(seconds: 3),
        variant: 'default',
      );
    } finally {
      setBusy(false);
    }
  }

  /// Membersihkan [TextEditingController] saat ViewModel dibuang.
  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }
}