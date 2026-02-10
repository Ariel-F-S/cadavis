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
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabel Users
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT,
        role TEXT
      )
    ''');

    // Tabel Jenazah
    await db.execute('''
      CREATE TABLE jenazah (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT,
        jenis_kelamin TEXT,
        umur INTEGER,
        status TEXT,
        tanggal_masuk TEXT
      )
    ''');

    // Tabel Korban Hilang
    await db.execute('''
      CREATE TABLE korban_hilang (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT,
        jenis_kelamin TEXT,
        tanggal_hilang TEXT,
        lokasi TEXT,
        status TEXT
      )
    ''');

    // ✅ Insert default admin user
    await db.insert('users', {
      'username': 'admin',
      'password': 'admin123',
      'role': 'admin',
    });
  }

  // ================== CRUD USER ==================
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
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

  // ================== CRUD JENAZAH ==================
  Future<int> insertJenazah(Jenazah jenazah) async {
    final db = await database;
    return await db.insert('jenazah', jenazah.toMap());
  }

  Future<List<Jenazah>> getAllJenazah() async {
    final db = await database;
    final result = await db.query('jenazah', orderBy: 'tanggal_masuk DESC');
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
  // ================== CRUD KORBAN HILANG ==================
  Future<int> insertKorbanHilang(KorbanHilang korban) async {
    final db = await database;
    return await db.insert('korban_hilang', korban.toMap());
  }

  Future<List<KorbanHilang>> getAllKorbanHilang() async {
    final db = await database;
    final result = await db.query(
      'korban_hilang',
      orderBy: 'tanggal_hilang DESC',
    );
    return result.map((e) => KorbanHilang.fromMap(e)).toList();
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

  // ================== Utility ==================
  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('users');
    await db.delete('jenazah');
    await db.delete('korban_hilang');
  }
}