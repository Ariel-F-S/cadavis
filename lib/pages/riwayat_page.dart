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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Data Jenazah'),
      ),
      body: FutureBuilder<List<Jenazah>>(
        future: _riwayatFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'Belum ada data tersimpan',
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
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
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(
                        theme.brightness == Brightness.dark ? 0.4 : 0.1,
                      ),
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
                          Divider(
                            height: 24,
                            color: colorScheme.onSurface.withOpacity(0.2),
                          ),

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
                              color: colorScheme.onSurface.withOpacity(0.7),
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

  // ================= ROW INFO =================

  Widget _rowInfo(IconData icon, String text) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  // ================= CHIP =================

  Widget _jumlahChip(
    IconData icon,
    String label,
    int jumlah,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Chip(
      avatar: Icon(icon, color: color, size: 18),
      label: Text(
        '$label: $jumlah',
        style: TextStyle(
          color: theme.brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
      ),
      backgroundColor: color.withOpacity(
        theme.brightness == Brightness.dark ? 0.25 : 0.12,
      ),
    );
  }
}