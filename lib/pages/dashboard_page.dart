import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/theme_helper.dart';
import 'input_page.dart';
import 'laporan_page.dart';
import 'backup_page.dart';
import 'hapus_data_lama_page.dart';
import 'daftar_korban_hilang.dart';

class DashboardPage extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final String role;

  const DashboardPage({
    super.key,
    required this.onThemeChanged,
    required this.role,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _namaPetugas = '';
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadTheme();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _namaPetugas = prefs.getString('nama_petugas') ?? 'Petugas';
    });
  }

  Future<void> _loadTheme() async {
    final isDark = await ThemeHelper.loadThemeMode();
    setState(() {
      _isDarkMode = isDark;
    });
  }

  String _getSapaan() {
  final hour = DateTime.now().hour;
  String waktu;
  if (hour < 11) waktu = 'Selamat Pagi';
  else if (hour < 15) waktu = 'Selamat Siang';
  else if (hour < 18) waktu = 'Selamat Sore';
  else waktu = 'Selamat Malam';

  return widget.role == 'admin'
      ? '$waktu'
      : '$waktu';
}
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
        Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              children: [
                Icon(Icons.light_mode,
                    size: 20, color: _isDarkMode ? Colors.grey : Colors.amber),
                Switch(
                  value: _isDarkMode,
                  onChanged: (value) {
                    setState(() {
                      _isDarkMode = value;
                    });
                    widget.onThemeChanged(value);
                  },
                  activeThumbColor: const Color(0xFF7C4DFF),
                ),
                Icon(Icons.dark_mode,
                    size: 20,
                    color: _isDarkMode ? Colors.purple : Colors.grey),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF9C7FFF), const Color(0xFF7C4DFF)]
                        : [const Color(0xFF7C4DFF), const Color(0xFF9C7FFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C4DFF).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_getSapaan()}, ${widget.role == 'admin' ? 'Admin' : 'Pengguna'}',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _namaPetugas,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cadaver Detection System',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.9), fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text('Menu Utama',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                // ✅ Input Jenazah untuk semua role
                _buildMenuCard(
                  icon: Icons.add_circle_outline,
                  title: 'Input Data',
                  subtitle: 'Jenazah',
                  color: const Color(0xFF7C4DFF),
                  onTap: () {
                    Navigator.pushNamed(context, '/input');
                  },
                ),
                _buildMenuCard(
                  icon: Icons.download_outlined,
                  title: 'Export Data',
                  subtitle: 'Laporan',
                  color: const Color(0xFF00BFA5),
                  onTap: () {
                    Navigator.pushNamed(context, '/laporan');
                  },
                ),
                _buildMenuCard(
                  icon: Icons.bar_chart_rounded,
                  title: 'Statistik',
                  subtitle: 'Grafik',
                  color: const Color(0xFFFF6D00),
                  onTap: () {
                    Navigator.pushNamed(context, '/statistik');
                  },
                ),
                _buildMenuCard(
                  icon: Icons.list_alt_rounded,
                  title: 'Riwayat',
                  subtitle: 'Data',
                  color: const Color(0xFF0091EA),
                  onTap: () {
                    Navigator.pushNamed(context, '/riwayat');
                  },
                ),
                // ✅ Korban Hilang untuk semua role
               _buildMenuCard(
                icon: Icons.people_alt,
                title: 'Korban Hilang',
                subtitle: 'Foto, ciri fisik, rumah',
                color: const Color(0xFFE91E63),
                onTap: () {
                  if (widget.role == 'admin') {
                    Navigator.pushNamed(context, '/menu-korban-hilang');
                  } else {
                    Navigator.pushNamed(context, '/daftar-korban-hilang',
                        arguments: {'role': widget.role});
                  }
                },
              ),
              ],
            ),
              const SizedBox(height: 24),
              const Text('Aksi Cepat',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              _buildQuickActionCard(
                icon: Icons.manage_accounts_rounded,
                title: 'Kelola Data',
                subtitle: 'Edit & hapus data jenazah',
                onTap: () {
                  Navigator.pushNamed(context, '/kelola');
                },
              ),
              const SizedBox(height: 12),
              _buildQuickActionCard(
                icon: Icons.backup_outlined,
                title: 'Backup Data',
                subtitle: 'Cadangkan semua data ke file',
                onTap: () {
                  Navigator.pushNamed(context, '/backup');
                },
              ),
              const SizedBox(height: 12),
              _buildQuickActionCard(
                icon: Icons.delete_sweep_outlined,
                title: 'Hapus Data Lama',
                subtitle: 'Bersihkan data secara permanen ',
                color: Colors.orange,
                onTap: () {
                  Navigator.pushNamed(context, '/hapus-data-lama');
                },
              ),
              const SizedBox(height: 12),
              _buildQuickActionCard(
                icon: Icons.logout,
                title: 'Keluar',
                subtitle: 'Logout dari aplikasi',
                color: Colors.red,
                onTap: () {
                  _showLogoutDialog();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(isDark ? 0.05 : 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
                        const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? color,
    required VoidCallback onTap,
  }) {
    final iconColor = color ?? const Color(0xFF7C4DFF);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(isDark ? 0.05 : 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}
