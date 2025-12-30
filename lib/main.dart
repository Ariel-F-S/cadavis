import 'package:flutter/material.dart';
import 'pages/splash_page.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/input_page.dart';
import 'pages/laporan_page.dart';
import 'pages/statistik_page.dart';
import 'pages/riwayat_page.dart';


void main() {
  runApp(const CadavisApp());
}

class CadavisApp extends StatelessWidget {
  const CadavisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadavis',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/input': (context) => const InputJenazahPage(),
        '/laporan': (context) => LaporanPage(),
        '/statistik': (context) => const StatistikPage(),
        '/riwayat': (context) => const RiwayatPage(),
      },
    );
  }
}