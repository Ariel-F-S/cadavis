import 'dart:io';
import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/korban_hilang.dart';
import 'detail_korban_hilang.dart';

class DaftarKorbanHilangPage extends StatefulWidget {
  final String role;

  const DaftarKorbanHilangPage({
    super.key,
    required this.role,
  });

  @override
  State<DaftarKorbanHilangPage> createState() =>
      _DaftarKorbanHilangPageState();
}

class _DaftarKorbanHilangPageState
    extends State<DaftarKorbanHilangPage> {

  List<KorbanHilang> _korbanList = [];
  bool get isAdmin => widget.role == "admin";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data =
        await DatabaseHelper.instance.getAllKorbanHilang();
    setState(() {
      _korbanList = data;
    });
  }

  @override
  Widget build(BuildContext context) {

    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final cardColor =
        isDark ? const Color(0xFF1E1E1E) : Colors.white;

    final textColor =
        isDark ? Colors.white70 : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Korban Hilang'),
      ),
      body: _korbanList.isEmpty
          ? Center(
              child: Text(
                'Belum ada data korban hilang',
                style: TextStyle(color: textColor),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView.builder(
                itemCount: _korbanList.length,
                itemBuilder: (context, index) {

                  final korban = _korbanList[index];

                  return Card(
                    color: cardColor,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      borderRadius:
                          BorderRadius.circular(12),
                      onTap: () async {

                        final result =
                            await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailKorbanPage(
                              korban: korban,
                              role: widget.role,
                            ),
                          ),
                        );

                        if (result != null) {
                          _loadData();
                        }
                      },
                      child: Padding(
                        padding:
                            const EdgeInsets.all(12),
                        child: Row(
                          children: [

                            /// FOTO
                            korban.fotoPath.isNotEmpty
                                ? ClipRRect(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                                8),
                                    child: Image.file(
                                      File(
                                          korban
                                              .fotoPath),
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit
                                          .cover,
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    size: 50,
                                    color: isDark
                                        ? Colors
                                            .white70
                                        : Colors.grey[
                                            700],
                                  ),

                            const SizedBox(
                                width: 12),

                            /// INFO
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    korban.nama,
                                    style: TextStyle(
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                      fontSize: 16,
                                      color:
                                          textColor,
                                    ),
                                  ),
                                  const SizedBox(
                                      height: 4),
                                  Text(
                                    "${korban.jenisKelamin} • Hilang: ${korban.tanggalHilang}\nLokasi: ${korban.lokasi}",
                                    style:
                                        TextStyle(
                                      fontSize:
                                          13,
                                      color: isDark
                                          ? Colors
                                              .white60
                                          : Colors
                                              .black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// STATUS BADGE
                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                          horizontal:
                                              8,
                                          vertical:
                                              4),
                              decoration:
                                  BoxDecoration(
                                color: korban
                                            .status ==
                                        "Sudah ditemukan"
                                    ? Colors
                                        .green
                                    : Colors.red,
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            8),
                              ),
                              child: Text(
                                korban.status,
                                style:
                                    const TextStyle(
                                  color:
                                      Colors.white,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

      /// FAB hanya admin
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () async {
                final result =
                    await Navigator.pushNamed(
                  context,
                  '/menu-korban-hilang',
                );

                if (result != null) {
                  _loadData();
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
