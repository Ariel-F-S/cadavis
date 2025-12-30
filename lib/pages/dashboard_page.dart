import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/theme_helper.dart';
import 'input_page.dart';
import 'laporan_page.dart';

class DashboardPage extends StatefulWidget {
  final Function(bool) onThemeChanged;
  
  const DashboardPage({super.key, required this.onThemeChanged});

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
    if (hour < 11) {
      return 'Selamat Pagi';
    } else if (hour < 15) {
      return 'Selamat Siang';
    } else if (hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          // Toggle Dark Mode
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              children: [
                Icon(
                  Icons.light_mode,
                  size: 20,
                  color: _isDarkMode ? Colors.grey : Colors.amber,
                ),
                Switch(
                  value: _isDarkMode,
                  onChanged: (value) {
                    setState(() {
                      _isDarkMode = value;
                    });
                    widget.onThemeChanged(value);
                  },
                  activeColor: const Color(0xFF7C4DFF),
                ),
                Icon(
                  Icons.dark_mode,
                  size: 20,
                  color: _isDarkMode ? Colors.purple : Colors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header dengan sapaan
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
                        _getSapaan(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _namaPetugas,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Cadaver Detection System',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Menu Grid
                const Text(
                  'Menu Utama',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    _buildMenuCard(
                      icon: Icons.add_circle_outline,
                      title: 'Input Data',
                      subtitle: 'Jenazah',
                      color: const Color(0xFF7C4DFF),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => InputJenazahPage()),
                        );
                      },
                    ),
                    _buildMenuCard(
                      icon: Icons.download_outlined,
                      title: 'Export Data',
                      subtitle: 'Laporan',
                      color: const Color(0xFF00BFA5),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LaporanPage()),
                        );
                      },
                    ),
                    _buildMenuCard(
                      icon: Icons.bar_chart_rounded,
                      title: 'Statistik',
                      subtitle: 'Grafik',
                      color: const Color(0xFFFF6D00),
                      onTap: () {
<<<<<<< HEAD
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Fitur Statistik (Coming Soon)'),
                          ),
                        );
=======
                        Navigator.pushNamed(context, '/statistik');
>>>>>>> 5d6e09686732722101b74f8be3d0cc8fe89b9197
                      },
                    ),
                    _buildMenuCard(
                      icon: Icons.list_alt_rounded,
                      title: 'Riwayat',
                      subtitle: 'Data',
                      color: const Color(0xFF0091EA),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Fitur Riwayat (Coming Soon)'),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Quick Actions
                const Text(
                  'Aksi Cepat',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                _buildQuickActionCard(
                  icon: Icons.search_rounded,
                  title: 'Cari Data',
                  subtitle: 'Cari berdasarkan nama atau lokasi',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fitur Pencarian (Coming Soon)'),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                _buildQuickActionCard(
                  icon: Icons.backup_outlined,
                  title: 'Backup Data',
                  subtitle: 'Cadangkan semua data ke file',
                  onTap: () {
                    _showBackupDialog();
                  },
                ),

                const SizedBox(height: 12),

                _buildQuickActionCard(
                  icon: Icons.delete_sweep_outlined,
                  title: 'Hapus Data Lama',
                  subtitle: 'Bersihkan data lebih dari 1 tahun',
                  color: Colors.orange,
                  onTap: () {
                    _showDeleteOldDataDialog();
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

                const SizedBox(height: 20),
              ],
            ),
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
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
<<<<<<< HEAD
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
=======

>>>>>>> 5d6e09686732722101b74f8be3d0cc8fe89b9197
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

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup Data'),
        content: const Text(
          'Semua data akan di-export ke file Excel dan disimpan di folder Download.\n\nLanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur Backup (Coming Soon)'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C4DFF),
              foregroundColor: Colors.white,
            ),
            child: const Text('Backup'),
          ),
        ],
      ),
    );
  }

  void _showDeleteOldDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data Lama'),
        content: const Text(
          'Data yang lebih dari 1 tahun akan dihapus permanen.\n\n⚠️ Aksi ini tidak dapat dibatalkan!\n\nLanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur Hapus Data Lama (Coming Soon)'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
