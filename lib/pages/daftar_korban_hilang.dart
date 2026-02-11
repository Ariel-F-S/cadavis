import 'dart:io';
import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/korban_hilang.dart';

class DaftarKorbanHilangPage extends StatefulWidget {
  const DaftarKorbanHilangPage({super.key});

  @override
  State<DaftarKorbanHilangPage> createState() => _DaftarKorbanHilangPageState();
}

class _DaftarKorbanHilangPageState extends State<DaftarKorbanHilangPage> {
  List<KorbanHilang> _korbanList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await DatabaseHelper.instance.getAllKorbanHilang();
    setState(() {
      _korbanList = data;
    });
  }

  Future<void> _deleteKorban(int id) async {
    await DatabaseHelper.instance.deleteKorbanHilang(id);
    _loadData();
  }

  @override
Widget build(BuildContext context) {
  final args = ModalRoute.of(context)!.settings.arguments as Map?;
  final role = args?['role'] ?? 'user';

  final isDark = Theme.of(context).brightness == Brightness.dark;
  final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
  final textColor = isDark ? Colors.white70 : Colors.black87;

  return Scaffold(
    appBar: AppBar(title: const Text('Daftar Korban Hilang')),
    body: _korbanList.isEmpty
        ? Center(
            child: Text(
              'Belum ada data korban hilang',
              style: TextStyle(color: textColor),
            ),
          )
        : ListView.builder(
            itemCount: _korbanList.length,
            itemBuilder: (context, index) {
              final korban = _korbanList[index];
              return Card(
                color: cardColor,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: korban.fotoPath.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(korban.fotoPath),
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(Icons.person,
                          size: 40,
                          color: isDark ? Colors.white70 : Colors.grey[700]),
                  title: Text(
                    korban.nama,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                  subtitle: Text(
                    '${korban.jenisKelamin} • Hilang: ${korban.tanggalHilang}\n'
                    'Lokasi: ${korban.lokasi}\n'
                    'Ciri fisik: ${korban.ciriFisik}\n'
                    'Alamat: ${korban.alamatRumah}\n'
                    'Status: ${korban.status}'
                    '${korban.status == "Sudah ditemukan" ? "\nKondisi: ${korban.kondisi}" : ""}',
                    style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
                  ),
                  isThreeLine: true,
                  trailing: role == 'admin'
                      ? IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            // buka halaman edit ciri fisik
                            Navigator.pushNamed(
                              context,
                              '/edit-korban',
                              arguments: korban,
                            );
                          },
                        )
                      : null, // user tidak bisa edit
                ),
              );
            },
          ),
    floatingActionButton: role == 'admin'
        ? FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/korban-hilang');
            },
            child: const Icon(Icons.add),
          )
        : null, // user tidak bisa tambah data
  );
  }
}