import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path/path.dart' as path;
import '../db/database_helper.dart';
import '../models/jenazah.dart';

class InputJenazahPage extends StatefulWidget {
  const InputJenazahPage({super.key});

  @override
  State<InputJenazahPage> createState() => _InputJenazahPageState();
}


class _InputJenazahPageState extends State<InputJenazahPage> {
  String _kondisiKorban = '';
  final _formKey = GlobalKey<FormState>();

  final _namaPetugasController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _jumlahLakiController = TextEditingController();
  final _jumlahPerempuanController = TextEditingController();

  DateTime? _tanggal;
  TimeOfDay? _waktu;
  
  File? _selectedImageJenazah;
  File? _selectedImageLokasi;
  String? _koordinatGPS;
  bool _isLoadingGPS = false;
  
  // ✅ TAMBAHAN: Status korban
  String? selectedStatus;
  String? selectedKondisi;
  
  
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

  Future<void> _pilihGambar(ImageSource source, bool isLokasiImage) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        if (mounted) {
          setState(() {
            if (isLokasiImage) {
              _selectedImageLokasi = File(pickedFile.path);
            } else {
              _selectedImageJenazah = File(pickedFile.path);
            }
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: $e')),
      );
    }
  }

  void _showImageSourceDialog(bool isLokasiImage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isLokasiImage ? 'Pilih Foto Lokasi' : 'Pilih Foto Jenazah'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pilihGambar(ImageSource.camera, isLokasiImage);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pilihGambar(ImageSource.gallery, isLokasiImage);
              },
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _ambilLokasiGPS() async {
    if (mounted) {
      setState(() {
        _isLoadingGPS = true;
      });
    }

    try {
      // Cek permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Izin lokasi ditolak');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi ditolak permanen. Buka Settings.');
      }

      // Ambil posisi dengan timeout
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('GPS timeout');
        },
      );

      if (mounted) {
        setState(() {
          _koordinatGPS = '${position.latitude}, ${position.longitude}';
          _isLoadingGPS = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Lokasi GPS berhasil didapatkan'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on TimeoutException {
      if (mounted) {
        setState(() {
          _isLoadingGPS = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Timeout: GPS memakan waktu terlalu lama'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingGPS = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal mendapatkan GPS: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _simpanGambar(File imageFile, String prefix) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${prefix}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = path.join(appDir.path, 'jenazah_images', fileName);

      final folder = Directory(path.join(appDir.path, 'jenazah_images'));
      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }

      final savedImage = await imageFile.copy(savedPath);
      return savedImage.path;
    } catch (e) {
      debugPrint('Error menyimpan gambar: $e');
      return null;
    }
  }

  Future<void> _simpanData() async {
    // Validasi form
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua data yang wajib diisi')),
      );
      return;
    }

    // Validasi tanggal dan waktu
    if (_tanggal == null || _waktu == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal dan waktu wajib diisi')),
      );
      return;
    }

    // Validasi status korban
    
      if (_kondisiKorban.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Kondisi korban wajib diisi')),
      );
      return;
    }

    // Validasi foto lokasi (WAJIB)
    if (_selectedImageLokasi == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Foto lokasi wajib diisi!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validasi angka dengan try-catch
    int? jumlahLaki;
    int? jumlahPerempuan;
    
    try {
      jumlahLaki = int.parse(_jumlahLakiController.text);
      jumlahPerempuan = int.parse(_jumlahPerempuanController.text);
      
      if (jumlahLaki < 0 || jumlahPerempuan < 0) {
        throw FormatException('Angka tidak boleh negatif');
      }
      
      if (jumlahLaki == 0 && jumlahPerempuan == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Total jenazah tidak boleh 0'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Format angka tidak valid: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Simpan gambar jenazah (opsional)
    String? gambarJenazahPath;
    if (_selectedImageJenazah != null) {
      gambarJenazahPath = await _simpanGambar(_selectedImageJenazah!, 'jenazah');
      if (gambarJenazahPath == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Gagal menyimpan foto jenazah'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }

    // Simpan gambar lokasi (wajib)
    String? gambarLokasiPath;
    if (_selectedImageLokasi != null) {
      gambarLokasiPath = await _simpanGambar(_selectedImageLokasi!, 'lokasi');
      if (gambarLokasiPath == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Gagal menyimpan foto lokasi'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    try {
      final jenazah = Jenazah(
        namaPetugas: _namaPetugasController.text.trim(),
        tanggalPenemuan: _formatTanggal(_tanggal!),
        waktuPenemuan: _formatWaktu(_waktu!),
        jumlahLaki: jumlahLaki,
        jumlahPerempuan: jumlahPerempuan,
        lokasiPenemuan: _lokasiController.text.trim(),
        koordinatGPS: _koordinatGPS,
        gambarPath: gambarJenazahPath,
        gambarLokasiPath: gambarLokasiPath,
        kondisiKorban: _kondisiKorban,
      );

      await DatabaseHelper.instance.insertJenazah(jenazah);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Data berhasil disimpan'),
          backgroundColor: Colors.green,
        ),
      );

      // ✅ Reset form setelah simpan
      _formKey.currentState!.reset();
      _namaPetugasController.clear();
      _lokasiController.clear();
      _jumlahLakiController.clear();
      _jumlahPerempuanController.clear();
      setState(() {
        _tanggal = null;
        _waktu = null;
        _selectedImageJenazah = null;
        _selectedImageLokasi = null;
        _koordinatGPS = null;
        _kondisiKorban = 'Meninggal'; // balik ke default
      });

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Gagal menyimpan data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
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
              // Nama Petugas
              TextFormField(
                controller: _namaPetugasController,
                decoration: const InputDecoration(
                  labelText: 'Nama Petugas *',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
              ),

              const SizedBox(height: 16),

              // SECTION: LOKASI
              const Divider(),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Color(0xFF7C4DFF)),
                  const SizedBox(width: 8),
                  const Text(
                    'Data Lokasi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Perkiraan Lokasi (WAJIB)
              TextFormField(
                controller: _lokasiController,
                decoration: const InputDecoration(
                  labelText: 'Perkiraan Lokasi Penemuan *',
                  prefixIcon: Icon(Icons.place),
                  hintText: 'Contoh: Jl. Raya Kampung, Desa X',
                ),
                maxLines: 2,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
              ),

              const SizedBox(height: 12),

              // Koordinat GPS (Jika terdapat sinyal)
              Card(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.gps_fixed,
                            size: 20,
                            color: _koordinatGPS != null
                                ? Colors.green
                                : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Koordinat GPS',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_koordinatGPS != null)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle,
                                  color: Colors.green, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _koordinatGPS!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: () {
                                  setState(() {
                                    _koordinatGPS = null;
                                  });
                                },
                              ),
                            ],
                          ),
                        )
                      else
                        Text(
                          'Ambil koordinat GPS jika ada sinyal',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _isLoadingGPS ? null : _ambilLokasiGPS,
                        icon: _isLoadingGPS
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.my_location, size: 18),
                        label: Text(_isLoadingGPS
                            ? 'Mengambil Lokasi...'
                            : 'Ambil Lokasi GPS'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0091EA),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Foto Lokasi (WAJIB)
              Card(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.photo_camera,
                              color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Foto Lokasi *',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'WAJIB',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_selectedImageLokasi != null)
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _selectedImageLokasi!,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: const Icon(Icons.close,
                                    color: Colors.white),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _selectedImageLokasi = null;
                                  });
                                },
                              ),
                            ),
                          ],
                        )
                      else
                        OutlinedButton.icon(
                          icon: const Icon(Icons.add_a_photo),
                          label: const Text('Ambil Foto Lokasi'),
                          onPressed: () => _showImageSourceDialog(true),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // SECTION: DATA JENAZAH
              const Divider(),
              Row(
                children: [
                  const Icon(Icons.person_outline, color: Color(0xFF7C4DFF)),
                  const SizedBox(width: 8),
                  const Text(
                    'Data Jenazah',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Status Korban (Hidup/Meninggal)
              Card(
                color: isDark 
                    ? const Color(0xFF1E1E1E) 
                    : (_kondisiKorban == 'Hidup' 
                        ? Colors.green.shade50 
                        : Colors.red.shade50),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _kondisiKorban == 'Hidup' 
                                ? Icons.favorite 
                                : Icons.heart_broken,
                            color: _kondisiKorban == 'Hidup' 
                                ? Colors.green 
                                : Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Status Korban *',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              value: 'Hidup',
                              groupValue: _kondisiKorban,
                              onChanged: (value) {
                                setState(() {
                                  _kondisiKorban  = value!;
                                });
                              },
                              title: const Text('Hidup'),
                              activeColor: Colors.green,
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              value: 'Meninggal',
                              groupValue: _kondisiKorban,
                              onChanged: (value) {
                                setState(() {
                                  _kondisiKorban = value!;
                                });
                              },
                              title: const Text('Meninggal'),
                              activeColor: Colors.red,
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Pilih apakah korban ditemukan dalam keadaan hidup atau meninggal',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Jumlah Laki-laki
              TextFormField(
                controller: _jumlahLakiController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Laki-laki *',
                  prefixIcon: Icon(Icons.person),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                  if (int.tryParse(v) == null) return 'Harus angka';
                  if (int.parse(v) < 0) return 'Tidak boleh negatif';
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // Jumlah Perempuan
              TextFormField(
                controller: _jumlahPerempuanController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Perempuan *',
                  prefixIcon: Icon(Icons.person),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                  if (int.tryParse(v) == null) return 'Harus angka';
                  if (int.parse(v) < 0) return 'Tidak boleh negatif';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Tanggal Penemuan
              ElevatedButton.icon(
                icon: const Icon(Icons.date_range),
                label: Text(
                  _tanggal == null
                      ? 'Pilih Tanggal Penemuan *'
                      : 'Tanggal: ${_formatTanggal(_tanggal!)}',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C4DFF),
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null && mounted) {
                    setState(() => _tanggal = picked);
                  }
                },
              ),

              const SizedBox(height: 8),

              // Waktu Penemuan
              ElevatedButton.icon(
                icon: const Icon(Icons.access_time),
                label: Text(
                  _waktu == null
                      ? 'Pilih Waktu Penemuan *'
                      : 'Waktu: ${_formatWaktu(_waktu!)}',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C4DFF),
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final picked = await showTimePicker(
                      context: context, initialTime: TimeOfDay.now());
                  if (picked != null && mounted) {
                    setState(() => _waktu = picked);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Foto Jenazah (Opsional)
              const Divider(),
              Row(
                children: [
                  const Icon(Icons.photo_library_outlined,
                      color: Color(0xFF7C4DFF)),
                  const SizedBox(width: 8),
                  const Text(
                    'Foto Jenazah (Opsional)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (_selectedImageJenazah != null)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _selectedImageJenazah!,
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
                            _selectedImageJenazah = null;
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
                  onPressed: () => _showImageSourceDialog(false),
                ),

              const SizedBox(height: 24),

              // Tombol Simpan
              ElevatedButton(
                onPressed: _simpanData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C4DFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'SIMPAN DATA',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Info wajib
              Text(
                '* Wajib diisi',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
