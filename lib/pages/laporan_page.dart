import 'dart:io';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart' as ex;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../db/database_helper.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  bool _isExporting = false;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  int _totalData = 0;
  bool _isLoadingCount = false;

  @override
  void initState() {
    super.initState();
    _initializeDateFormatting();
    _loadTotalData();
  }

  /// INITIALIZE DATE FORMATTING
  Future<void> _initializeDateFormatting() async {
    await initializeDateFormatting('id_ID', null);
  }

  /// LOAD TOTAL DATA
    Future<void> _loadTotalData() async {
    setState(() {
      _isLoadingCount = true;
    });
    
    // ❌ sebelumnya: getAllJenazah()
    // ✅ revisi: ambil join jenazah + korban_hilang
    final data = await DatabaseHelper.instance.getJenazahWithStatus();
    
    if (mounted) {
      setState(() {
        _totalData = data.length;
        _isLoadingCount = false;
      });
    }
  }

  /// PILIH TANGGAL AWAL
  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF7C4DFF),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedStartDate = picked;
        if (_selectedEndDate != null && _selectedEndDate!.isBefore(picked)) {
          _selectedEndDate = null;
        }
      });
    }
  }

  /// PILIH TANGGAL AKHIR
  Future<void> _pickEndDate() async {
    if (_selectedStartDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Pilih tanggal mulai terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate ?? _selectedStartDate ?? DateTime.now(),
      firstDate: _selectedStartDate!,
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF7C4DFF),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedEndDate = picked;
      });
    }
  }

  /// REQUEST PERMISSION
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
          
          if (status.isDenied || status.isPermanentlyDenied) {
            if (mounted) {
              _showPermissionDialog();
            }
            return false;
          }
          
          return status.isGranted;
        }

        if (await Permission.storage.isGranted) {
          return true;
        }

        final status = await Permission.storage.request();
        
        if (status.isDenied || status.isPermanentlyDenied) {
          if (mounted) {
            _showPermissionDialog();
          }
          return false;
        }
        
        return status.isGranted;

      } catch (e) {
        debugPrint('Error checking permission: $e');
        return true;
      }
    }
    return true;
  }

  /// DIALOG PERMISSION
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Izin Diperlukan'),
        content: const Text(
          'Aplikasi memerlukan izin penyimpanan untuk menyimpan file Excel.\n\n'
          'Silakan buka Settings > Apps > Cadavis > Permissions dan aktifkan izin Storage atau Files.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BATAL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C4DFF),
              foregroundColor: Colors.white,
            ),
            child: const Text('BUKA SETTINGS'),
          ),
        ],
      ),
    );
  }

  /// FILTER DATA BERDASARKAN TANGGAL
 List<Map<String, dynamic>> _filterDataByDate(List<Map<String, dynamic>> allData) {
  if (_selectedStartDate == null && _selectedEndDate == null) {
    return allData;
  }

  return allData.where((j) {
    try {
      DateTime jenazahDate = DateTime.parse(j['tanggal_penemuan']);
      if (_selectedStartDate != null && jenazahDate.isBefore(_selectedStartDate!)) {
        return false;
      }
      if (_selectedEndDate != null && jenazahDate.isAfter(_selectedEndDate!)) {
        return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }).toList();
}


  /// GET SAVE PATH
  Future<String> _getSavePath(String fileName) async {
    if (Platform.isAndroid) {
      try {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        final sdkInt = androidInfo.version.sdkInt;

        if (sdkInt >= 29) {
          final downloadDir = Directory('/storage/emulated/0/Download');
          
          if (await downloadDir.exists()) {
            return '${downloadDir.path}/$fileName';
          }
        }

        final docsDir = Directory('/storage/emulated/0/Documents');
        if (await docsDir.exists()) {
          return '${docsDir.path}/$fileName';
        }

        final appDir = await getExternalStorageDirectory();
        return '${appDir!.path}/$fileName';

      } catch (e) {
        debugPrint('Error getting save path: $e');
        final appDir = await getExternalStorageDirectory();
        return '${appDir!.path}/$fileName';
      }
    } else {
      final dir = await getApplicationDocumentsDirectory();
      return '${dir.path}/$fileName';
    }
  }

  /// EXPORT EXCEL
    Future<void> _exportExcel() async {
    if (_selectedStartDate == null && _selectedEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Pilih minimal tanggal mulai untuk export'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      // ❌ sebelumnya: getAllJenazah()
      // ✅ revisi: ambil join jenazah + korban_hilang
      final allData = await DatabaseHelper.instance.getJenazahWithStatus();
      final filteredData = _filterDataByDate(allData);

      if (filteredData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Tidak ada data pada rentang tanggal yang dipilih'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() => _isExporting = false);
        return;
      }

      final excel = ex.Excel.createExcel();
      final sheet = excel['Laporan Jenazah'];

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
        ex.TextCellValue('Status Korban'),   // ✅ dari korban_hilang
        ex.TextCellValue('Kondisi Korban'),  // ✅ dari korban_hilang
      ]);

      int no = 1;
      for (var j in filteredData) {
        sheet.appendRow([
          ex.IntCellValue(no),
          ex.TextCellValue(j['nama_petugas'] ?? ''),
          ex.TextCellValue(j['tanggal_penemuan'] ?? ''),
          ex.TextCellValue(j['waktu_penemuan'] ?? ''),
          ex.IntCellValue(j['jumlah_laki'] ?? 0),
          ex.IntCellValue(j['jumlah_perempuan'] ?? 0),
          ex.IntCellValue((j['jumlah_laki'] ?? 0) + (j['jumlah_perempuan'] ?? 0)),
          ex.TextCellValue(j['lokasi_penemuan'] ?? ''),
          ex.TextCellValue(j['koordinat_gps'] ?? '-'),
          ex.TextCellValue(j['status'] ?? '-'),   // ✅ ambil dari join korban_hilang
          ex.TextCellValue(j['kondisi'] ?? '-'),  // ✅ ambil dari join korban_hilang
        ]);
        no++;
      }

      // sisanya (save file, snackbar, open file) tetap sama


      var fileBytes = excel.encode();
      if (fileBytes == null) {
        throw Exception('Gagal membuat file Excel');
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final dateFormat = DateFormat('ddMMyyyy');
      final startStr = _selectedStartDate != null ? dateFormat.format(_selectedStartDate!) : 'All';
      final endStr = _selectedEndDate != null ? dateFormat.format(_selectedEndDate!) : 'Now';
      final fileName = 'Cadavis_${startStr}_${endStr}_$timestamp.xlsx';

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

      debugPrint('File saved at: $filePath');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ Berhasil export ${filteredData.length} data!\n📁 $filePath'),
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

    } catch (e, stackTrace) {
      debugPrint('Export error: $e');
      debugPrint('Stack trace: $stackTrace');
      
      if (!mounted) return;
      
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Data'),
        backgroundColor: const Color(0xFF7C4DFF),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C4DFF).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.file_download_outlined,
                    size: 80,
                    color: Color(0xFF7C4DFF),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              const Text(
                'Export Data Jenazah',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              Text(
                'Pilih rentang tanggal untuk export data jenazah\nmenjadi file Excel (.xlsx)',
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
                      color: Color(0xFF7C4DFF),
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
              
              const SizedBox(height: 24),
              
              const Text(
                'Filter Tanggal',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 12),
              
              InkWell(
                onTap: _pickStartDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _selectedStartDate != null 
                          ? const Color(0xFF7C4DFF) 
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: _selectedStartDate != null 
                            ? const Color(0xFF7C4DFF) 
                            : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tanggal Mulai',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedStartDate != null
                                  ? dateFormat.format(_selectedStartDate!)
                                  : 'Pilih tanggal mulai',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _selectedStartDate != null
                                    ? (isDark ? Colors.white : Colors.black)
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              InkWell(
                onTap: _pickEndDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _selectedEndDate != null 
                          ? const Color(0xFF7C4DFF) 
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: _selectedEndDate != null 
                            ? const Color(0xFF7C4DFF) 
                            : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tanggal Akhir (Opsional)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedEndDate != null
                                  ? dateFormat.format(_selectedEndDate!)
                                  : 'Pilih tanggal akhir',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _selectedEndDate != null
                                    ? (isDark ? Colors.white : Colors.black)
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              ElevatedButton.icon(
                onPressed: _isExporting ? null : _exportExcel,  // INI YANG DIPERBAIKI
                icon: _isExporting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.download, size: 24),
                label: Text(
                  _isExporting ? 'EXPORTING...' : 'EXPORT EXCEL',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: const Color(0xFF7C4DFF),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              if (_selectedStartDate != null || _selectedEndDate != null)
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedStartDate = null;
                      _selectedEndDate = null;
                    });
                  },
                  icon: const Icon(Icons.clear),
                  label: const Text('RESET FILTER'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    foregroundColor: const Color(0xFF7C4DFF),
                    side: const BorderSide(
                      color: Color(0xFF7C4DFF),
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
                            'Informasi:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '• Pilih tanggal mulai wajib diisi\n'
                            '• Tanggal akhir opsional (jika tidak diisi, akan sampai hari ini)\n'
                            '• Format nama: Cadavis_[tanggal].xlsx\n'
                            '• Android 13+ tidak perlu izin khusus',
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