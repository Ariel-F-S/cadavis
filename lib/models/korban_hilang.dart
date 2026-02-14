class KorbanHilang {
  final int? id;
  final String nama;
  final String jenisKelamin; // "Laki-laki" / "Perempuan"
  final String tanggalHilang;
  final String lokasi;
  final String status; // "Belum ditemukan" / "Sudah ditemukan"
  final String kondisi; // "Masih hidup" / "Meninggal"
  final String ciriFisik;
  final String alamatRumah;
  final String fotoPath;
  final String nomorTelepon;
  final int? jenazahId; // relasi ke tabel jenazah

  const KorbanHilang({
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
    required this.nomorTelepon,
    this.jenazahId,
  });

  // ===============================
  // TO MAP (UNTUK INSERT / UPDATE)
  // ===============================
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'jenis_kelamin': jenisKelamin,
      'tanggal_hilang': tanggalHilang,
      'lokasi': lokasi,
      'status': status,
      'kondisi': status == "Sudah ditemukan" ? kondisi : "",
      'ciri_fisik': ciriFisik,
      'alamat_rumah': alamatRumah,
      'foto_path': fotoPath,
      'nomor_telepon': nomorTelepon,
      'jenazah_id': jenazahId,
    };
  }

  // ===============================
  // FROM MAP (AMBIL DARI DATABASE)
  // ===============================
  factory KorbanHilang.fromMap(Map<String, dynamic> map) {
    return KorbanHilang(
      id: map['id'] as int?,
      nama: map['nama'] ?? '',
      jenisKelamin: map['jenis_kelamin'] ?? '',
      tanggalHilang: map['tanggal_hilang'] ?? '',
      lokasi: map['lokasi'] ?? '',
      status: map['status'] ?? 'Belum ditemukan',
      kondisi: map['kondisi'] ?? '',
      ciriFisik: map['ciri_fisik'] ?? '',
      alamatRumah: map['alamat_rumah'] ?? '',
      fotoPath: map['foto_path'] ?? '',
      nomorTelepon: map['nomor_telepon'] ?? '',
      jenazahId: map['jenazah_id'] as int?,
    );
  }

  // ===============================
  // COPY WITH (UNTUK EDIT DATA)
  // ===============================
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
    String? nomorTelepon,
    int? jenazahId,
  }) {
    return KorbanHilang(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      tanggalHilang: tanggalHilang ?? this.tanggalHilang,
      lokasi: lokasi ?? this.lokasi,
      status: status ?? this.status,
      kondisi: (status ?? this.status) == "Sudah ditemukan"
          ? (kondisi ?? this.kondisi)
          : "",
      ciriFisik: ciriFisik ?? this.ciriFisik,
      alamatRumah: alamatRumah ?? this.alamatRumah,
      fotoPath: fotoPath ?? this.fotoPath,
      nomorTelepon: nomorTelepon ?? this.nomorTelepon,
      jenazahId: jenazahId ?? this.jenazahId,
    );
  }
}
