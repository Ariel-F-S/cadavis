import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/jenazah.dart';

class InputJenazahPage extends StatefulWidget {
  const InputJenazahPage({super.key});

  @override
  State<InputJenazahPage> createState() => _InputJenazahPageState();
}

class _InputJenazahPageState extends State<InputJenazahPage> {
  final _formKey = GlobalKey<FormState>();

  final _namaPetugasController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _jumlahLakiController = TextEditingController();
  final _jumlahPerempuanController = TextEditingController();

  DateTime? _tanggal;
  TimeOfDay? _waktu;

  /// format tanggal manual (ANTI ERROR)
  String _formatTanggal(DateTime date) {
    final y = date.year.toString();
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// format waktu manual
  String _formatWaktu(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _simpanData() async {
    if (!_formKey.currentState!.validate() ||
        _tanggal == null ||
        _waktu == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua data')),
      );
      return;
    }

    final jenazah = Jenazah(
      namaPetugas: _namaPetugasController.text,
      tanggalPenemuan: _formatTanggal(_tanggal!),
      waktuPenemuan: _formatWaktu(_waktu!),
      jumlahLaki: int.parse(_jumlahLakiController.text),
      jumlahPerempuan: int.parse(_jumlahPerempuanController.text),
      lokasiPenemuan: _lokasiController.text,
    );

    await DatabaseHelper.instance.insertJenazah(jenazah);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data berhasil disimpan')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Data Jenazah'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _namaPetugasController,
                decoration:
                    const InputDecoration(labelText: 'Nama Petugas'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _lokasiController,
                decoration: const InputDecoration(
                    labelText: 'Perkiraan Lokasi Penemuan'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _jumlahLakiController,
                decoration:
                    const InputDecoration(labelText: 'Jumlah Laki-laki'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _jumlahPerempuanController,
                decoration:
                    const InputDecoration(labelText: 'Jumlah Perempuan'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),

              const SizedBox(height: 16),

              ElevatedButton.icon(
                icon: const Icon(Icons.date_range),
                label: Text(
                  _tanggal == null
                      ? 'Pilih Tanggal Penemuan'
                      : 'Tanggal: ${_formatTanggal(_tanggal!)}',
                ),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => _tanggal = picked);
                  }
                },
              ),

              const SizedBox(height: 8),

              ElevatedButton.icon(
                icon: const Icon(Icons.access_time),
                label: Text(
                  _waktu == null
                      ? 'Pilih Waktu Penemuan'
                      : 'Waktu: ${_formatWaktu(_waktu!)}',
                ),
                onPressed: () async {
                  final picked =
                      await showTimePicker(context: context, initialTime: TimeOfDay.now());
                  if (picked != null) {
                    setState(() => _waktu = picked);
                  }
                },
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _simpanData,
                child: const Text('SIMPAN DATA'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
