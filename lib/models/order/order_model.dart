import 'dart:convert';
import '../product/product_model.dart';

/// Fungsi *helper* untuk mengonversi string JSON (list) menjadi daftar objek [OrderModel].
///
/// @param str String JSON array dari API response.
/// @returns [List<OrderModel>] daftar pesanan.
List<OrderModel> orderListFromJson(String str) =>
    List<OrderModel>.from(json.decode(str).map((x) => OrderModel.fromJson(x)));

/// Model utama untuk Pesanan.
///
/// Model ini menampung detail transaksi, status, informasi pengiriman, dan daftar item.
class OrderModel {
  /// ID unik pesanan.
  String? id;

  /// Tanggal dan waktu pesanan dibuat.
  DateTime? createdAt;

  /// Tanggal dan waktu pesanan terakhir diperbarui.
  DateTime? updatedAt;

  /// Status pesanan (misalnya, 'MENUNGGU_VERIFIKASI_CS1').
  String? status;

  /// Nama penerima/pembeli.
  String? buyerName;

  /// Nomor telepon penerima/pembeli.
  String? buyerPhone;

  /// Alamat pengiriman lengkap.
  String? buyerAddress;

  /// Total harga akhir dari pesanan.
  double? totalPrice;

  /// URL bukti pembayaran yang diunggah oleh pembeli (jika ada).
  String? paymentProofUrl;

  /// ID pengguna yang membuat pesanan.
  String? buyerId;

  /// Daftar item produk di dalam pesanan.
  List<OrderItemModel>? items;

  OrderModel({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.status,
    this.buyerName,
    this.buyerPhone,
    this.buyerAddress,
    this.totalPrice,
    this.paymentProofUrl,
    this.buyerId,
    this.items,
  });

  /// Factory constructor untuk membuat [OrderModel] dari Map JSON.
  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id: json["id"],
    // Parsing string tanggal ke objek DateTime
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null
        ? null
        : DateTime.parse(json["updatedAt"]),
    status: json["status"],
    buyerName: json["buyerName"],
    buyerPhone: json["buyerPhone"],
    buyerAddress: json["buyerAddress"],
    // Konversi ke double dari tipe numerik manapun
    totalPrice: (json["totalPrice"] as num?)?.toDouble(),
    paymentProofUrl: json["paymentProofUrl"],
    buyerId: json["buyerId"],
    // Parsing daftar item pesanan (fallback ke list kosong jika null)
    items: json["items"] == null
        ? []
        : List<OrderItemModel>.from(
        json["items"].map((x) => OrderItemModel.fromJson(x))),
  );
}

/// Model untuk item individual di dalam pesanan ([OrderModel]).
class OrderItemModel {
  /// ID unik item pesanan (bukan ID produk).
  String? id;

  /// Jumlah (kuantitas) produk ini.
  int? quantity;

  /// Harga snapshot (harga yang disimpan saat checkout) dari produk ini.
  double? price;

  /// Objek detail produk yang dibeli.
  ProductModel? product;

  OrderItemModel({this.id, this.quantity, this.price, this.product});

  /// Factory constructor untuk membuat [OrderItemModel] dari Map JSON.
  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
    id: json["id"],
    quantity: json["quantity"],
    // Konversi harga snapshot ke double
    price: (json["price"] as num?)?.toDouble(),
    // Parsing objek produk yang tersemat
    product: json["product"] == null
        ? null
        : ProductModel.fromJson(json["product"]),
  );
}