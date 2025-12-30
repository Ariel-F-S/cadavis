import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/input_page.dart';
import 'pages/laporan_page.dart';
import 'pages/statistik_page.dart';

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
      ),
      home: LoginPage(
        onThemeChanged: _toggleTheme,
      ),
      routes: {
        '/splash': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/input': (context) => const InputJenazahPage(),
        '/laporan': (context) => LaporanPage(),
        '/statistik': (context) => const StatistikPage(),
      },
    );
  }
}
