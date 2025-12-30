import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/jenazah.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'cadavis.db');

    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE jenazah (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama_petugas TEXT,
            tanggal_penemuan TEXT,
            waktu_penemuan TEXT,
            jumlah_laki INTEGER,
            jumlah_perempuan INTEGER,
            lokasi_penemuan TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertJenazah(Jenazah jenazah) async {
    final db = await database;
    return db.insert('jenazah', jenazah.toMap());
  }

  Future<List<Jenazah>> getByTanggal(String tanggal) async {
    final db = await database;
    final result = await db.query(
      'jenazah',
      where: 'tanggal_penemuan = ?',
      whereArgs: [tanggal],
    );

    return result.map((e) => Jenazah.fromMap(e)).toList();
  }
}
