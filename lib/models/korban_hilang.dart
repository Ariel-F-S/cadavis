class KorbanHilang {
  final int? id;
  final String nama;
  final String jenisKelamin; // "Laki-laki" / "Perempuan"
  final String tanggalHilang;
  final String lokasi;
  final String status; // contoh: "Belum ditemukan", "Ditemukan selamat", "Meninggal"

  KorbanHilang({
    this.id,
    required this.nama,
    required this.jenisKelamin,
    required this.tanggalHilang,
    required this.lokasi,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'jenis_kelamin': jenisKelamin,
      'tanggal_hilang': tanggalHilang,
      'lokasi': lokasi,
      'status': status,
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
    );
  }

  KorbanHilang copyWith({
    int? id,
    String? nama,
    String? jenisKelamin,
    String? tanggalHilang,
    String? lokasi,
    String? status,
  }) {
    return KorbanHilang(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      tanggalHilang: tanggalHilang ?? this.tanggalHilang,
      lokasi: lokasi ?? this.lokasi,
      status: status ?? this.status,
    );
  }
}
