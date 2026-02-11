import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../db/database_helper.dart';
import '../models/korban_hilang.dart';

class KorbanHilangInputPage extends StatefulWidget {
  const KorbanHilangInputPage({super.key});

  @override
  State<KorbanHilangInputPage> createState() => _KorbanHilangInputPageState();
}

class _KorbanHilangInputPageState extends State<KorbanHilangInputPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _jenisKelaminController = TextEditingController();
  final _tanggalController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _ciriFisikController = TextEditingController();
  final _alamatController = TextEditingController();
  final _statusController = TextEditingController();
  final _kondisiController = TextEditingController();

  String _fotoPath = '';

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _fotoPath = picked.path;
      });
    }
  }

  Future<void> _saveData() async {
    if (_formKey.currentState!.validate()) {
      final korban = KorbanHilang(
        nama: _namaController.text,
        jenisKelamin: _jenisKelaminController.text,
        tanggalHilang: _tanggalController.text,
        lokasi: _lokasiController.text,
        status: _statusController.text,
        kondisi: _kondisiController.text,
        ciriFisik: _ciriFisikController.text,
        alamatRumah: _alamatController.text,
        fotoPath: _fotoPath,
      );

      await DatabaseHelper.instance.insertKorbanHilang(korban);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✓ Data korban hilang berhasil disimpan')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Data Korban Hilang'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama'),
                validator: (val) => val!.isEmpty ? 'Nama wajib diisi' : null,
              ),
              TextFormField(
                controller: _jenisKelaminController,
                decoration: const InputDecoration(labelText: 'Jenis Kelamin'),
              ),
              TextFormField(
                controller: _tanggalController,
                decoration: const InputDecoration(labelText: 'Tanggal Hilang'),
              ),
              TextFormField(
                controller: _lokasiController,
                decoration: const InputDecoration(labelText: 'Lokasi'),
              ),
              TextFormField(
                controller: _ciriFisikController,
                decoration: const InputDecoration(labelText: 'Ciri Fisik'),
              ),
              TextFormField(
                controller: _alamatController,
                decoration: const InputDecoration(labelText: 'Alamat Rumah'),
              ),
              TextFormField(
                controller: _statusController,
                decoration: const InputDecoration(labelText: 'Status'),
              ),
              TextFormField(
                controller: _kondisiController,
                decoration: const InputDecoration(labelText: 'Kondisi'),
              ),
              const SizedBox(height: 16),
              _fotoPath.isEmpty
                  ? ElevatedButton.icon(
                      icon: const Icon(Icons.photo),
                      label: const Text('Pilih Foto'),
                      onPressed: _pickImage,
                    )
                  : Image.file(File(_fotoPath), height: 150),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Simpan Data'),
                onPressed: _saveData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}