import 'package:flutter/material.dart';
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
  final _ciriFisikController = TextEditingController();
  final _alamatController = TextEditingController();

  String? _selectedGender;
  DateTime? _selectedDate;

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

  Future<void> _simpanData() async {
    if (_formKey.currentState!.validate()) {
      final korban = KorbanHilang(
        nama: _namaController.text,
        jenisKelamin: _selectedGender ?? "-",
        tanggalHilang: _selectedDate != null
            ? DateFormat('dd-MM-yyyy').format(_selectedDate!)
            : "-",
        lokasi: _lokasiController.text,
        ciriFisik: _ciriFisikController.text,
        alamatRumah: _alamatController.text,
        status: "Belum ditemukan", // default
        kondisi: "", // default kosong
        fotoPath: "",
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
                    value: _selectedGender,
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
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _ciriFisikController,
                    decoration: const InputDecoration(
                      labelText: "Ciri Fisik",
                      prefixIcon: Icon(Icons.accessibility_new),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _alamatController,
                    decoration: const InputDecoration(
                      labelText: "Alamat Rumah",
                      prefixIcon: Icon(Icons.home),
                    ),
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
