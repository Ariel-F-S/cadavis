import 'dart:io';
import 'package:flutter/material.dart';
import '../models/korban_hilang.dart';
import '../db/database_helper.dart';

class DetailKorbanPage extends StatefulWidget {
  final KorbanHilang korban;
  final String role;

  const DetailKorbanPage({
    super.key,
    required this.korban,
    required this.role,
  });

  @override
  State<DetailKorbanPage> createState() => _DetailKorbanPageState();
}

class _DetailKorbanPageState extends State<DetailKorbanPage> {

  late TextEditingController ciriController;
  late TextEditingController alamatController;
  late TextEditingController teleponController;
  late TextEditingController lokasiController;

  bool get isAdmin => widget.role == "admin";

  @override
  void initState() {
    super.initState();
    ciriController = TextEditingController(text: widget.korban.ciriFisik);
    alamatController = TextEditingController(text: widget.korban.alamatRumah);
    teleponController = TextEditingController(text: widget.korban.nomorTelepon);
    lokasiController = TextEditingController(text: widget.korban.lokasi);
  }

 import 'package:flutter/material.dart';
import '../models/korban_hilang.dart';
import '../db/database_helper.dart';
import 'detail_korban_page.dart';

class DaftarKorbanHilangPage extends StatefulWidget {
  final String role;

  const DaftarKorbanHilangPage({
    Key? key,
    required this.role,
  }) : super(key: key);

  @override
  State<DaftarKorbanHilangPage> createState() =>
      _DaftarKorbanHilangPageState();
}

class _DaftarKorbanHilangPageState
    extends State<DaftarKorbanHilangPage> {

  List<KorbanHilang> _listKorban = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadKorban();
  }

  Future<void> _loadKorban() async {
    final data =
        await DatabaseHelper.instance.getAllKorbanHilang();
    setState(() {
      _listKorban = data;
      _isLoading = false;
    });
  }

  Future<void> _deleteKorban(int id) async {
    await DatabaseHelper.instance.deleteKorbanHilang(id);
    _loadKorban();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Korban Hilang"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _listKorban.isEmpty
              ? const Center(
                  child: Text("Belum ada data korban"),
                )
              : ListView.builder(
                  itemCount: _listKorban.length,
                  itemBuilder: (context, index) {
                    final korban = _listKorban[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              korban.status == "Sudah ditemukan"
                                  ? Colors.green
                                  : Colors.red,
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(korban.nama),
                        subtitle: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text("Lokasi: ${korban.lokasi}"),
                            Text("Status: ${korban.status}"),
                            if (korban.status ==
                                "Sudah ditemukan")
                              Text(
                                "Kondisi: ${korban.kondisi}",
                                style: TextStyle(
                                  color: korban.kondisi ==
                                          "Meninggal"
                                      ? Colors.red
                                      : Colors.green,
                                ),
                              ),
                          ],
                        ),
                        isThreeLine: true,

                        // ===============================
                        // NAVIGATE KE DETAIL
                        // ===============================
                        onTap: () async {
                          final result =
                              await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetailKorbanPage(
                                korban: korban,
                                role: widget.role,
                              ),
                            ),
                          );

                          if (result != null) {
                            _loadKorban();
                          }
                        },

                        // ===============================
                        // DELETE (HANYA ADMIN)
                        // ===============================
                        trailing: widget.role == "admin"
                            ? IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  if (korban.id != null) {
                                    _deleteKorban(
                                        korban.id!);
                                  }
                                },
                              )
                            : null,
                      ),
                    );
                  },
                ),
    );
  }
}

    await DatabaseHelper.instance.updateKorbanHilang(widget.korban);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data berhasil diperbarui")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Korban Hilang"),
        backgroundColor: const Color(0xFFE91E63),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          /// FOTO
          widget.korban.fotoPath.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(widget.korban.fotoPath),
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                )
              : Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(child: Text("Tidak ada foto")),
                ),

          const SizedBox(height: 20),

          /// DATA UTAMA
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  _buildField("Jenis Kelamin", widget.korban.jenisKelamin, false),
                  _buildField("Tanggal Hilang", widget.korban.tanggalHilang, false),

                  const SizedBox(height: 10),

                  TextField(
                    controller: lokasiController,
                    enabled: isAdmin,
                    decoration: const InputDecoration(
                      labelText: "Lokasi Hilang",
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: ciriController,
                    enabled: isAdmin,
                    decoration: const InputDecoration(
                      labelText: "Ciri Fisik",
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: alamatController,
                    enabled: isAdmin,
                    decoration: const InputDecoration(
                      labelText: "Alamat Rumah",
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: teleponController,
                    enabled: isAdmin,
                    decoration: const InputDecoration(
                      labelText: "Nomor Telepon",
                    ),
                  ),

                  const SizedBox(height: 15),

                  if (isAdmin)
                    ElevatedButton(
                      onPressed: _saveAdminEdit,
                      child: const Text("Simpan Perubahan"),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// STATUS (BOLEH SEMUA ROLE)
          Card(
            color: widget.korban.status == "Sudah ditemukan"
                ? Colors.green.shade100
                : Colors.red.shade100,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text("Status Korban",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                  const SizedBox(height: 10),

                  DropdownButtonFormField<String>(
                    value: widget.korban.status,
                    items: ["Belum ditemukan", "Sudah ditemukan"]
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        widget.korban.status = value!;
                      });
                    },
                  ),

                  if (widget.korban.status == "Sudah ditemukan")
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: "Kondisi",
                        ),
                        controller: TextEditingController(
                            text: widget.korban.kondisi),
                        onChanged: (value) {
                          widget.korban.kondisi = value;
                        },
                      ),
                    ),

                  const SizedBox(height: 15),

                  ElevatedButton(
                    onPressed: () async {
                      await DatabaseHelper.instance
                          .updateKorbanHilang(widget.korban);

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Status berhasil diperbarui")),
                        );
                      }
                    },
                    child: const Text("Update Status"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, String value, bool editable) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        enabled: editable,
        controller: TextEditingController(text: value),
        decoration: InputDecoration(
          labelText: label,
        ),
      ),
    );
  }
}
