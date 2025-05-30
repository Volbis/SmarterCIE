import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/energy_data.dart';

class EnergyChart extends StatelessWidget {
  final List<EnergyData> data;

  const EnergyChart({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(
        child: Text('Aucune donnée disponible', style: TextStyle(color: Colors.grey)),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text('${value.toInt()}W', style: TextStyle(fontSize: 10));
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() < data.length) {
                      final time = data[value.toInt()].timestamp;
                      return Text('${time.hour}:${time.minute.toString().padLeft(2, '0')}', 
                                 style: TextStyle(fontSize: 10));
                    }
                    return Text('');
                  },
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: true),
            lineBarsData: [
              LineChartBarData(
                spots: data.asMap().entries.map((entry) {
                  return FlSpot(entry.key.toDouble(), entry.value.power);
                }).toList(),
                isCurved: true,
                color: Colors.green,
                barWidth: 3,
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: Colors.green.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}