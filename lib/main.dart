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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null);

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

      routes: {
        '/splash': (context) => SplashPage(
              onThemeChanged: _toggleTheme,
            ),

        '/login': (context) => LoginPage(
              onThemeChanged: _toggleTheme,
            ),

        '/dashboard': (context) => DashboardPage(
              onThemeChanged: _toggleTheme,
            ),

        '/input': (context) => const InputJenazahPage(),

        '/laporan': (context) => const LaporanPage(),

        '/statistik': (context) => const StatistikPage(),

        '/riwayat': (context) => const RiwayatPage(),

        '/kelola': (context) => const KelolaDataPage(),

        // ✅ SEKARANG BISA DI KLIK
        '/backup': (context) => const BackupPage(),

        '/hapus-data-lama': (context) => const HapusDataLamaPage(),
      },
    );
  }
}
