import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/korban_hilang.dart';

class EditKorbanPage extends StatefulWidget {
  final KorbanHilang korban;

  const EditKorbanPage({super.key, required this.korban});

  @override
  State<EditKorbanPage> createState() => _EditKorbanPageState();
}

class _EditKorbanPageState extends State<EditKorbanPage> {
  String? _selectedStatus;
  String? _selectedKondisi;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.korban.status;
    _selectedKondisi = widget.korban.kondisi;
  }

  Future<void> _simpanPerubahan() async {
    final updatedKorban = KorbanHilang(
      id: widget.korban.id,
      nama: widget.korban.nama,
      jenisKelamin: widget.korban.jenisKelamin,
      tanggalHilang: widget.korban.tanggalHilang,
      lokasi: widget.korban.lokasi,
      ciriFisik: widget.korban.ciriFisik,
      alamatRumah: widget.korban.alamatRumah,
      fotoPath: widget.korban.fotoPath,
      status: _selectedStatus ?? widget.korban.status,
      kondisi: _selectedKondisi ?? widget.korban.kondisi,
      nomorTelepon: widget.korban.nomorTelepon,
    );

    await DatabaseHelper.instance.updateKorbanHilang(updatedKorban);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Data korban berhasil diperbarui")),
    );
    Navigator.pop(context, updatedKorban);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Data Korban"),
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
            child: ListView(
              children: [
                Text(
                  widget.korban.nama,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Jenis Kelamin: ${widget.korban.jenisKelamin}\n"
                  "Tanggal Hilang: ${widget.korban.tanggalHilang}\n"
                  "Lokasi: ${widget.korban.lokasi}\n"
                  "Ciri Fisik: ${widget.korban.ciriFisik}\n"
                  "Alamat: ${widget.korban.alamatRumah}",
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),

                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  items: const [
                    DropdownMenuItem(value: "Belum ditemukan", child: Text("Belum ditemukan")),
                    DropdownMenuItem(value: "Sudah ditemukan", child: Text("Sudah ditemukan")),
                  ],
                  onChanged: (val) => setState(() => _selectedStatus = val),
                  decoration: const InputDecoration(
                    labelText: "Status Korban",
                    prefixIcon: Icon(Icons.flag),
                  ),
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _selectedKondisi,
                  items: const [
                    DropdownMenuItem(value: "Masih hidup", child: Text("Masih hidup")),
                    DropdownMenuItem(value: "Meninggal", child: Text("Meninggal")),
                  ],
                  onChanged: (val) => setState(() => _selectedKondisi = val),
                  decoration: const InputDecoration(
                    labelText: "Kondisi Korban",
                    prefixIcon: Icon(Icons.heart_broken),
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text("Simpan Perubahan"),
                  onPressed: _simpanPerubahan,
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
    );
  }
}