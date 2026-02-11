class Jenazah {
  final int? id;
  final String namaPetugas;
  final String tanggalPenemuan;
  final String waktuPenemuan;
  final int jumlahLaki;
  final int jumlahPerempuan;
  final int jumlahLakiHidup;
  final int jumlahPerempuanHidup;
  final String lokasiPenemuan;
  final String? koordinatGPS;
  final String? gambarPath;
  final String? gambarLokasiPath;
  final String statusKorban; // ✅ Tambahan field baru

  Jenazah({
    this.id,
    required this.namaPetugas,
    required this.tanggalPenemuan,
    required this.waktuPenemuan,
    required this.jumlahLaki,
    required this.jumlahPerempuan,
    this.jumlahLakiHidup = 0,
    this.jumlahPerempuanHidup = 0,
    required this.lokasiPenemuan,
    this.koordinatGPS,
    this.gambarPath,
    this.gambarLokasiPath,
    required this.statusKorban, // ✅ Wajib diisi
  });

  // Helper untuk hitung total
  int get totalKorban => jumlahLaki + jumlahPerempuan;
  int get totalHidup => jumlahLakiHidup + jumlahPerempuanHidup;
  int get totalMeninggal => totalKorban - totalHidup;

  Jenazah copyWith({
    int? id,
    String? namaPetugas,
    String? tanggalPenemuan,
    String? waktuPenemuan,
    int? jumlahLaki,
    int? jumlahPerempuan,
    int? jumlahLakiHidup,
    int? jumlahPerempuanHidup,
    String? lokasiPenemuan,
    String? koordinatGPS,
    String? gambarPath,
    String? gambarLokasiPath,
    String? statusKorban,
  }) {
    return Jenazah(
      id: id ?? this.id,
      namaPetugas: namaPetugas ?? this.namaPetugas,
      tanggalPenemuan: tanggalPenemuan ?? this.tanggalPenemuan,
      waktuPenemuan: waktuPenemuan ?? this.waktuPenemuan,
      jumlahLaki: jumlahLaki ?? this.jumlahLaki,
      jumlahPerempuan: jumlahPerempuan ?? this.jumlahPerempuan,
      jumlahLakiHidup: jumlahLakiHidup ?? this.jumlahLakiHidup,
      jumlahPerempuanHidup: jumlahPerempuanHidup ?? this.jumlahPerempuanHidup,
      lokasiPenemuan: lokasiPenemuan ?? this.lokasiPenemuan,
      koordinatGPS: koordinatGPS ?? this.koordinatGPS,
      gambarPath: gambarPath ?? this.gambarPath,
      gambarLokasiPath: gambarLokasiPath ?? this.gambarLokasiPath,
      statusKorban: statusKorban ?? this.statusKorban,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_petugas': namaPetugas,
      'tanggal_penemuan': tanggalPenemuan,
      'waktu_penemuan': waktuPenemuan,
      'jumlah_laki': jumlahLaki,
      'jumlah_perempuan': jumlahPerempuan,
      'jumlah_laki_hidup': jumlahLakiHidup,
      'jumlah_perempuan_hidup': jumlahPerempuanHidup,
      'lokasi_penemuan': lokasiPenemuan,
      'koordinat_gps': koordinatGPS,
      'gambar_path': gambarPath,
      'gambar_lokasi_path': gambarLokasiPath,
      'status_korban': statusKorban, // ✅ Tambahan
    };
  }

  factory Jenazah.fromMap(Map<String, dynamic> map) {
    return Jenazah(
      id: map['id'],
      namaPetugas: map['nama_petugas'],
      tanggalPenemuan: map['tanggal_penemuan'],
      waktuPenemuan: map['waktu_penemuan'],
      jumlahLaki: map['jumlah_laki'],
      jumlahPerempuan: map['jumlah_perempuan'],
      jumlahLakiHidup: map['jumlah_laki_hidup'] ?? 0,
      jumlahPerempuanHidup: map['jumlah_perempuan_hidup'] ?? 0,
      lokasiPenemuan: map['lokasi_penemuan'],
      koordinatGPS: map['koordinat_gps'],
      gambarPath: map['gambar_path'],
      gambarLokasiPath: map['gambar_lokasi_path'],
      statusKorban: map['status_korban'] ?? 'Meninggal', 
    );
  }
}
