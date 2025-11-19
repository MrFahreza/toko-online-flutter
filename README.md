## 📱 Mobile Client - Toko Online Sederhana (Flutter)

Ini adalah aplikasi klien seluler (mobile client) yang dibangun menggunakan **Flutter** sebagai bagian dari "Test Project: Mobile App Toko Online Sederhana". Aplikasi ini berinteraksi dengan **Backend NestJS** untuk mengelola seluruh siklus transaksi multi peran (Pembeli, CS1, CS2) dengan fokus pada **User Experience (UX) yang modern** dan **keamanan data**.


## 🚀 Fitur Utama

### Fungsional (Sesuai Spesifikasi)
- **Multi-Role Routing:** Navigasi dashboard yang dinamis berdasarkan peran pengguna yang login (Pembeli, CS1, CS2).
- **Alur Pembeli Lengkap:** Browsing produk, penambahan keranjang, Checkout, Upload Bukti Pembayaran, hingga Konfirmasi Pesanan Diterima.
- **Alur CS Layer 1 (Verifikasi):** Melihat daftar pesanan menunggu bukti bayar, Aksi Setuju (mengurangi stok & meneruskan ke CS2) atau Tolak (membatalkan pesanan).
- **Alur CS Layer 2 (Logistik):** Memajukan status pesanan dari Menunggu Proses → Sedang Dikemas → Dikirim.
- **Order History:** Riwayat transaksi yang terperinci di setiap peran.

### Fitur Tambahan & Hardening (Production Grade UX/Security)
- **Real Time Status Synchronization (WebSockets):** Status order dan notifikasi tugas baru (CS1/CS2) diperbarui secara instan tanpa perlu *pull to refresh*.
- **Reactive State Management:** Penggunaan **Reactive ViewModels** di seluruh aplikasi untuk *state* yang terjamin konsisten dan *up to date* (misalnya, badge keranjang).
- **Optimistic Cart Update:** Perubahan kuantitas keranjang terjadi secara instan di UI, dengan API request di **debounce** (memperbaiki *glitch* loncatan angka saat *tap* cepat).
- **Themed Custom Snackbar:** Notifikasi menggunakan *style* kustom yang seragam (putih, ikon hijau) alih-alih *default* OS (memperbaiki UX).
- **UX Consistency:** Penerapan desain *Modern Card UI* yang konsisten di halaman List Produk, Keranjang, Checkout, Detail, dan semua Dashboard CS.
- **Root/Jailbreak Check:** Menggunakan `flutter_jailbreak_detection_plus` untuk memblokir aplikasi di perangkat yang tidak aman.
- **Anti-Screenshot:** Menggunakan `screen_protector` untuk mencegah pengambilan tangkapan layar di seluruh aplikasi (keamanan visual).

---

## 🛠️ Tech Stack & Architecture

| Komponen | Teknologi/Pola | Deskripsi |
| :--- | :--- | :--- |
| **Framework** | **Flutter (Dart 3+)** | Menggunakan fitur Dart modern untuk aplikasi multi-platform. |
| **Architecture** | **MVVM** (Model-View-ViewModel) | Memisahkan tampilan dari logika bisnis, didukung oleh Stacked. |
| **State Management** | Stacked / GetIt | Digunakan untuk navigasi tanpa konteks dan [ReactiveViewModel] untuk *state* *real-time*. |
| **HTTP Client** | Dio | Klien HTTP yang mendukung Interceptor (untuk JWT). |
| **Real-time** | Socket.io-Client | Koneksi ke NestJS Gateway untuk notifikasi instan. |
| **Secure Storage** | `flutter_secure_storage` | Menyimpan JWT token dengan aman di *keychain* / *keystore*. |
| **UI Helpers** | `flutter_screenutil`, `shimmer`, `cached_network_image` | Untuk responsivitas, loading visual, dan caching gambar. |

---

## ⚙️ Instalasi dan Menjalankan

Aplikasi ini memerlukan backend NestJS untuk berjalan. Pastikan backend sudah berjalan di port `3000` dan berada di jaringan lokal (Wi-Fi) yang sama dengan perangkat seluler yang akan digunakan.

### Prasyarat
- Node.js & NestJS Backend (**Sudah terinstall dan berjalan**).
- Flutter SDK (v3.16 atau terbaru).
- Perangkat Android atau iOS yang terhubung.
- IP Lokal Laptop (misalnya `192.168.1.XX`).

### Setup Environment Variables

Buat file bernama **`secrets.json`** di root proyek Flutter dan salin kredensial yang dibutuhkan. **Pastikan** `BASE_URL` disetel ke IP lokal **Laptop/PC** untuk pengujian *real-time* di perangkat seluler fisik.

```json
{
  "SUPABASE_URL": "https://[supabase_project].supabase.co",
  "SUPABASE_ANON_KEY": "...",
  "BASE_URL": "http://[IP_LOKAL]:3000",
  "SOCKET_URL": "http://[IP_LOKAL]:3000"
}
```

### Command Menjalankan Aplikasi
Gunakan perintah flutter run berikut untuk menyuntikkan variabel environment saat runtime:
```
# Ganti [IP_LOKAL] dengan IP aktual (misal: 192.168.1.10)
flutter run --dart-define-from-file=secrets.json --dart-define=BASE_URL=http://[IP_LOKAL]:3000
```

## 🛡️ Keamanan dan Reverse Engineering
Aplikasi ini mengimplementasikan beberapa lapisan pertahanan terhadap reverse engineering dan dynamic analysis:

- Obfuscation (Penyulitan Kode): Kode sumber Dart diacak (mangled) saat build rilis menggunakan `flag --obfuscate`. Ini mengganti nama-nama fungsi, kelas, dan variabel menjadi string acak, sehingga mempersulit pemahaman logika bisnis oleh analis statis.
- Jailbreak/Root Detection: Menggunakan flutter_jailbreak_detection_plus untuk memverifikasi integritas perangkat pada saat startup. Aplikasi akan diblokir jika dijalankan pada perangkat yang di-root atau di-jailbreak. Ini berfungsi sebagai pertahanan terhadap alat dynamic analysis seperti Frida.
- Anti-Screenshot: Layar aplikasi dilindungi menggunakan screen_protector, mencegah tangkapan layar dan perekaman visual yang tidak sah.

## 🧪 Akun Default (Simulasi)
Aplikasi ini menggunakan akun simulasi yang sudah terdaftar di backend (melalui seed data). Penguji dapat memilih peran di halaman login (AuthView).
| Peran | Email | Password |
| :--- | :--- | :--- |
| Pembeli | pembeli@example.com | password123 |
| CS Layer 1 | cs1@example.com | password123 |
| CS Layer 2 | cs2@example.com | password123 |
