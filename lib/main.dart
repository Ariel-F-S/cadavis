import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'pages/splash_page.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/input_page.dart';
import 'pages/laporan_page.dart';
import 'pages/statistik_page.dart';
import 'pages/riwayat_page.dart';
import 'pages/kelola_data_page.dart';
import 'pages/backup_page.dart';
import 'pages/hapus_data_lama_page.dart';
import 'pages/daftar_korban_hilang.dart';
import 'pages/menu_korban_hilang.dart'; // ✅ Tambahkan import untuk admin

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  // ✅ Reset database lama (hapus cadavis.db)
  final dbPath = await getDatabasesPath();
  await deleteDatabase(join(dbPath, 'cadavis.db'));

  runApp(const CadavisApp());
}

class CadavisApp extends StatefulWidget {
  const CadavisApp({super.key});

  @override
  State<CadavisApp> createState() => _CadavisAppState();
}

class _CadavisAppState extends State<CadavisApp> {
  bool _isDarkMode = false;

  void _toggleTheme(bool value) {
    setState(() {
      _isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // 🔥 PENTING UNTUK DATE PICKER
      locale: const Locale('id', 'ID'),

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: const [
        Locale('id', 'ID'),
        Locale('en', 'US'),
      ],

      theme: ThemeData(
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),

      initialRoute: '/login',

      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/splash':
            return MaterialPageRoute(
              builder: (_) => SplashPage(onThemeChanged: _toggleTheme),
            );
          case '/login':
            return MaterialPageRoute(
              builder: (_) => LoginPage(onThemeChanged: _toggleTheme),
            );
          case '/dashboard':
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            final role = args['role'] ?? 'pengguna';
            return MaterialPageRoute(
              builder: (_) => DashboardPage(
                onThemeChanged: _toggleTheme,
                role: role,
              ),
            );
          case '/input':
            return MaterialPageRoute(builder: (_) => const InputJenazahPage());
          case '/laporan':
            return MaterialPageRoute(builder: (_) => const LaporanPage());
          case '/statistik':
            return MaterialPageRoute(builder: (_) => const StatistikPage());
          case '/riwayat':
            return MaterialPageRoute(builder: (_) => const RiwayatPage());
          case '/kelola':
            return MaterialPageRoute(builder: (_) => const KelolaDataPage());
          case '/backup':
            return MaterialPageRoute(builder: (_) => const BackupPage());
          case '/hapus-data-lama':
            return MaterialPageRoute(builder: (_) => const HapusDataLamaPage());
          case '/menu-korban-hilang': // ✅ route untuk admin
            return MaterialPageRoute(builder: (_) => const MenuKorbanHilangPage());
          case '/daftar-korban-hilang': // ✅ route untuk user
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            final role = args['role'] ?? 'pengguna';
            return MaterialPageRoute(
              builder: (_) => DaftarKorbanHilangPage(role: role),
            );
          default:
            return null;
        }
      },
    );
  }
}
