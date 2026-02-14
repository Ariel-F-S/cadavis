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

  bool isEditMode = false;

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
  // UPDATE STATUS
  // ===============================
  Future<void> _updateStatus(String status) async {
    final updated = korban.copyWith(
      status: status,
      kondisi:
          status == "Belum ditemukan" ? "" : korban.kondisi,
    );

    await DatabaseHelper.instance
        .updateKorbanHilang(updated);

    setState(() {
      korban = updated;
    });
  }

  // ===============================
  // UPDATE KONDISI
  // ===============================
  Future<void> _updateKondisi(String kondisi) async {
    final updated = korban.copyWith(
      kondisi: kondisi,
    );

    await DatabaseHelper.instance
        .updateKorbanHilang(updated);

    setState(() {
      korban = updated;
    });
  }

  // ===============================
  // SAVE EDIT (ADMIN)
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

    setState(() {
      korban = updated;
      isEditMode = false;
    });
  }

  // ===============================
  // FULLSCREEN FOTO
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
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final cardColor =
        isDark ? const Color(0xFF1E1E1E) : Colors.white;

    final primaryText =
        isDark ? Colors.white : Colors.black87;

    final secondaryText =
        isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Korban Hilang"),
        actions: [
          if (isAdmin)
            IconButton(
              icon: Icon(
                isEditMode
                    ? Icons.close
                    : Icons.edit,
              ),
              onPressed: () {
                setState(() {
                  isEditMode = !isEditMode;
                });
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ===============================
          // FOTO
          // ===============================
          korban.fotoPath.isNotEmpty
              ? GestureDetector(
                  onTap: _showFullImage,
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(12),
                    child: Image.file(
                      File(korban.fotoPath),
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : const SizedBox(),

          const SizedBox(height: 20),

          // ===============================
          // CARD BIODATA
          // ===============================
          Card(
            color: cardColor,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Text(
                    korban.nama,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                      color: primaryText,
                    ),
                  ),

                  Divider(
                    color: isDark
                        ? Colors.grey[700]
                        : Colors.grey[400],
                  ),

                  const SizedBox(height: 10),

                  isEditMode
                      ? TextField(
                          controller:
                              lokasiController,
                          style: TextStyle(
                              color:
                                  primaryText),
                          decoration:
                              const InputDecoration(
                                  labelText:
                                      "Lokasi"),
                        )
                      : Text(
                          "Lokasi: ${korban.lokasi}",
                          style: TextStyle(
                              color:
                                  secondaryText),
                        ),

                  const SizedBox(height: 10),

                  isEditMode
                      ? TextField(
                          controller:
                              ciriController,
                          style: TextStyle(
                              color:
                                  primaryText),
                          decoration:
                              const InputDecoration(
                                  labelText:
                                      "Ciri Fisik"),
                        )
                      : Text(
                          "Ciri Fisik: ${korban.ciriFisik}",
                          style: TextStyle(
                              color:
                                  secondaryText),
                        ),

                  const SizedBox(height: 10),

                  isEditMode
                      ? TextField(
                          controller:
                              alamatController,
                          style: TextStyle(
                              color:
                                  primaryText),
                          decoration:
                              const InputDecoration(
                                  labelText:
                                      "Alamat"),
                        )
                      : Text(
                          "Alamat: ${korban.alamatRumah}",
                          style: TextStyle(
                              color:
                                  secondaryText),
                        ),

                  const SizedBox(height: 10),

                  isEditMode
                      ? TextField(
                          controller:
                              teleponController,
                          style: TextStyle(
                              color:
                                  primaryText),
                          decoration:
                              const InputDecoration(
                                  labelText:
                                      "Nomor Telepon"),
                        )
                      : Text(
                          "Telepon: ${korban.nomorTelepon}",
                          style: TextStyle(
                              color:
                                  secondaryText),
                        ),

                  const SizedBox(height: 20),

                  if (isEditMode)
                    ElevatedButton(
                      onPressed:
                          _saveAdminEdit,
                      child: const Text(
                          "Simpan Perubahan"),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 25),

          // ===============================
          // CARD STATUS
          // ===============================
          Card(
            color: cardColor,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Text(
                    "Apakah korban sudah ditemukan?",
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      color: primaryText,
                    ),
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

                  const SizedBox(height: 20),

                  if (korban.status ==
                      "Sudah ditemukan") ...[

                    Text(
                      "Bagaimana kondisi korban?",
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        color: primaryText,
                      ),
                    ),

                    const SizedBox(height: 10),

                    DropdownButton<String>(
                      value: korban.kondisi
                              .isEmpty
                          ? "Masih hidup"
                          : korban.kondisi,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(
                          value:
                              "Masih hidup",
                          child: Text(
                              "Masih hidup"),
                        ),
                        DropdownMenuItem(
                          value:
                              "Sudah meninggal",
                          child: Text(
                              "Sudah meninggal"),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          _updateKondisi(value);
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
