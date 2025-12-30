class Jenazah {
  final int? id;
  final String namaPetugas;
  final String tanggalPenemuan;
  final String waktuPenemuan;
  final int jumlahLaki;
  final int jumlahPerempuan;
  final String lokasiPenemuan;
  final String? gambarPath;

  Jenazah({
    this.id,
    required this.namaPetugas,
    required this.tanggalPenemuan,
    required this.waktuPenemuan,
    required this.jumlahLaki,
    required this.jumlahPerempuan,
    required this.lokasiPenemuan,
    this.gambarPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_petugas': namaPetugas,
      'tanggal_penemuan': tanggalPenemuan,
      'waktu_penemuan': waktuPenemuan,
      'jumlah_laki': jumlahLaki,
      'jumlah_perempuan': jumlahPerempuan,
      'lokasi_penemuan': lokasiPenemuan,
      'gambar_path': gambarPath, 
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
      lokasiPenemuan: map['lokasi_penemuan'],
      gambarPath: map['gambar_path'], 
    );
  }
}