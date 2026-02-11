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
          // Foto korban
          korban.fotoPath.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(korban.fotoPath),
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              : Container(
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(child: Text("Tidak ada foto")),
                ),
          const SizedBox(height: 16),

          // Informasi korban
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(korban.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Jenis Kelamin: ${korban.jenisKelamin}"),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text("Tanggal Hilang"),
            subtitle: Text(korban.tanggalHilang),
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text("Lokasi Hilang"),
            subtitle: Text(korban.lokasi),
          ),
          ListTile(
            leading: const Icon(Icons.accessibility_new),
            title: const Text("Ciri Fisik"),
            subtitle: Text(korban.ciriFisik),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Alamat Rumah"),
            subtitle: Text(korban.alamatRumah),
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: const Text("Nomor Telepon"),
            subtitle: Text(korban.nomorTelepon),
          ),
          const SizedBox(height: 16),

          // Status & Kondisi
          Card(
            color: Colors.grey.shade100,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Status Korban: ${korban.status}",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (korban.status == "Sudah ditemukan")
                    Text("Kondisi: ${korban.kondisi}"),
                  const SizedBox(height: 12),

                  // Tombol update status (hanya untuk petugas/admin)
                  if (role == "petugas" || role == "admin")
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
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
