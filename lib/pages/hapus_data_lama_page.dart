import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/jenazah.dart';

class HapusDataLamaPage extends StatefulWidget {
  const HapusDataLamaPage({super.key});

  @override
  State<HapusDataLamaPage> createState() => _HapusDataLamaPageState();
}

class _HapusDataLamaPageState extends State<HapusDataLamaPage> {
  bool _isLoading = false;
  bool _isDeleting = false;
  int _totalData = 0;
  int _oldDataCount = 0;
  List<Jenazah> _oldData = [];

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _pickDateRange() async {
    final pickedStart = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // langsung hari ini 
      firstDate: DateTime(2000), // batas paling awal 
      lastDate: DateTime.now(), // batas paling akhir 
      );

    if (pickedStart == null) return;

    final pickedEnd = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: pickedStart,
      lastDate: DateTime.now(),
    );

    if (pickedEnd == null) return;

    setState(() {
      _startDate = pickedStart;
      _endDate = pickedEnd;
    });

    _loadData();
  }
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
    final allData = await DatabaseHelper.instance.getAllJenazah();

      final oldData = allData.where((jenazah) {
        try {
          DateTime jenazahDate;
            if (jenazah.tanggalPenemuan.contains('/')) {
            final parts = jenazah.tanggalPenemuan.split('/');
            jenazahDate = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
          } else {
            jenazahDate = DateTime.parse(jenazah.tanggalPenemuan);
          }

          if (_startDate != null && _endDate != null) {
            return jenazahDate.isAfter(_startDate!) &&
                   jenazahDate.isBefore(_endDate!);
          }
          return false;
        } catch (_) {
          return false;
        }
      }).toList();

      if (mounted) {
        setState(() {
          _totalData = allData.length;
          _oldDataCount = oldData.length;
          _oldData = oldData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteOldData() async {
    if (_oldDataCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Tidak ada data dalam rentang yang dipilih'),
          backgroundColor: Colors.green,
        ),
      );
      return;
    }

      final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Konfirmasi Hapus'),
        content: Text(
          'Anda akan menghapus $_oldDataCount data dalam rentang tanggal.\n\n'
          '⚠️ AKSI INI TIDAK DAPAT DIBATALKAN!\n\n'
          'Pastikan Anda sudah melakukan backup data sebelumnya.\n\n'
          'Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('BATAL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('HAPUS'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      int deletedCount = 0;
        for (var jenazah in _oldData) {
        if (jenazah.id != null) {
          await DatabaseHelper.instance.deleteJenazah(jenazah.id!);
          deletedCount++;
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ Berhasil menghapus $deletedCount data'),
          backgroundColor: Colors.green,
          ),
      );

    await _loadData();
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_sweep_outlined,
                        size: 80,
                        color: Colors.orange,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    const Text(
                      'Hapus Data Berdasarkan Rentang',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Text(
                      'Pilih rentang tanggal untuk menghapus data jenazah\nagar penyimpanan lebih efisien',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 32),

                    if (_startDate != null && _endDate != null)
                      Text(
                        'Rentang: ${_startDate!.toLocal()} - ${_endDate!.toLocal()}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),

                    const SizedBox(height: 24),
                    // tanggal picker
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Hapus Data Berdasarkan Rentang Tanggal',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.date_range),
                          label: const Text('Pilih Rentang Tanggal'),
                          onPressed: _pickDateRange,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_startDate != null && _endDate != null)
                          Text(
                            'Rentang: ${_startDate!.toLocal()} - ${_endDate!.toLocal()}',
                            textAlign: TextAlign.center,
                          ),
                        const SizedBox(height: 24),
                        // lanjut ke statistik, list data, tombol hapus, dll
                      ],
                    ),
                    // Statistik
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark 
                                  ? const Color(0xFF1E1E1E) 
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.inventory_2_outlined,
                                    color: Colors.blue, size: 32),
                                const SizedBox(height: 8),
                                Text(
                                  '$_totalData',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                const Text('Total Data',
                                    style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark 
                                  ? const Color(0xFF1E1E1E) 
                                  : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.delete_outline,
                                    color: Colors.red, size: 32),
                                const SizedBox(height: 8),
                                Text(
                                  '$_oldDataCount',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                const Text('Data dalam rentang',
                                    style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    // List data lama
                    if (_oldDataCount > 0) ...[
                      const Text(
                        'Data yang akan dihapus:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        decoration: BoxDecoration(
                          color: isDark 
                              ? const Color(0xFF1E1E1E) 
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: _oldData.length > 5 ? 5 : _oldData.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final jenazah = _oldData[index];
                            return ListTile(
                              dense: true,
                              leading: const Icon(Icons.calendar_today, size: 16),
                              title: Text(
                                jenazah.namaPetugas,
                                style: const TextStyle(fontSize: 13),
                              ),
                              subtitle: Text(
                                jenazah.tanggalPenemuan,
                                style: const TextStyle(fontSize: 11),
                              ),
                              trailing: Text(
                                '${jenazah.jumlahLaki + jenazah.jumlahPerempuan}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      if (_oldData.length > 5)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '... dan ${_oldData.length - 5} data lainnya',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      const SizedBox(height: 24),
                    ],
                    
                    // Button Hapus
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isDeleting ? null : _deleteOldData,
                        icon: _isDeleting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.delete_sweep, size: 24),
                        label: Text(
                          _isDeleting 
                              ? 'MENGHAPUS...' 
                              : _oldDataCount > 0
                                  ? 'HAPUS DATA RENTANG'
                                  : 'TIDAK ADA DATA',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          backgroundColor: _oldDataCount > 0 ? Colors.orange : Colors.grey,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark 
                            ? const Color(0xFF1E1E1E) 
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Peringatan:',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '• Data yang dihapus TIDAK DAPAT dikembalikan\n'
                                  '• Pastikan sudah backup data sebelumnya\n'
                                  '• Data yang dihapus: sesuai rentang tanggal yang dipilih\n'
                                  '• Gunakan fitur ini secara berkala untuk maintenance\n'
                                  '• Hubungi admin jika ragu',
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
