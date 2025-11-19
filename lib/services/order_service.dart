import 'dart:io';

import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toko_online_flutter/app/locator.dart';
import 'package:toko_online_flutter/constants/api_endpoints.dart';
import 'package:toko_online_flutter/services/api_service.dart';
import '../models/order/checkout_payload.dart';
import '../models/order/order_model.dart';

/// Service yang menangani semua alur transaksi dan manajemen pesanan.
///
/// Kelas ini mengelola interaksi dengan API Order (via [ApiService]) dan
/// Supabase Storage untuk upload bukti pembayaran.
class OrderService {
  final _apiService = locator<ApiService>();
  // Supabase client untuk interaksi dengan Storage
  final _supabase = Supabase.instance.client;

  /// Mengirim data checkout ke backend untuk membuat pesanan baru.
  ///
  /// @param payload Objek [CheckoutPayload] yang berisi data pengiriman.
  /// @returns [Future<String>] ID Pesanan (OrderId) jika sukses.
  /// @throws [Exception] jika gagal.
  Future<String> checkout(CheckoutPayload payload) async {
    try {
      final response = await _apiService.httpClient.post(
        ApiEndpoints.checkout,
        data: payload.toJson(),
      );

      if (response.statusCode == 201 && response.data != null) {
        // Backend mengembalikan objek Order. Kita ambil ID-nya.
        final responseData = response.data['data'];
        return responseData['id'];
      }

      throw Exception('Gagal membuat pesanan.');
    } on DioException catch (e) {
      final msg = _apiService.handleError(e);
      throw Exception(msg);
    }
  }

