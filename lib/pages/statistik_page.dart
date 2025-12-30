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

  List<Jenazah> data = [];

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

    for (var j in list) {
      laki += j.jumlahLaki;
      perempuan += j.jumlahPerempuan;
    }

    setState(() {
      data = list;
      totalData = list.length;
      totalLaki = laki;
      totalPerempuan = perempuan;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Statistik Data Jenazah'),
          backgroundColor: const Color(0xFF7C4DFF),
          foregroundColor: Colors.white,
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
              _buildDailyChart(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Row(
      children: [
        _buildInfoBox(
          title: 'Total Data',
          value: totalData.toString(),
          color: const Color(0xFF7C4DFF),
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
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
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                title: 'Laki-laki',
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

  Widget _buildDailyChart() {
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
                      color: const Color(0xFF7C4DFF),
                      width: 18,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                );
              },
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      'D${value.toInt() + 1}',
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
            ),
            gridData: FlGridData(show: true),
            borderData: FlBorderData(show: false),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
