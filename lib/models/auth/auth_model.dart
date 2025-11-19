import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

/// Fungsi *helper* untuk mengonversi string JSON menjadi objek [AuthModel].
AuthModel authModelFromJson(String str) => AuthModel.fromJson(json.decode(str));

/// Fungsi *helper* untuk mengonversi objek [AuthModel] menjadi string JSON.
String authModelToJson(AuthModel data) => json.encode(data.toJson());

//-------------------------------------------------------------------------
//                         ENUM & PARSING HELPER
//-------------------------------------------------------------------------

/// Enumerasi peran pengguna sesuai backend (Prisma Schema).
///
/// [UNKNOWN] digunakan sebagai nilai *default* atau *fallback* jika peran tidak dikenali.
enum UserRole {
  PEMBELI,
  CS1,
  CS2,
  @JsonValue('UNKNOWN')
  UNKNOWN,
}

/// Helper untuk konversi string role dari API ke [UserRole] enum yang aman.
///
/// Fungsi ini membersihkan dan membandingkan string role yang masuk secara *case-insensitive*.
///
/// @param role String role dari payload API (misal: "CS1", "PEMBELI").
/// @returns [UserRole] enum (akan mengembalikan [UserRole.UNKNOWN] jika tidak cocok atau `null`).
UserRole roleFromString(String? role) {
  if (role == null) return UserRole.UNKNOWN;

  final cleanRole = role.trim().toUpperCase();

  // Mencoba mencari nama enum yang cocok
  return UserRole.values.firstWhere(
        (e) => e.name.toUpperCase() == cleanRole,
    orElse: () => UserRole.UNKNOWN, // Mengembalikan UNKNOWN jika tidak ditemukan
  );
}

//-------------------------------------------------------------------------
//                         DATA MODELS
//-------------------------------------------------------------------------

/// Model data yang membungkus response login (Model Response API Global).
class AuthModel {
  /// Kode status HTTP dari response (misal: 200).
  int? statusCode;

  /// Pesan yang menyertai response (misal: "Login successful").
  String? message;

  /// Payload data utama yang berisi token dan objek pengguna.
  Data? data;

  AuthModel({this.statusCode, this.message, this.data});

  /// Factory constructor untuk membuat [AuthModel] dari Map JSON.
  factory AuthModel.fromJson(Map<String, dynamic> json) => AuthModel(
    statusCode: json["statusCode"],
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  /// Mengonversi [AuthModel] menjadi Map JSON.
  Map<String, dynamic> toJson() => {
    "statusCode": statusCode,
    "message": message,
    "data": data?.toJson(),
  };
}

/// Model data yang membungkus token akses dan objek pengguna.
class Data {
  /// JSON Web Token (JWT) yang digunakan untuk otorisasi API selanjutnya.
  String? accessToken;

  /// Objek detail pengguna yang sedang login.
  User? user;

  Data({this.accessToken, this.user});

  /// Factory constructor untuk membuat [Data] dari Map JSON.
  factory Data.fromJson(Map<String, dynamic> json) => Data(
    accessToken: json["access_token"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
  );

  /// Mengonversi [Data] menjadi Map JSON.
  Map<String, dynamic> toJson() => {
    "access_token": accessToken,
    "user": user?.toJson(),
  };
}

/// Model data untuk detail User yang sedang login.
class User {
  String? id;
  String? email;
  String? name;

  /// String asli peran dari API (misalnya "CS1").
  String? roleString;

  /// Nilai peran yang sudah diparsing menjadi enum [UserRole] yang aman.
  UserRole role;

  User({this.id, this.email, this.name, required this.role, this.roleString});

  /// Factory constructor untuk membuat [User] dari Map JSON.
  factory User.fromJson(Map<String, dynamic> json) {
    final roleStr = json["role"] as String?;
    return User(
      id: json["id"],
      email: json["email"],
      name: json["name"],
      roleString: roleStr,
      // Panggil helper parsing yang aman
      role: roleFromString(roleStr),
    );
  }

  /// Mengonversi [User] menjadi Map JSON.
  ///
  /// Saat dikonversi ke JSON, hanya string peran ([roleString]) yang dikembalikan.
  Map<String, dynamic> toJson() => {
    "id": id,
    "email": email,
    "name": name,
    "role": roleString,
  };
}