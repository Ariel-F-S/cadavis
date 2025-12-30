import 'package:flutter/material.dart';
import 'pages/splash_page.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/input_page.dart';
import 'pages/laporan_page.dart';
import 'pages/statistik_page.dart';
import 'pages/riwayat_page.dart';
import 'pages/kelola_data_page.dart';
void main() {
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

        '/laporan': (context) => LaporanPage(),

        '/statistik': (context) => const StatistikPage(),

        '/riwayat': (context) => const RiwayatPage(),
        '/kelola': (context) => const KelolaDataPage(),

      },
    );
  }
}
