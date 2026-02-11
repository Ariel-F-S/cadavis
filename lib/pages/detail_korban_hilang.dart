import 'dart:io';
import 'package:flutter/material.dart';
import '../models/korban_hilang.dart';
import '../db/database_helper.dart';

class DetailKorbanPage extends StatelessWidget {
  final KorbanHilang korban;
  final String role; // admin / petugas / user

  const DetailKorbanPage({super.key, required this.korban, required this.role});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Korban Hilang"),
        backgroundColor: const Color(0xFFE91E63),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Foto korban besar
          (korban.fotoPath.isNotEmpty)
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(korban.fotoPath),
                    height: 320,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              : Container(
                  height: 320,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(child: Text("Tidak ada foto")),
                ),
          const SizedBox(height: 20),

          // Informasi korban dalam card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    korban.nama.isNotEmpty ? korban.nama : "Nama tidak tersedia",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 20),
                      const SizedBox(width: 8),
                      Text("Jenis Kelamin: ${korban.jenisKelamin.isNotEmpty ? korban.jenisKelamin : '-'}"),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20),
                      const SizedBox(width: 8),
                      Text("Tanggal Hilang: ${korban.tanggalHilang.isNotEmpty ? korban.tanggalHilang : '-'}"),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 20),
                      const SizedBox(width: 8),
                      Text("Lokasi: ${korban.lokasi.isNotEmpty ? korban.lokasi : '-'}"),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.accessibility_new, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text("Ciri Fisik: ${korban.ciriFisik.isNotEmpty ? korban.ciriFisik : '-'}")),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.home, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text("Alamat: ${korban.alamatRumah.isNotEmpty ? korban.alamatRumah : '-'}")),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 20),
                      const SizedBox(width: 8),
                      Text("Telepon: ${korban.nomorTelepon.isNotEmpty ? korban.nomorTelepon : '-'}"),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Status & Kondisi
          Card(
            color: korban.status == "Sudah ditemukan"
                ? Colors.green.shade100
                : Colors.red.shade100,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Status: ${korban.status.isNotEmpty ? korban.status : '-'}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  if (korban.status == "Sudah ditemukan")
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text("Kondisi: ${korban.kondisi.isNotEmpty ? korban.kondisi : '-'}",
                          style: const TextStyle(fontSize: 16)),
                    ),
                  const SizedBox(height: 16),

                  // Tombol update status (untuk semua role)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text("Update Status"),
                    onPressed: () async {
                      final updated = await Navigator.pushNamed(
                        context,
                        '/edit-korban',
                        arguments: korban,
                      );
                      if (updated != null && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Status korban diperbarui")),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Tambahan dekorasi agar lebih panjang dan estetik
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text("Catatan Tambahan",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    "Data korban ini ditampilkan untuk membantu proses pencarian dan identifikasi. "
                    "Pastikan informasi selalu diperbarui agar tim pencarian dapat bekerja dengan efektif.",
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  Row(
                    children: const [
                      Icon(Icons.info_outline, size: 20, color: Colors.grey),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Jika ada perubahan status atau kondisi korban, segera lakukan update.",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
