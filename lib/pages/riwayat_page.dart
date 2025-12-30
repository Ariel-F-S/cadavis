import 'dart:io';
import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/jenazah.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  late Future<List<Jenazah>> _riwayatFuture;

  @override
  void initState() {
    super.initState();
    _riwayatFuture = _loadRiwayat();
  }

  Future<List<Jenazah>> _loadRiwayat() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'jenazah',
      orderBy: 'tanggal_penemuan DESC',
    );
    return result.map((e) => Jenazah.fromMap(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Data Jenazah'),
        backgroundColor: const Color(0xFF7C4DFF),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Jenazah>>(
        future: _riwayatFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada data tersimpan',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final data = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // GAMBAR
                    if (item.gambarPath != null &&
                        File(item.gambarPath!).existsSync())
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Image.file(
                          File(item.gambarPath!),
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _rowInfo(
                            Icons.calendar_today,
                            '${item.tanggalPenemuan} • ${item.waktuPenemuan}',
                          ),
                          const SizedBox(height: 6),
                          _rowInfo(
                            Icons.location_on,
                            item.lokasiPenemuan,
                          ),
                          const Divider(height: 24),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _jumlahChip(
                                Icons.male,
                                'Laki-laki',
                                item.jumlahLaki,
                                Colors.blue,
                              ),
                              _jumlahChip(
                                Icons.female,
                                'Perempuan',
                                item.jumlahPerempuan,
                                Colors.pink,
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),
                          Text(
                            'Petugas: ${item.namaPetugas}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _rowInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF7C4DFF)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _jumlahChip(
    IconData icon,
    String label,
    int jumlah,
    Color color,
  ) {
    return Chip(
      avatar: Icon(icon, color: color, size: 18),
      label: Text('$label: $jumlah'),
      backgroundColor: color.withOpacity(0.1),
    );
  }
}
