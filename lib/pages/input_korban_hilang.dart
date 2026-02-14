import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
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
  final _lokasiController = TextEditingController();
  final _alamatController = TextEditingController();
  final _teleponController = TextEditingController();

  // ✅ Ciri fisik detail
  final _tinggiController = TextEditingController();
  final _rambutController = TextEditingController();
  final _kulitController = TextEditingController();
  final _tandaKhususController = TextEditingController();

  String? _selectedGender;
  DateTime? _selectedDate;
  File? _selectedImage;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _simpanData() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Foto korban wajib diupload")),
        );
        return;
      }

      // ✅ Gabungkan ciri fisik detail
      final ciriFisik =
          "Tinggi: ${_tinggiController.text} cm, "
          "Rambut: ${_rambutController.text}, "
          "Kulit: ${_kulitController.text}, "
          "Tanda khusus: ${_tandaKhususController.text}";

      final korban = KorbanHilang(
        nama: _namaController.text,
        jenisKelamin: _selectedGender ?? "-",
        tanggalHilang: _selectedDate != null
            ? DateFormat('dd-MM-yyyy').format(_selectedDate!)
            : "-",
        lokasi: _lokasiController.text,
        ciriFisik: ciriFisik,
        alamatRumah: _alamatController.text,
        nomorTelepon: _teleponController.text,
        status: "Belum ditemukan", // default
        kondisi: "", // default kosong
        fotoPath: _selectedImage!.path,
      );

      await DatabaseHelper.instance.insertKorbanHilang(korban);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data korban hilang berhasil disimpan")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Input Korban Hilang"),
        backgroundColor: const Color(0xFFE91E63),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  // Foto korban
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400, width: 2),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade100,
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            )
                          : const Center(
                              child: Text("Upload Foto Korban"),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _namaController,
                    decoration: const InputDecoration(
                      labelText: "Nama",
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    initialValue: _selectedGender,
                    items: const [
                      DropdownMenuItem(value: "Laki-laki", child: Text("Laki-laki")),
                      DropdownMenuItem(value: "Perempuan", child: Text("Perempuan")),
                    ],
                    onChanged: (val) => setState(() => _selectedGender = val),
                    decoration: const InputDecoration(
                      labelText: "Jenis Kelamin",
                      prefixIcon: Icon(Icons.wc),
                    ),
                    validator: (val) => val == null ? "Pilih jenis kelamin" : null,
                  ),
                  const SizedBox(height: 12),

                  InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: "Tanggal Hilang",
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _selectedDate != null
                            ? DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate!)
                            : "Pilih tanggal",
                        style: TextStyle(
                          color: _selectedDate != null
                              ? (isDark ? Colors.white : Colors.black)
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _lokasiController,
                    decoration: const InputDecoration(
                      labelText: "Lokasi Hilang",
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
                  ),
                  const SizedBox(height: 12),

                  // ✅ Ciri fisik detail
                  TextFormField(
                    controller: _tinggiController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Tinggi Badan (cm)",
                      prefixIcon: Icon(Icons.height),
                    ),
                    validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _rambutController,
                    decoration: const InputDecoration(
                      labelText: "Warna Rambut",
                      prefixIcon: Icon(Icons.brush),
                    ),
                    validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _kulitController,
                    decoration: const InputDecoration(
                      labelText: "Warna Kulit",
                      prefixIcon: Icon(Icons.color_lens),
                    ),
                    validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
                  ),
                  const SizedBox(height: 12),                
                    TextFormField(
                    controller: _tandaKhususController,
                    decoration: const InputDecoration(
                      labelText: "Tanda Khusus (tato, bekas luka, dll)",
                      prefixIcon: Icon(Icons.accessibility_new),
                    ),
                    validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _alamatController,
                    decoration: const InputDecoration(
                      labelText: "Alamat Rumah",
                      prefixIcon: Icon(Icons.home),
                    ),
                    validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _teleponController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "Nomor Telepon yang dapat dihubungi",
                      prefixIcon: Icon(Icons.phone),
                    ),
                    validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text("Simpan"),
                    onPressed: _simpanData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
