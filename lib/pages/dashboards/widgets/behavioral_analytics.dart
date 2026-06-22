import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BehavioralGraphCard extends StatelessWidget {
  const BehavioralGraphCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF111111),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), 
        side: const BorderSide(color: Color(0xFF39FF14), width: 0.5)
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AUDIENCE BEHAVIORAL VELOCITY', 
              style: TextStyle(color: Color(0xFF39FF14), fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 10),
            // LayoutBuilder gives us the constraints of the parent,
            // letting us size the chart precisely without overflowing.
            LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  height: constraints.maxHeight > 50 ? constraints.maxHeight - 40 : 120,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: const [FlSpot(0, 1), FlSpot(1, 3), FlSpot(2, 2.5), FlSpot(3, 5), FlSpot(4, 4.2), FlSpot(5, 6.8), FlSpot(6, 7.5)],
                          isCurved: true, color: const Color(0xFF39FF14), barWidth: 3
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
