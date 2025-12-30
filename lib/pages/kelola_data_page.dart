import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../db/database_helper.dart';
import '../models/jenazah.dart';

class KelolaDataPage extends StatefulWidget {
  const KelolaDataPage({super.key});

  @override
  State<KelolaDataPage> createState() => _KelolaDataPageState();
}

class _KelolaDataPageState extends State<KelolaDataPage> {
  late Future<List<Jenazah>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _dataFuture = DatabaseHelper.instance.getAllJenazah();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Data Jenazah'),
        backgroundColor: const Color(0xFF7C4DFF),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Jenazah>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          if (data.isEmpty) {
            return const Center(child: Text('Belum ada data'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (context, i) {
              final item = data[i];

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    if (item.gambarPath != null &&
                        File(item.gambarPath!).existsSync())
                      ClipRRect(
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(16)),
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
                          Text(
                            item.lokasiPenemuan,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${item.tanggalPenemuan} • ${item.waktuPenemuan}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Petugas: ${item.namaPetugas}'),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    color: Colors.orange,
                                    onPressed: () => _showEditModal(item),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () => _confirmDelete(item),
                                  ),
                                ],
                              ),
                            ],
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

  void _showEditModal(Jenazah data) {
    final lokasiCtrl = TextEditingController(text: data.lokasiPenemuan);
    File? newImage;
    String? removedImagePath = data.gambarPath;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: lokasiCtrl,
              decoration: const InputDecoration(labelText: 'Lokasi'),
            ),
            const SizedBox(height: 12),
            if (removedImagePath != null &&
                File(removedImagePath!).existsSync())
              Image.file(File(removedImagePath!), height: 120),
            TextButton.icon(
              icon: const Icon(Icons.image),
              label: const Text('Ganti Foto'),
              onPressed: () async {
                final picked =
                    await ImagePicker().pickImage(source: ImageSource.gallery);
                if (picked != null) {
                  setState(() {
                    newImage = File(picked.path);
                  });
                }
              },
            ),
            TextButton.icon(
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text('Hapus Foto'),
              onPressed: () {
                setState(() {
                  removedImagePath = null;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Simpan'),
            onPressed: () async {
              final updated = data.copyWith(
                lokasiPenemuan: lokasiCtrl.text,
                gambarPath: newImage?.path ?? removedImagePath,
              );

              await DatabaseHelper.instance.updateJenazah(updated);
              Navigator.pop(context);
              setState(_refresh);
            },
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Jenazah data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data'),
        content: const Text('Data ini akan dihapus permanen.'),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
            onPressed: () async {
              await DatabaseHelper.instance.deleteJenazah(data.id!);
              Navigator.pop(context);
              setState(_refresh);
            },
          ),
        ],
      ),
    );
  }
}
