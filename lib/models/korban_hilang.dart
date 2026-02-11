class KorbanHilang {
  final int? id;
  final String nama;
  final String jenisKelamin; // "Laki-laki" / "Perempuan"
  final String tanggalHilang;
  final String lokasi;
  final String status; // "Belum ditemukan" / "Sudah ditemukan"
  final String kondisi; // jika sudah ditemukan: "Masih hidup" / "Meninggal"
  final String ciriFisik;
  final String alamatRumah;
  final String fotoPath;

  KorbanHilang({
    this.id,
    required this.nama,
    required this.jenisKelamin,
    required this.tanggalHilang,
    required this.lokasi,
    required this.status,
    required this.kondisi,
    required this.ciriFisik,
    required this.alamatRumah,
    required this.fotoPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'jenis_kelamin': jenisKelamin,
      'tanggal_hilang': tanggalHilang,
      'lokasi': lokasi,
      'status': status,
      'kondisi': kondisi,
      'ciri_fisik': ciriFisik,
      'alamat_rumah': alamatRumah,
      'foto_path': fotoPath,
    };
  }

  factory KorbanHilang.fromMap(Map<String, dynamic> map) {
    return KorbanHilang(
      id: map['id'],
      nama: map['nama'],
      jenisKelamin: map['jenis_kelamin'],
      tanggalHilang: map['tanggal_hilang'],
      lokasi: map['lokasi'],
      status: map['status'],
      kondisi: map['kondisi'] ?? '',
      ciriFisik: map['ciri_fisik'] ?? '',
      alamatRumah: map['alamat_rumah'] ?? '',
      fotoPath: map['foto_path'] ?? '',
    );
  }

  KorbanHilang copyWith({
    int? id,
    String? nama,
    String? jenisKelamin,
    String? tanggalHilang,
    String? lokasi,
    String? status,
    String? kondisi,
    String? ciriFisik,
    String? alamatRumah,
    String? fotoPath,
  }) {
    return KorbanHilang(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      tanggalHilang: tanggalHilang ?? this.tanggalHilang,
      lokasi: lokasi ?? this.lokasi,
      status: status ?? this.status,
      kondisi: kondisi ?? this.kondisi,
      ciriFisik: ciriFisik ?? this.ciriFisik,
      alamatRumah: alamatRumah ?? this.alamatRumah,
      fotoPath: fotoPath ?? this.fotoPath,
    );
  }
}