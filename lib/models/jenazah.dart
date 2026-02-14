class Jenazah {
  final int? id;
  final String namaPetugas;
  final String tanggalPenemuan;
  final String waktuPenemuan;
  final int jumlahLaki;
  final int jumlahPerempuan;
  final String lokasiPenemuan;
  final String? koordinatGPS;
  final String? gambarPath;
  final String? gambarLokasiPath;
  final String kondisiKorban;   // ✅ hanya kondisi, bukan status

  Jenazah({
  this.id,
  required this.namaPetugas,
  required this.tanggalPenemuan,
  required this.waktuPenemuan,
  required this.jumlahLaki,
  required this.jumlahPerempuan,
  required this.lokasiPenemuan,
  this.koordinatGPS,
  this.gambarPath,
  this.gambarLokasiPath,
  required this.kondisiKorban,
  });

  // ✅ copyWith untuk update data
  Jenazah copyWith({
    int? id,
    String? namaPetugas,
    String? tanggalPenemuan,
    String? waktuPenemuan,
    int? jumlahLaki,
    int? jumlahPerempuan,
    String? lokasiPenemuan,
    String? koordinatGPS,
    String? gambarPath,
    String? gambarLokasiPath,
    String? kondisiKorban,
  }) {
    return Jenazah(
      id: id ?? this.id,
      namaPetugas: namaPetugas ?? this.namaPetugas,
      tanggalPenemuan: tanggalPenemuan ?? this.tanggalPenemuan,
      waktuPenemuan: waktuPenemuan ?? this.waktuPenemuan,
      jumlahLaki: jumlahLaki ?? this.jumlahLaki,
      jumlahPerempuan: jumlahPerempuan ?? this.jumlahPerempuan,
      lokasiPenemuan: lokasiPenemuan ?? this.lokasiPenemuan,
      koordinatGPS: koordinatGPS ?? this.koordinatGPS,
      gambarPath: gambarPath ?? this.gambarPath,
      gambarLokasiPath: gambarLokasiPath ?? this.gambarLokasiPath,
      kondisiKorban: kondisiKorban ?? this.kondisiKorban,
    );
  }

  // ✅ simpan ke database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_petugas': namaPetugas,
      'tanggal_penemuan': tanggalPenemuan,
      'waktu_penemuan': waktuPenemuan,
      'jumlah_laki': jumlahLaki,
      'jumlah_perempuan': jumlahPerempuan,
      'lokasi_penemuan': lokasiPenemuan,
      'koordinat_gps': koordinatGPS,
      'gambar_path': gambarPath,
      'gambar_lokasi_path': gambarLokasiPath,
      'kondisi_korban': kondisiKorban,
    };
  }

  // ✅ load dari database
  factory Jenazah.fromMap(Map<String, dynamic> map) {
    return Jenazah(
      id: map['id'],
      namaPetugas: map['nama_petugas'] ?? '',
      tanggalPenemuan: map['tanggal_penemuan'] ?? '',
      waktuPenemuan: map['waktu_penemuan'] ?? '',
      jumlahLaki: map['jumlah_laki'] ?? 0,
      jumlahPerempuan: map['jumlah_perempuan'] ?? 0,
      lokasiPenemuan: map['lokasi_penemuan'] ?? '',
      koordinatGPS: map['koordinat_gps'],
      gambarPath: map['gambar_path'],
      gambarLokasiPath: map['gambar_lokasi_path'],
      kondisiKorban: map['kondisi_korban'] ?? '',
    );
  }
}
