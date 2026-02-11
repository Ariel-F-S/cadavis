import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

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
  int _filteredCount = 0;
  List<Jenazah> _filteredData = [];

  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _loadData();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedStartDate = picked;
        if (_selectedEndDate != null && _selectedEndDate!.isBefore(picked)) {
          _selectedEndDate = null;
        }
      });
      _loadData();
    }
  }

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
    );
    if (picked != null) {
      setState(() {
        _selectedEndDate = picked;
      });
      _loadData();
    }
  }
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final allData = await DatabaseHelper.instance.getAllJenazah();

      final filtered = allData.where((jenazah) {
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

          if (_selectedStartDate != null) {
            final startDateOnly = DateTime(_selectedStartDate!.year, _selectedStartDate!.month, _selectedStartDate!.day);
            if (jenazahDate.isBefore(startDateOnly)) return false;
          }

          if (_selectedEndDate != null) {
            final endDateOnly = DateTime(_selectedEndDate!.year, _selectedEndDate!.month, _selectedEndDate!.day);
            if (jenazahDate.isAfter(endDateOnly)) return false;
          }

          return true;
        } catch (_) {
          return false;
        }
      }).toList();

      if (mounted) {
        setState(() {
          _totalData = allData.length;
          _filteredCount = filtered.length;
          _filteredData = filtered;
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

  Future<void> _deleteFilteredData() async {
    if (_filteredCount == 0) {
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
          'Anda akan menghapus $_filteredCount data dalam rentang tanggal.\n\n'
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
      for (var jenazah in _filteredData) {
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
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hapus Data Lama'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
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
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Hapus Data Berdasarkan Rentang Tanggal',
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

                  // Filter tanggal
                  InkWell(
                    onTap: _pickStartDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedStartDate != null ? Colors.orange : Colors.grey.shade300,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _selectedStartDate != null
                            ? 'Tanggal Mulai: ${dateFormat.format(_selectedStartDate!)}'
                            : 'Pilih Tanggal Mulai',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _pickEndDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedEndDate != null ? Colors.orange : Colors.grey.shade300,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _selectedEndDate != null
                            ? 'Tanggal Akhir: ${dateFormat.format(_selectedEndDate!)}'
                            : 'Pilih Tanggal Akhir (Opsional)',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Text('Total Data: $_totalData'),
                  Text('Data dalam rentang: $_filteredCount'),
                  const SizedBox(height: 24),

                  if (_filteredCount > 0)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.delete),
                      label: Text(_isDeleting ? 'Menghapus...' : 'Hapus Data Rentang'),
                      onPressed: _isDeleting ? null : _deleteFilteredData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
