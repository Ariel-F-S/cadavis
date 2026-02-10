import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../db/database_helper.dart';
import '../models/jenazah.dart';

class StatistikPage extends StatefulWidget {
  const StatistikPage({super.key});

  @override
  State<StatistikPage> createState() => _StatistikPageState();
}

class _StatistikPageState extends State<StatistikPage> {
  int totalData = 0;
  int totalLaki = 0;
  int totalPerempuan = 0;
  int totalHidup = 0;
  int totalMeninggal = 0;

  List<Jenazah> data = [];
  Map<String, int> korbanPerTanggal = {}; // ✅ Tambahan untuk line chart

  @override
  void initState() {
    super.initState();
    _loadStatistik();
  }

  Future<void> _loadStatistik() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('jenazah');

    final list = result.map((e) => Jenazah.fromMap(e)).toList();

    int laki = 0;
    int perempuan = 0;
    int hidup = 0;
    int meninggal = 0;
    final Map<String, int> perTanggal = {};

    for (var j in list) {
      laki += j.jumlahLaki;
      perempuan += j.jumlahPerempuan;

      if (j.statusKorban == 'Hidup') {
        hidup += j.jumlahLaki + j.jumlahPerempuan;
      } else {
        meninggal += j.jumlahLaki + j.jumlahPerempuan;
      }

      // Hitung jumlah korban per tanggal
      perTanggal[j.tanggalPenemuan] =
          (perTanggal[j.tanggalPenemuan] ?? 0) + j.jumlahLaki + j.jumlahPerempuan;
    }

    setState(() {
      data = list;
      totalData = list.length;
      totalLaki = laki;
      totalPerempuan = perempuan;
      totalHidup = hidup;
      totalMeninggal = meninggal;
      korbanPerTanggal = perTanggal;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik Data Jenazah'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadStatistik,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 24),
            _buildGenderChart(),
            const SizedBox(height: 24),
            _buildStatusChart(),
            const SizedBox(height: 24),
            _buildDailyChart(),
            const SizedBox(height: 24),
            _buildLineChart(), // ✅ Tambahan line chart tren waktu
          ],
        ),
      ),
    );
  }

  // ================= SUMMARY CARD =================
  Widget _buildSummaryCard() {
    return Row(
      children: [
        _buildInfoBox(
          title: 'Total Data',
          value: totalData.toString(),
          color: Colors.deepPurple,
          icon: Icons.storage,
        ),
        const SizedBox(width: 12),
        _buildInfoBox(
          title: 'Laki-laki',
          value: totalLaki.toString(),
          color: Colors.blue,
          icon: Icons.male,
        ),
        const SizedBox(width: 12),
        _buildInfoBox(
          title: 'Perempuan',
          value: totalPerempuan.toString(),
          color: Colors.pink,
          icon: Icons.female,
        ),
      ],
    );
  }

  Widget _buildInfoBox({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                theme.brightness == Brightness.dark ? 0.4 : 0.15,
              ),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // ================= PIE CHART GENDER =================
  Widget _buildGenderChart() {
    return _buildCard(
      title: 'Komposisi Jenazah',
      child: SizedBox(
        height: 220,
        child: PieChart(
          PieChartData(
            sectionsSpace: 4,
            centerSpaceRadius: 40,
            sections: [
              PieChartSectionData(
                value: totalLaki.toDouble(),
                title: 'Laki',
                color: Colors.blue,
                radius: 60,
                titleStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              PieChartSectionData(
                value: totalPerempuan.toDouble(),
                title: 'Perempuan',
                color: Colors.pink,
                radius: 60,
                titleStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= PIE CHART STATUS =================
  Widget _buildStatusChart() {
    return _buildCard(
      title: 'Status Korban',
      child: SizedBox(
        height: 220,
        child: PieChart(
          PieChartData(
            sectionsSpace: 4,
            centerSpaceRadius: 40,
            sections: [
              PieChartSectionData(
                value: totalHidup.toDouble(),
                title: 'Hidup',
                color: Colors.green,
                radius: 60,
                titleStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              PieChartSectionData(
                value: totalMeninggal.toDouble(),
                title: 'Meninggal',
                color: Colors.grey,
                radius: 60,
                titleStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= BAR CHART =================
  Widget _buildDailyChart() {
    final colorScheme = Theme.of(context).colorScheme;

    return _buildCard(
      title: 'Data Per Entri',
      child: SizedBox(
        height: 260,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            barGroups: List.generate(
              data.length > 7 ? 7 : data.length,
              (index) {
                final j = data[index];
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: (j.jumlahLaki + j.jumlahPerempuan).toDouble(),
                      color: colorScheme.primary,
                      width: 18,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                );
              },
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        fontSize: 10,
                        color: colorScheme.onSurface,
                      ),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      'D${value.toInt() + 1}',
                      style: TextStyle(
                        fontSize: 10,
                        color: colorScheme.onSurface,
                      ),
                    );
                  },
                ),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) => FlLine(
                color: colorScheme.onSurface.withOpacity(0.15),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
          ),
        ),
      ),
    );
  }

  // ================= LINE CHART =================
  Widget _buildLineChart() {
    final colorScheme = Theme.of(context).colorScheme;
    final entries = korbanPerTanggal.entries.toList();

    return _buildCard(
      title: 'Tren Korban per Tanggal',
      child: SizedBox(
        height: 260,
        child: LineChart(
          LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: List.generate(entries.length, (i) {
                  return FlSpot(i.toDouble(), entries[i].value.toDouble());
                }),
                isCurved: true,
                color: colorScheme.primary,
                barWidth: 3,
                dotData: FlDotData(show: true),
              ),
            ],
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        fontSize: 10,
                        color: colorScheme.onSurface,
                      ),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < entries.length) {
                      return Text(
                        entries[index].key,
                        style: TextStyle(
                          fontSize: 10,
                          color: colorScheme.onSurface,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) => FlLine(
                color: colorScheme.onSurface.withOpacity(0.15),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
          ),
        ),
      ),
    );
  }

  // ================= CARD WRAPPER =================
  Widget _buildCard({
    required String title,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              theme.brightness == Brightness.dark ? 0.4 : 0.1,
            ),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
