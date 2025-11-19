import 'dart:convert';

/// Fungsi *helper* untuk mengonversi string JSON menjadi objek [ProductModel] tunggal.
///
/// @param str String JSON dari API response.
/// @returns [ProductModel] objek produk.
ProductModel productModelFromJson(String str) => ProductModel.fromJson(json.decode(str));

/// Fungsi *helper* untuk mengonversi objek [ProductModel] menjadi string JSON.
///
/// @param data Objek [ProductModel].
/// @returns String JSON.
String productModelToJson(ProductModel data) => json.encode(data.toJson());

/// Model untuk list response dari API.
///
/// Model ini digunakan untuk membungkus respons yang berisi daftar produk
/// dengan kode status dan pesan.
class ProductListResponse {
  /// Kode status HTTP dari response (misal: 200).
  int? statusCode;

  /// Pesan yang menyertai response.
  String? message;

  /// Daftar objek produk ([ProductModel]).
  List<ProductModel>? data;

  ProductListResponse({this.statusCode, this.message, this.data});

  /// Factory constructor untuk membuat [ProductListResponse] dari Map JSON.
  factory ProductListResponse.fromJson(Map<String, dynamic> json) => ProductListResponse(
    statusCode: json["statusCode"],
    message: json["message"],
    // Parsing daftar produk (fallback ke null jika data null)
    data: json["data"] == null
        ? null
        : List<ProductModel>.from(
        json["data"].map((x) => ProductModel.fromJson(x))),
  );
}

/// Model data untuk Produk.
class ProductModel {
  /// ID unik produk.
  String? id;

  /// Nama produk.
  String? name;

  /// Harga produk (double).
  double? price;

  /// Jumlah stok yang tersedia.
  int? stock;

  /// URL gambar thumbnail produk.
  String? thumbnailUrl;

  ProductModel({this.id, this.name, this.price, this.stock, this.thumbnailUrl});

  /// Factory constructor untuk membuat [ProductModel] dari Map JSON.
  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: json["id"],
    name: json["name"],
    // Konversi ke double dari tipe numerik manapun (int/double)
    price: (json["price"] as num?)?.toDouble(),
    stock: json["stock"],
    thumbnailUrl: json["thumbnailUrl"],
  );

  /// Mengonversi [ProductModel] menjadi Map JSON.
  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "price": price,
    "stock": stock,
    "thumbnailUrl": thumbnailUrl,
  };
}