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
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Korban Hilang')),
      body: _korbanList.isEmpty
          ? const Center(child: Text('Belum ada data korban hilang'))
          : ListView.builder(
              itemCount: _korbanList.length,
              itemBuilder: (context, index) {
                final korban = _korbanList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(korban.nama),
                    subtitle: Text(
                      '${korban.jenisKelamin} • Hilang: ${korban.tanggalHilang}\n'
                      'Lokasi: ${korban.lokasi}\nStatus: ${korban.status}',
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteKorban(korban.id!),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: arahkan ke halaman tambah korban hilang
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
