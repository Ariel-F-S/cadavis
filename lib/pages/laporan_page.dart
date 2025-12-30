import 'dart:io';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

import '../db/database_helper.dart';
import '../models/jenazah.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  String? _tanggalTerpilih;
  List<Jenazah> _data = [];
  bool _isExporting = false;

  Future<void> _pilihTanggal() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      final tanggal =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final hasil = await DatabaseHelper.instance.getByTanggal(tanggal);

      setState(() {
        _tanggalTerpilih = tanggal;
        _data = hasil;
      });
    }
  }

  /// REQUEST PERMISSION
  Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      // Untuk Android 13+ (API 33+)
      final androidInfo = await Permission.storage.status;
      
      if (androidInfo.isGranted) {
        return true;
      }

      // Request storage permission
      final status = await Permission.storage.request();
      
      if (status.isDenied || status.isPermanentlyDenied) {
        // Jika ditolak, minta MANAGE_EXTERNAL_STORAGE
        final manageStatus = await Permission.manageExternalStorage.request();
        return manageStatus.isGranted;
      }
      
      return status.isGranted;
    }
    return true;
  }

  /// EXPORT EXCEL KE FOLDER DOWNLOAD
  Future<void> _exportExcel() async {
    if (_tanggalTerpilih == null || _data.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih tanggal & pastikan ada data'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      // 1. Request Permission
      bool hasPermission = await _requestPermission();
      
      if (!hasPermission) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permission ditolak. Buka Settings > Apps > Cadavis > Permissions > Storage'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
        setState(() {
          _isExporting = false;
        });
        return;
      }

      // 2. Buat Excel
      final excel = Excel.createExcel();
      final sheet = excel['Laporan Jenazah'];

      // Header
      sheet.appendRow([
        TextCellValue('Nama Petugas'),
        TextCellValue('Tanggal'),
        TextCellValue('Waktu'),
        TextCellValue('Laki-laki'),
        TextCellValue('Perempuan'),
        TextCellValue('Lokasi'),
      ]);

      // Style header
      for (int i = 0; i < 6; i++) {
        var cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        );
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.fromHexString('#4A90E2'),
          fontColorHex: ExcelColor.white,
        );
      }

      // Isi data
      for (var j in _data) {
        sheet.appendRow([
          TextCellValue(j.namaPetugas),
          TextCellValue(j.tanggalPenemuan),
          TextCellValue(j.waktuPenemuan),
          IntCellValue(j.jumlahLaki),
          IntCellValue(j.jumlahPerempuan),
          TextCellValue(j.lokasiPenemuan),
        ]);
      }

      // 3. Encode Excel
      var fileBytes = excel.encode();
      if (fileBytes == null) {
        throw Exception('Gagal membuat file Excel');
      }

      // 4. Tentukan Path
      String filePath;
      
      if (Platform.isAndroid) {
        // Coba beberapa path untuk Android
        final downloadDir = Directory('/storage/emulated/0/Download');
        
        if (await downloadDir.exists()) {
          filePath = '${downloadDir.path}/Cadavis_${_tanggalTerpilih!}.xlsx';
        } else {
          // Fallback ke Documents
          final dir = await getExternalStorageDirectory();
          filePath = '${dir!.path}/Cadavis_${_tanggalTerpilih!}.xlsx';
        }
      } else {
        final dir = await getApplicationDocumentsDirectory();
        filePath = '${dir.path}/Cadavis_${_tanggalTerpilih!}.xlsx';
      }

      // 5. Simpan File
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);

      // Verifikasi file tersimpan
      if (!await file.exists()) {
        throw Exception('File gagal disimpan');
      }

      if (!mounted) return;

      // 6. Tampilkan Notifikasi Sukses
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ File berhasil disimpan!\n$filePath'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'BUKA',
            textColor: Colors.white,
            onPressed: () async {
              final result = await OpenFile.open(filePath);
              if (result.type != ResultType.done) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Tidak bisa membuka file: ${result.message}'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              }
            },
          ),
        ),
      );

      // 7. Coba buka file otomatis
      await OpenFile.open(filePath);

    } catch (e) {
      if (!mounted) return;
      
      print('Error export: $e'); // Debug
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✗ Gagal export: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Button Pilih Tanggal
            ElevatedButton.icon(
              onPressed: _pilihTanggal,
              icon: const Icon(Icons.calendar_today),
              label: const Text('Pilih Tanggal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C4DFF),
                foregroundColor: Colors.white,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Tampilkan Tanggal Terpilih
            if (_tanggalTerpilih != null)
              Text(
                'Tanggal: $_tanggalTerpilih',
                style: const TextStyle(fontSize: 16),
              ),
            
            const SizedBox(height: 16),
            
            // List Data
            Expanded(
              child: _data.isEmpty
                  ? const Center(child: Text('Tidak ada data'))
                  : ListView.builder(
                      itemCount: _data.length,
                      itemBuilder: (context, index) {
                        final j = _data[index];
                        return ListTile(
                          title: Text(j.namaPetugas),
                          subtitle: Text(
                            'L: ${j.jumlahLaki} | P: ${j.jumlahPerempuan}\n${j.lokasiPenemuan}',
                          ),
                        );
                      },
                    ),
            ),
            
            const SizedBox(height: 16),
            
            // Button Export Excel
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isExporting ? null : _exportExcel,
                icon: _isExporting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.download),
                label: Text(
                  _isExporting ? 'EXPORTING...' : 'EXPORT EXCEL',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF7C4DFF),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}