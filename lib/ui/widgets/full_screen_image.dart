import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Widget yang menampilkan gambar dari URL dalam mode layar penuh (full screen).
///
/// Widget ini memungkinkan pengguna untuk melakukan *zoom* dan *pan* pada gambar
/// yang dimuat menggunakan [InteractiveViewer].
class FullScreenImageView extends StatelessWidget {
  /// URL publik dari gambar yang akan ditampilkan.
  final String imageUrl;

  const FullScreenImageView({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Background hitam untuk fokus pada gambar
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        // InteractiveViewer memungkinkan zoom in/out dan panning
        child: InteractiveViewer(
          panEnabled: true, // Izinkan panning (geser)
          minScale: 0.5,
          maxScale: 4,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain, // Pastikan gambar terlihat di layar
            // Placeholder saat loading
            placeholder: (context, url) => const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
            // Widget saat terjadi error
            errorWidget: (context, url, error) =>
            const Icon(Icons.error, color: Colors.white),
          ),
        ),
      ),
    );
  }
}