import 'package:flutter/material.dart';

class MenuKorbanHilangPage extends StatelessWidget {
  const MenuKorbanHilangPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Korban Hilang'),
        backgroundColor: Color(0xFFE91E63),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people_alt,
                size: 80,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Fitur Korban Hilang',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Input Data Korban Hilang'),
              onPressed: () {
                Navigator.pushNamed(context, '/korban-hilang-input');
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              icon: const Icon(Icons.list_alt),
              label: const Text('Cek Korban Hilang'),
              onPressed: () {
                Navigator.pushNamed(context, '/daftar-korban-hilang',
                    arguments: {'role': 'admin'});
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
