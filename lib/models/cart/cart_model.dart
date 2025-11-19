import 'dart:convert';
import '../product/product_model.dart';

/// Fungsi *helper* untuk mengonversi string JSON menjadi objek [CartModel].
///
/// @param str String JSON dari API response.
/// @returns [CartModel] objek keranjang belanja.
CartModel cartModelFromJson(String str) => CartModel.fromJson(json.decode(str));

/// Model utama untuk Keranjang Belanja.
class CartModel {
  /// ID unik keranjang belanja.
  String? id;

  /// ID pengguna yang memiliki keranjang ini.
  String? userId;

  /// Daftar item produk yang ada di dalam keranjang.
  List<CartItemModel>? items;

  /// Total harga dari semua item di keranjang.
  double? totalPrice;

  CartModel({this.id, this.userId, this.items, this.totalPrice});

  /// Factory constructor untuk membuat [CartModel] dari Map JSON.
  factory CartModel.fromJson(Map<String, dynamic> json) => CartModel(
    id: json["id"],
    userId: json["userId"],
    // Parsing daftar item (fallback ke list kosong jika null)
    items: json["items"] == null
        ? []
        : List<CartItemModel>.from(
        json["items"].map((x) => CartItemModel.fromJson(x))),
    // Pastikan konversi ke double dari tipe numerik manapun (int/double)
    totalPrice: (json["totalPrice"] as num?)?.toDouble(),
  );
}

/// Model untuk item individual di dalam keranjang ([CartModel]).
class CartItemModel {
  /// ID unik item keranjang (bukan ID produk).
  String? id;

  /// Jumlah (kuantitas) produk ini di dalam keranjang.
  int? quantity;

  /// Objek detail produk yang dibeli.
  ProductModel? product;

  CartItemModel({this.id, this.quantity, this.product});

  /// Factory constructor untuk membuat [CartItemModel] dari Map JSON.
  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
    id: json["id"],
    quantity: json["quantity"],
    // Parsing objek produk yang tersemat
    product: json["product"] == null
        ? null
        : ProductModel.fromJson(json["product"]),
  );
}