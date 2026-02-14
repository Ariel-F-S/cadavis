import 'dart:io';
import 'package:flutter/material.dart';
import '../models/korban_hilang.dart';
import '../db/database_helper.dart';

class DetailKorbanPage extends StatefulWidget {
  final KorbanHilang korban;
  final String role;

  const DetailKorbanPage({
    Key? key,
    required this.korban,
    required this.role,
  }) : super(key: key);

  @override
  State<DetailKorbanPage> createState() =>
      _DetailKorbanPageState();
}

class _DetailKorbanPageState
    extends State<DetailKorbanPage> {

  late KorbanHilang korban;

  late TextEditingController ciriController;
  late TextEditingController alamatController;
  late TextEditingController teleponController;
  late TextEditingController lokasiController;

  @override
  void initState() {
    super.initState();

    korban = widget.korban;

    ciriController =
        TextEditingController(text: korban.ciriFisik);
    alamatController =
        TextEditingController(text: korban.alamatRumah);
    teleponController =
        TextEditingController(text: korban.nomorTelepon);
    lokasiController =
        TextEditingController(text: korban.lokasi);
  }

  // ===============================
  // UPDATE STATUS (SEMUA ROLE)
  // ===============================
  Future<void> _updateStatus(String status) async {
    String kondisiBaru = korban.kondisi;

    if (status == "Sudah ditemukan") {
      kondisiBaru = "Masih hidup";
    } else {
      kondisiBaru = "";
    }

    final updated = korban.copyWith(
      status: status,
      kondisi: kondisiBaru,
    );

    await DatabaseHelper.instance
        .updateKorbanHilang(updated);

    setState(() {
      korban = updated;
    });
  }

  // ===============================
  // SAVE EDIT (ADMIN SAJA)
  // ===============================
  Future<void> _saveAdminEdit() async {
    final updated = korban.copyWith(
      ciriFisik: ciriController.text,
      alamatRumah: alamatController.text,
      nomorTelepon: teleponController.text,
      lokasi: lokasiController.text,
    );

    await DatabaseHelper.instance
        .updateKorbanHilang(updated);

    Navigator.pop(context, true);
  }

  // ===============================
  // FOTO FULLSCREEN
  // ===============================
  void _showFullImage() {
    if (korban.fotoPath.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Center(
              child: InteractiveViewer(
                child: Image.file(
                  File(korban.fotoPath),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.role == "admin";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Korban Hilang"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ===============================
          // FOTO (BISA DIKLIK)
          // ===============================
          korban.fotoPath.isNotEmpty
              ? GestureDetector(
                  onTap: _showFullImage,
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(12),
                    child: Image.file(
                      File(korban.fotoPath),
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: const Center(
                      child: Text("Tidak ada foto")),
                ),

          const SizedBox(height: 20),

          // ===============================
          // INFORMASI KORBAN
          // ===============================
          Card(
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(12)),
            elevation: 4,
            child: Padding(
              padding:
                  const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Text(
                    korban.nama,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight:
                            FontWeight.bold),
                  ),

                  const Divider(),

                  Text(
                      "Jenis Kelamin: ${korban.jenisKelamin}"),
                  Text(
                      "Tanggal Hilang: ${korban.tanggalHilang}"),

                  const SizedBox(height: 10),

                  // ===============================
                  // LOKASI (ADMIN EDIT)
                  // ===============================
                  isAdmin
                      ? TextField(
                          controller:
                              lokasiController,
                          decoration:
                              const InputDecoration(
                                  labelText:
                                      "Lokasi"),
                        )
                      : Text(
                          "Lokasi: ${korban.lokasi}"),

                  const SizedBox(height: 10),

                  // ===============================
                  // CIRI FISIK
                  // ===============================
                  isAdmin
                      ? TextField(
                          controller:
                              ciriController,
                          decoration:
                              const InputDecoration(
                                  labelText:
                                      "Ciri Fisik"),
                        )
                      : Text(
                          "Ciri Fisik: ${korban.ciriFisik}"),

                  const SizedBox(height: 10),

                  // ===============================
                  // ALAMAT
                  // ===============================
                  isAdmin
                      ? TextField(
                          controller:
                              alamatController,
                          decoration:
                              const InputDecoration(
                                  labelText:
                                      "Alamat"),
                        )
                      : Text(
                          "Alamat: ${korban.alamatRumah}"),

                  const SizedBox(height: 10),

                  // ===============================
                  // TELEPON
                  // ===============================
                  isAdmin
                      ? TextField(
                          controller:
                              teleponController,
                          decoration:
                              const InputDecoration(
                                  labelText:
                                      "Nomor Telepon"),
                        )
                      : Text(
                          "Telepon: ${korban.nomorTelepon}"),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ===============================
          // STATUS (SEMUA ROLE BISA UBAH)
          // ===============================
          Card(
            color: korban.status ==
                    "Sudah ditemukan"
                ? Colors.green.shade100
                : Colors.red.shade100,
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(12)),
            elevation: 4,
            child: Padding(
              padding:
                  const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Status",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  DropdownButton<String>(
                    value: korban.status,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value:
                            "Belum ditemukan",
                        child: Text(
                            "Belum ditemukan"),
                      ),
                      DropdownMenuItem(
                        value:
                            "Sudah ditemukan",
                        child: Text(
                            "Sudah ditemukan"),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        _updateStatus(value);
                      }
                    },
                  ),

                  if (korban.status ==
                      "Sudah ditemukan")
                    Text(
                        "Kondisi: ${korban.kondisi}"),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ===============================
          // TOMBOL SIMPAN (ADMIN SAJA)
          // ===============================
          if (isAdmin)
            ElevatedButton(
              onPressed: _saveAdminEdit,
              child:
                  const Text("Simpan Perubahan"),
            ),
        ],
      ),
    );
  }
}