  /// Mendapatkan Riwayat Pesanan Pembeli.
  ///
  /// @returns [Future<List<OrderModel>>] Daftar pesanan.
  /// @throws [Exception] jika gagal.
  Future<List<OrderModel>> getOrderHistory() async {
    try {
      final response =
      await _apiService.httpClient.get(ApiEndpoints.orderHistory);
      if (response.statusCode == 200 && response.data != null) {
        final listData = response.data['data'] as List;
        return listData.map((e) => OrderModel.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }

  /// Upload File bukti pembayaran ke Supabase Storage.
  ///
  /// @param imageFile File gambar lokal.
  /// @returns [Future<String>] URL publik gambar yang sudah diupload.
  /// @throws [Exception] jika gagal.
  Future<String> uploadImageToSupabase(File imageFile) async {
    try {
      final fileName = 'proof_${DateTime.now().millisecondsSinceEpoch}.jpg';
      const bucketName = 'bukti-pembayaran';
      final path = 'public/$fileName';

      // Upload ke bucket 'bukti-pembayaran'
      await _supabase.storage.from(bucketName).upload(
        path,
        imageFile,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      // Dapatkan URL Publik
      final publicUrl =
      _supabase.storage.from(bucketName).getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      throw Exception('Gagal upload gambar ke Supabase: ${e.toString()}');
    }
  }

  /// Mengirim URL Bukti Pembayaran ke NestJS (mengubah status menjadi MENUNGGU_VERIFIKASI_CS1).
  ///
  /// @param orderId ID pesanan yang akan diupdate.
  /// @param proofUrl URL gambar bukti pembayaran.
  /// @returns [Future<void>]
  /// @throws [Exception] jika gagal.
  Future<void> submitPaymentProof(String orderId, String proofUrl) async {
    try {
      await _apiService.httpClient.patch(
        ApiEndpoints.uploadProof(orderId),
        data: {'paymentProofUrl': proofUrl},
      );
    } on DioException catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }

  /// Mendapatkan list pesanan yang menunggu Verifikasi Pembayaran (CS1).
  ///
  /// Status yang dicari: `MENUNGGU_VERIFIKASI_CS1`.
  ///
  /// @returns [Future<List<OrderModel>>] Daftar pesanan.
  /// @throws [Exception] jika gagal.
  Future<List<OrderModel>> getPendingVerificationOrders() async {
    try {
      final response = await _apiService.httpClient
          .get(ApiEndpoints.pendingVerificationList);
      if (response.statusCode == 200 && response.data != null) {
        final listData = response.data['data'] as List;
        return listData.map((e) => OrderModel.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }

  /// Menyetujui pembayaran (Aksi CS1).
  ///
  /// Mengubah status menjadi `MENUNGGU_DIPROSES_CS2`.
  ///
  /// @param orderId ID pesanan.
  /// @returns [Future<void>]
  /// @throws [Exception] jika gagal.
  Future<void> approvePayment(String orderId) async {
    try {
      await _apiService.httpClient.patch(
        ApiEndpoints.approvePayment(orderId),
      );
    } on DioException catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }

  /// Menolak pembayaran (Aksi CS1).
  ///
  /// Mengubah status menjadi `DIBATALKAN`.
  ///
  /// @param orderId ID pesanan.
  /// @returns [Future<void>]
  /// @throws [Exception] jika gagal.
  Future<void> rejectPayment(String orderId) async {
    try {
      await _apiService.httpClient.patch(
        ApiEndpoints.rejectPayment(orderId),
      );
    } on DioException catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }

  /// Menandai pesanan selesai oleh Pembeli.
  ///
  /// Mengubah status menjadi `SELESAI`.
  ///
  /// @param orderId ID pesanan.
  /// @returns [Future<void>]
  /// @throws [Exception] jika gagal.
  Future<void> completeOrder(String orderId) async {
    try {
      await _apiService.httpClient.patch(
        ApiEndpoints.completeByBuyer(orderId),
      );
    } on DioException catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }

  /// Mendapatkan riwayat pesanan yang sudah diverifikasi (History CS1).
  ///
  /// Status yang dicari: selain `MENUNGGU_UPLOAD_BUKTI` atau `MENUNGGU_VERIFIKASI_CS1`.
  ///
  /// @returns [Future<List<OrderModel>>] Daftar pesanan.
  /// @throws [Exception] jika gagal.
  Future<List<OrderModel>> getCs1OrderHistory() async {
    try {
      final response =
      await _apiService.httpClient.get(ApiEndpoints.cs1HistoryList);
      if (response.statusCode == 200 && response.data != null) {
        final listData = response.data['data'] as List;
        return listData.map((e) => OrderModel.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }

  /// Mendapatkan list pesanan yang menunggu diproses gudang (Tasks CS2).
  ///
  /// Status yang dicari: `MENUNGGU_DIPROSES_CS2` atau `SEDANG_DIPROSES`.
  ///
  /// @returns [Future<List<OrderModel>>] Daftar pesanan.
  /// @throws [Exception] jika gagal.
  Future<List<OrderModel>> getPendingProcessingOrders() async {
    try {
      final response =
      await _apiService.httpClient.get(ApiEndpoints.pendingProcessingList);

      if (response.statusCode == 200 && response.data != null) {
        final listData = response.data['data'] as List;
        return listData.map((e) => OrderModel.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }

  /// Mengupdate status pesanan (Aksi CS2).
  ///
  /// Mengubah status dari `MENUNGGU_DIPROSES_CS2` menjadi `SEDANG_DIPROSES`
  /// atau dari `SEDANG_DIPROSES` menjadi `DIKIRIM`.
  ///
  /// @param orderId ID pesanan.
  /// @param newStatus Status baru yang akan di-set.
  /// @returns [Future<void>]
  /// @throws [Exception] jika gagal.
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _apiService.httpClient.patch(
        ApiEndpoints.updateStatus(orderId),
        data: {'status': newStatus}, // Body JSON
      );
    } on DioException catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }

  /// Mendapatkan riwayat pesanan yang sudah dikirim atau selesai (History CS2).
  ///
  /// Status yang dicari: `DIKIRIM` atau `SELESAI`.
  ///
  /// @returns [Future<List<OrderModel>>] Daftar pesanan.
  /// @throws [Exception] jika gagal.
  Future<List<OrderModel>> getCs2OrderHistory() async {
    try {
      final response =
      await _apiService.httpClient.get(ApiEndpoints.cs2HistoryList);
      if (response.statusCode == 200 && response.data != null) {
        final listData = response.data['data'] as List;
        return listData.map((e) => OrderModel.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }
}