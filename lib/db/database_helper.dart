import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/korban_hilang.dart';
import '../models/user.dart';
import '../models/jenazah.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase('cadavis.db');
    return _database!;
  }

  Future<Database> _initDatabase(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onConfigure: (db) async {
        // 🔥 WAJIB supaya foreign key aktif
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // ================= CREATE =================
  Future<void> _onCreate(Database db, int version) async {
    // USERS
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT,
        role TEXT
      )
    ''');

    await db.insert('users', {
      'username': 'admin',
      'password': 'admin123',
      'role': 'admin',
    });

    await db.insert('users', {
      'username': 'user',
      'password': 'user123',
      'role': 'pengguna',
    });

    // JENAZAH
    await db.execute('''
      CREATE TABLE jenazah (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_petugas TEXT,
        tanggal_penemuan TEXT,
        waktu_penemuan TEXT,
        jumlah_laki INTEGER,
        jumlah_perempuan INTEGER,
        jumlah_laki_hidup INTEGER,
        jumlah_perempuan_hidup INTEGER,
        lokasi_penemuan TEXT,
        koordinat_gps TEXT,
        gambar_path TEXT,
        gambar_lokasi_path TEXT,
        kondisi_korban TEXT
      )
    ''');

    // KORBAN HILANG
    await db.execute('''
      CREATE TABLE korban_hilang (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT,
        jenis_kelamin TEXT,
        tanggal_hilang TEXT,
        lokasi TEXT,
        status TEXT,
        kondisi TEXT,
        ciri_fisik TEXT,
        alamat_rumah TEXT,
        foto_path TEXT,
        nomor_telepon TEXT,
        jenazah_id INTEGER,
        FOREIGN KEY (jenazah_id) REFERENCES jenazah (id) ON DELETE CASCADE
      )
    ''');

    // 🔥 INDEX UNTUK PERFORMA JOIN
    await db.execute(
      'CREATE INDEX idx_korban_jenazah_id ON korban_hilang (jenazah_id)'
    );
  }

  // ================= UPGRADE =================
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute(
        "ALTER TABLE jenazah ADD COLUMN kondisi_korban TEXT"
      );
    }
  }

  // ================= CRUD USER =================
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<User?> getUser(String username, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  Future<List<User>> getAllUsers() async {
    final db = await database;
    final result = await db.query('users');
    return result.map((e) => User.fromMap(e)).toList();
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // ================= CRUD JENAZAH =================
  Future<int> insertJenazah(Jenazah jenazah) async {
    final db = await database;
    return await db.insert(
      'jenazah',
      jenazah.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Jenazah>> getAllJenazah() async {
    final db = await database;
    final result = await db.query(
      'jenazah',
      orderBy: 'tanggal_penemuan DESC',
    );
    return result.map((e) => Jenazah.fromMap(e)).toList();
  }

  Future<int> updateJenazah(Jenazah jenazah) async {
    final db = await database;
    return await db.update(
      'jenazah',
      jenazah.toMap(),
      where: 'id = ?',
      whereArgs: [jenazah.id],
    );
  }

  Future<int> deleteJenazah(int id) async {
    final db = await database;
    return await db.delete('jenazah', where: 'id = ?', whereArgs: [id]);
  }

  // ================= CRUD KORBAN HILANG =================
  Future<int> insertKorbanHilang(KorbanHilang korban) async {
    final db = await database;
    return await db.insert(
      'korban_hilang',
      korban.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateKorbanHilang(KorbanHilang korban) async {
    final db = await database;
    return await db.update(
      'korban_hilang',
      korban.toMap(),
      where: 'id = ?',
      whereArgs: [korban.id],
    );
  }

  Future<int> deleteKorbanHilang(int id) async {
    final db = await database;
    return await db.delete(
      'korban_hilang',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<KorbanHilang>> getAllKorbanHilang() async {
    final db = await database;
    final result = await db.query(
      'korban_hilang',
      orderBy: 'tanggal_hilang DESC',
    );
    return result.map((e) => KorbanHilang.fromMap(e)).toList();
  }

  // ================= JOIN =================
 Future<List<Map<String, dynamic>>> getJenazahWithStatus() async {
  final db = await instance.database;

  final result = await db.rawQuery('''
    SELECT 
      j.*,
      COALESCE(k.status, '-') AS status,
      COALESCE(k.kondisi, '-') AS kondisi
    FROM jenazah j
    LEFT JOIN korban_hilang k
      ON k.jenazah_id = j.id
  ''');

  return result;
}

  // ================= CLEAR =================
  Future<void> clearDatabase() async {
    final db = await database;

    await db.delete('korban_hilang');
    await db.delete('jenazah');
    await db.delete('users');

    // Reset autoincrement (optional tapi bersih)
    await db.execute("DELETE FROM sqlite_sequence");
  }

  // ================= CLOSE =================
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}