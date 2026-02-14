import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
import 'pages/input_korban_hilang.dart';
import 'pages/menu_korban_hilang.dart';
import 'pages/edit_korban.dart';
import 'pages/detail_korban_hilang.dart';

import 'models/korban_hilang.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  // ❌ JANGAN ADA deleteDatabase DI SINI
  // Database akan dibuat otomatis oleh DatabaseHelper

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
            return MaterialPageRoute(
              builder: (_) => const InputJenazahPage(),
            );

          case '/laporan':
            return MaterialPageRoute(
              builder: (_) => const LaporanPage(),
            );

          case '/statistik':
            return MaterialPageRoute(
              builder: (_) => const StatistikPage(),
            );

          case '/riwayat':
            return MaterialPageRoute(
              builder: (_) => const RiwayatPage(),
            );

          case '/kelola':
            return MaterialPageRoute(
              builder: (_) => const KelolaDataPage(),
            );

          case '/backup':
            return MaterialPageRoute(
              builder: (_) => const BackupPage(),
            );

          case '/hapus-data-lama':
            return MaterialPageRoute(
              builder: (_) => const HapusDataLamaPage(),
            );

          case '/korban-hilang-input':
            return MaterialPageRoute(
              builder: (_) => const KorbanHilangInputPage(),
            );

          case '/menu-korban-hilang':
            return MaterialPageRoute(
              builder: (_) => const MenuKorbanHilangPage(),
            );

          case '/daftar-korban-hilang':
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            final role = args['role'] ?? 'pengguna';
            return MaterialPageRoute(
              builder: (_) => DaftarKorbanHilangPage(role: role),
            );

          case '/detail-korban':
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            final korban = args['korban'];
            final role = args['role'] ?? 'pengguna';

            if (korban is KorbanHilang) {
              return MaterialPageRoute(
                builder: (_) => DetailKorbanPage(
                  korban: korban,
                  role: role,
                ),
              );
            } else {
              return MaterialPageRoute(
                builder: (_) => const Scaffold(
                  body: Center(child: Text("Data korban tidak valid")),
                ),
              );
            }

          case '/edit-korban':
            final korban = settings.arguments;

            if (korban is KorbanHilang) {
              return MaterialPageRoute(
                builder: (_) => EditKorbanPage(korban: korban),
              );
            } else {
              return MaterialPageRoute(
                builder: (_) => const Scaffold(
                  body: Center(child: Text("Data korban tidak valid")),
                ),
              );
            }

          default:
            return null;
        }
      },
    );
  }
}