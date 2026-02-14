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
  bool isLoading = false;

  late TextEditingController ciriController;
  late TextEditingController alamatController;
  late TextEditingController teleponController;
  late TextEditingController lokasiController;

  final List<String> statusList = [
    "Belum ditemukan",
    "Sudah ditemukan"
  ];

  final List<String> kondisiList = [
    "Masih hidup",
    "Sudah meninggal"
  ];

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

  @override
  void dispose() {
    ciriController.dispose();
    alamatController.dispose();
    teleponController.dispose();
    lokasiController.dispose();
    super.dispose();
  }

  // ===============================
  // UPDATE STATUS (AUTO SAVE)
  // ===============================
  Future<void> _updateStatus(String status) async {
    setState(() => isLoading = true);

    final updated = korban.copyWith(
      status: status,
      kondisi:
          status == "Belum ditemukan" ? "" : korban.kondisi,
    );

    await DatabaseHelper.instance
        .updateKorbanHilang(updated);

    if (!mounted) return;

    setState(() {
      korban = updated;
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Status berhasil diperbarui"),
        backgroundColor: Colors.green,
      ),
    );
  }

  // ===============================
  // UPDATE KONDISI (AUTO SAVE)
  // ===============================
  Future<void> _updateKondisi(String kondisi) async {
    setState(() => isLoading = true);

    final updated = korban.copyWith(
      kondisi: kondisi,
    );

    await DatabaseHelper.instance
        .updateKorbanHilang(updated);

    if (!mounted) return;

    setState(() {
      korban = updated;
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Kondisi berhasil diperbarui"),
        backgroundColor: Colors.green,
      ),
    );
  }

  // ===============================
  // SAVE EDIT (ADMIN ONLY)
  // ===============================
  Future<void> _saveAdminEdit() async {
    setState(() => isLoading = true);

    final updated = korban.copyWith(
      ciriFisik: ciriController.text,
      alamatRumah: alamatController.text,
      nomorTelepon: teleponController.text,
      lokasi: lokasiController.text,
    );

    await DatabaseHelper.instance
        .updateKorbanHilang(updated);

    if (!mounted) return;

    setState(() {
      korban = updated;
      isEditMode = false;
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Data berhasil diperbarui"),
        backgroundColor: Colors.green,
      ),
    );
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

    final safeStatus = statusList.contains(korban.status)
        ? korban.status
        : "Belum ditemukan";

    final safeKondisi = kondisiList.contains(korban.kondisi)
        ? korban.kondisi
        : "Masih hidup";

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
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [

              // FOTO
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

              // BIODATA CARD
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

                      const SizedBox(height: 15),

                      isEditMode
                          ? TextField(
                              controller:
                                  lokasiController,
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

                      if (isEditMode)
                        Padding(
                          padding:
                              const EdgeInsets.only(
                                  top: 15),
                          child: ElevatedButton(
                            onPressed:
                                _saveAdminEdit,
                            child: const Text(
                                "Simpan Perubahan"),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // STATUS CARD
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

                      const Text(
                        "Apakah korban sudah ditemukan?",
                        style: TextStyle(
                            fontWeight:
                                FontWeight.bold),
                      ),

                      const SizedBox(height: 10),

                      DropdownButton<String>(
                        value: safeStatus,
                        isExpanded: true,
                        items: statusList
                            .map((e) =>
                                DropdownMenuItem(
                                  value: e,
                                  child: Text(e),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            _updateStatus(value);
                          }
                        },
                      ),

                      const SizedBox(height: 20),

                      if (safeStatus ==
                          "Sudah ditemukan") ...[
                        const Text(
                          "Bagaimana kondisi korban?",
                          style: TextStyle(
                              fontWeight:
                                  FontWeight.bold),
                        ),

                        const SizedBox(height: 10),

                        DropdownButton<String>(
                          value: safeKondisi,
                          isExpanded: true,
                          items: kondisiList
                              .map((e) =>
                                  DropdownMenuItem(
                                    value: e,
                                    child:
                                        Text(e),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              _updateKondisi(
                                  value);
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

          if (isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child:
                    CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
