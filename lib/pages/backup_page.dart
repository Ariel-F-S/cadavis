import 'dart:io';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart' as ex;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../db/database_helper.dart';

class BackupPage extends StatefulWidget {
  const BackupPage({super.key});

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  bool _isBackingUp = false;
  int _totalData = 0;
  bool _isLoadingCount = false;

  @override
  void initState() {
    super.initState();
    _loadTotalData();
  }

  Future<void> _loadTotalData() async {
    setState(() {
      _isLoadingCount = true;
    });
    
    final data = await DatabaseHelper.instance.getAllJenazah();
    
    if (mounted) {
      setState(() {
        _totalData = data.length;
        _isLoadingCount = false;
      });
    }
  }

  Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      try {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        final sdkInt = androidInfo.version.sdkInt;

        if (sdkInt >= 33) {
          return true;
        }

        if (sdkInt >= 30) {
          if (await Permission.manageExternalStorage.isGranted) {
            return true;
          }
          final status = await Permission.manageExternalStorage.request();
          return status.isGranted;
        }

        if (await Permission.storage.isGranted) {
          return true;
        }
        final status = await Permission.storage.request();
        return status.isGranted;

      } catch (e) {
        debugPrint('Error checking permission: $e');
        return true;
      }
    }
    return true;
  }

  Future<String> _getSavePath(String fileName) async {
    if (Platform.isAndroid) {
      try {
        final downloadDir = Directory('/storage/emulated/0/Download');
        if (await downloadDir.exists()) {
          return '${downloadDir.path}/$fileName';
        }

        final docsDir = Directory('/storage/emulated/0/Documents');
        if (await docsDir.exists()) {
          return '${docsDir.path}/$fileName';
        }

        final appDir = await getExternalStorageDirectory();
        return '${appDir!.path}/$fileName';
      } catch (e) {
        final appDir = await getExternalStorageDirectory();
        return '${appDir!.path}/$fileName';
      }
    } else {
      final dir = await getApplicationDocumentsDirectory();
      return '${dir.path}/$fileName';
    }
  }

  Future<void> _backupData() async {
    // Konfirmasi
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Backup'),
        content: Text(
          'Backup akan membuat file Excel berisi semua data ($_totalData data).\n\nLanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('BATAL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C4DFF),
              foregroundColor: Colors.white,
            ),
            child: const Text('BACKUP'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isBackingUp = true;
    });

    try {
      // Ambil semua data
      final allData = await DatabaseHelper.instance.getAllJenazah();
      
      if (allData.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Tidak ada data untuk di-backup'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() {
          _isBackingUp = false;
        });
        return;
      }

      // Request permission
      bool hasPermission = await _requestPermission();
      if (!hasPermission) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Permission ditolak'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isBackingUp = false;
        });
        return;
      }

      // Buat Excel
      final excel = ex.Excel.createExcel();
      final sheet = excel['Backup Data Jenazah'];

      // Header
      sheet.appendRow([
        ex.TextCellValue('No'),
        ex.TextCellValue('Nama Petugas'),
        ex.TextCellValue('Tanggal'),
        ex.TextCellValue('Waktu'),
        ex.TextCellValue('Laki-laki'),
        ex.TextCellValue('Perempuan'),
        ex.TextCellValue('Total'),
        ex.TextCellValue('Lokasi'),
        ex.TextCellValue('Koordinat GPS'),
        ex.TextCellValue('Kondisi Korban'),
      ]);

      // Style header
      for (int i = 0; i < 9; i++) {
        var cell = sheet.cell(
          ex.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        );
        cell.cellStyle = ex.CellStyle(
          bold: true,
          backgroundColorHex: ex.ExcelColor.fromHexString('#00BFA5'),
          fontColorHex: ex.ExcelColor.white,
        );
      }

      // Isi data
      int no = 1;
      for (var j in allData) {
        sheet.appendRow([
          ex.IntCellValue(no),
          ex.TextCellValue(j.namaPetugas),
          ex.TextCellValue(j.tanggalPenemuan),
          ex.TextCellValue(j.waktuPenemuan),
          ex.IntCellValue(j.jumlahLaki),
          ex.IntCellValue(j.jumlahPerempuan),
          ex.IntCellValue(j.jumlahLaki + j.jumlahPerempuan),
          ex.TextCellValue(j.lokasiPenemuan),
          ex.TextCellValue(j.koordinatGPS ?? '-'),
          ex.TextCellValue(j.kondisiKorban ?? '-'),
        ]);
        no++;
      }

      // Encode
      var fileBytes = excel.encode();
      if (fileBytes == null) {
        throw Exception('Gagal membuat file Excel');
      }

      // Nama file dengan timestamp
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'Cadavis_Backup_$timestamp.xlsx';

      // Simpan
      final filePath = await _getSavePath(fileName);
      final file = File(filePath);
      
      final dir = Directory(file.parent.path);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      
      await file.writeAsBytes(fileBytes);

      if (!await file.exists()) {
        throw Exception('File gagal disimpan');
      }

      if (!mounted) return;

      // Sukses
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ Backup berhasil! ${allData.length} data tersimpan\n📁 $filePath'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'BUKA',
            textColor: Colors.white,
            onPressed: () async {
              await OpenFile.open(filePath);
            },
          ),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      await OpenFile.open(filePath);

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✗ Gagal backup: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isBackingUp = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup Data'),
        backgroundColor: const Color(0xFF00BFA5),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xFF00BFA5).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.backup_outlined,
                  size: 80,
                  color: Color(0xFF00BFA5),
                ),
              ),
              
              const SizedBox(height: 32),
              
              const Text(
                'Backup Semua Data',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              Text(
                'Semua data jenazah akan di-backup ke file Excel\ndan disimpan di folder Download',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark 
                      ? const Color(0xFF1E1E1E) 
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.inventory_2_outlined,
                      color: Color(0xFF00BFA5),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isLoadingCount 
                          ? 'Memuat...' 
                          : 'Total Data: $_totalData',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 48),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isBackingUp ? null : _backupData,
                  icon: _isBackingUp
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.backup, size: 24),
                  label: Text(
                    _isBackingUp ? 'BACKING UP...' : 'MULAI BACKUP',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: const Color(0xFF00BFA5),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark 
                      ? const Color(0xFF1E1E1E) 
                      : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue[700],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informasi Backup:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '• Backup mencakup SEMUA data jenazah\n'
                            '• Format: Cadavis_Backup_[timestamp].xlsx\n'
                            '• Lakukan backup secara berkala\n'
                            '• Simpan file backup di tempat aman',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}