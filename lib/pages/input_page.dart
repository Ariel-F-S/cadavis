import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../db/database_helper.dart';
import '../models/jenazah.dart';

class InputJenazahPage extends StatefulWidget {
  const InputJenazahPage({super.key});

  @override
  State<InputJenazahPage> createState() => _InputJenazahPageState();
}

class _InputJenazahPageState extends State<InputJenazahPage> {
  final _formKey = GlobalKey<FormState>();

  final _namaPetugasController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _jumlahLakiController = TextEditingController();
  final _jumlahPerempuanController = TextEditingController();

  DateTime? _tanggal;
  TimeOfDay? _waktu;
  
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  String _formatTanggal(DateTime date) {
    final y = date.year.toString();
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _formatWaktu(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pilihGambar(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: $e')),
      );
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Sumber Gambar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pilihGambar(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pilihGambar(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _simpanGambar(File imageFile) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = path.join(appDir.path, 'jenazah_images', fileName);

      final folder = Directory(path.join(appDir.path, 'jenazah_images'));
      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }

      final savedImage = await imageFile.copy(savedPath);
      return savedImage.path;
    } catch (e) {
      print('Error menyimpan gambar: $e');
      return null;
    }
  }

  Future<void> _simpanData() async {
    if (!_formKey.currentState!.validate() ||
        _tanggal == null ||
        _waktu == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua data')),
      );
      return;
    }

    String? gambarPath;
    if (_selectedImage != null) {
      gambarPath = await _simpanGambar(_selectedImage!);
    }

    final jenazah = Jenazah(
      namaPetugas: _namaPetugasController.text,
      tanggalPenemuan: _formatTanggal(_tanggal!),
      waktuPenemuan: _formatWaktu(_waktu!),
      jumlahLaki: int.parse(_jumlahLakiController.text),
      jumlahPerempuan: int.parse(_jumlahPerempuanController.text),
      lokasiPenemuan: _lokasiController.text,
      gambarPath: gambarPath,
    );

    await DatabaseHelper.instance.insertJenazah(jenazah);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data berhasil disimpan')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Data Jenazah'),
          backgroundColor: const Color(0xFF7C4DFF),
          foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _namaPetugasController,
                decoration: const InputDecoration(labelText: 'Nama Petugas'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _lokasiController,
                decoration: const InputDecoration(
                    labelText: 'Perkiraan Lokasi Penemuan'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _jumlahLakiController,
                decoration:
                    const InputDecoration(labelText: 'Jumlah Laki-laki'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _jumlahPerempuanController,
                decoration:
                    const InputDecoration(labelText: 'Jumlah Perempuan'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null
 || v.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              ElevatedButton.icon(
                icon: const Icon(Icons.date_range),
                label: Text(
                  _tanggal == null
                      ? 'Pilih Tanggal Penemuan'
                      : 'Tanggal: ${_formatTanggal(_tanggal!)}',
                ),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => _tanggal = picked);
                  }
                },
              ),

              const SizedBox(height: 8),

              ElevatedButton.icon(
                icon: const Icon(Icons.access_time),
                label: Text(
                  _waktu == null
                      ? 'Pilih Waktu Penemuan'
                      : 'Waktu: ${_formatWaktu(_waktu!)}',
                ),
                onPressed: () async {
                  final picked = await showTimePicker(
                      context: context, initialTime: TimeOfDay.now());
                  if (picked != null) {
                    setState(() => _waktu = picked);
                  }
                },
              ),

              const SizedBox(height: 16),

              const Divider(),
              const Text(
                'Foto Jenazah (Opsional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              if (_selectedImage != null)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _selectedImage!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedImage = null;
                          });
                        },
                      ),
                    ),
                  ],
                )
              else
                OutlinedButton.icon(
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Tambah Foto Jenazah'),
                  onPressed: _showImageSourceDialog,
                ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _simpanData,
                child: const Text('SIMPAN DATA'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _namaPetugasController.dispose();
    _lokasiController.dispose();
    _jumlahLakiController.dispose();
    _jumlahPerempuanController.dispose();
    super.dispose();
  }
}