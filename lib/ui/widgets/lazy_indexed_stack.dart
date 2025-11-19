import 'package:flutter/material.dart';

/// Sebuah wrapper custom di atas [IndexedStack] yang mengimplementasikan
/// *Lazy Loading* atau *Keep Alive*.
///
/// Konten ([children]) hanya akan di-build dan di-render saat indeksnya
/// pertama kali diakses. Setelah di-build, konten akan dipertahankan
/// (di-*keep alive*) di memori.
class LazyIndexedStack extends StatefulWidget {
  /// Indeks widget anak yang saat ini harus terlihat.
  final int index;

  /// Daftar widget anak yang merupakan konten dari setiap tab/halaman.
  final List<Widget> children;

  const LazyIndexedStack({
    super.key,
    required this.index,
    required this.children,
  });

  @override
  State<LazyIndexedStack> createState() => _LazyIndexedStackState();
}

class _LazyIndexedStackState extends State<LazyIndexedStack> {
  // Daftar boolean yang melacak widget anak mana yang sudah pernah diaktifkan/di-build.
  late List<bool> _activated;

  @override
  void initState() {
    super.initState();
    _activated = List<bool>.filled(widget.children.length, false);
    // Aktifkan tab awal (index yang diberikan) saat pertama kali inisialisasi
    _activated[widget.index] = true;
  }

  @override
  void didUpdateWidget(LazyIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Cek apakah indeks berubah
    if (oldWidget.index != widget.index) {
      // Aktifkan tab yang baru dibuka (indeks yang baru)
      _activated[widget.index] = true;
    }
  }

  /// Membangun [IndexedStack] dengan mengganti widget anak yang belum diaktifkan
  /// dengan [SizedBox.shrink()] (widget kosong).
  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.index,
      children: List.generate(widget.children.length, (i) {
        if (_activated[i]) {
          // Jika sudah pernah diaktifkan, kembalikan widget aslinya
          return widget.children[i];
        }
        // Jika belum pernah diaktifkan, kembalikan widget kosong (SizedBox.shrink)
        // untuk menghemat sumber daya.
        return const SizedBox.shrink();
      }),
    );
  }
}