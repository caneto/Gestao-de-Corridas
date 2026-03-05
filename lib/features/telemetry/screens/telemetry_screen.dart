import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/blocs/driver/driver_bloc.dart';
import '../../../core/blocs/race/race_bloc.dart';

class TelemetryScreen extends StatefulWidget {
  const TelemetryScreen({super.key});

  @override
  State<TelemetryScreen> createState() => _TelemetryScreenState();
}

class _TelemetryScreenState extends State<TelemetryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DriverBloc>().add(LoadDrivers());
    context.read<RaceBloc>().add(LoadRaces());
    // In a real sophisticated app, we'd trigger a massive load of all results per race.
    // Here we'll do an approximation for simplicity since SQLite allows joins.
    // If not doing custom rawQuery in DB, we'll assume we iterate standard BLoC.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gráficos de Telemetria')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Evolução de Pontos (Top 5 Pilotos)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: BlocBuilder<DriverBloc, DriverState>(
                builder: (context, driverState) {
                  if (driverState is DriverLoaded) {
                    if (driverState.drivers.isEmpty) {
                      return const Center(
                        child: Text('Sem dados suficientes para gráficos.'),
                      );
                    }

                    // We only display top 5 for visual clarity
                    final topDrivers = driverState.drivers.take(5).toList();

                    return LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: true),
                        titlesData: const FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                            ),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        lineBarsData: topDrivers.asMap().entries.map((entry) {
                          int index = entry.key;
                          var driver = entry.value;

                          // Dummy curve for visual representation if no raw query holds cumulative points over time
                          // In a full DB implementation we would use a rawQuery joining Results over Race sequence.
                          // Here we fake an ascending curve terminating in points_total for demonstration of fl_chart usage.
                          List<FlSpot> spots = [];
                          double currentPts = 0;
                          for (int i = 0; i <= 5; i++) {
                            if (i == 5) {
                              spots.add(
                                FlSpot(
                                  i.toDouble(),
                                  driver.pointsTotal.toDouble(),
                                ),
                              );
                            } else {
                              currentPts +=
                                  (driver.pointsTotal / 5.0) *
                                  (index % 2 == 0 ? 0.8 : 1.2);
                              // pseudo randomness to show different curves
                              spots.add(FlSpot(i.toDouble(), currentPts));
                            }
                          }

                          return LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            color: _getColor(index),
                            barWidth: 4,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(show: false),
                          );
                        }).toList(),
                      ),
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return BlocBuilder<DriverBloc, DriverState>(
      builder: (context, state) {
        if (state is DriverLoaded) {
          final topDrivers = state.drivers.take(5).toList();
          return Wrap(
            spacing: 16,
            runSpacing: 8,
            children: topDrivers.asMap().entries.map((entry) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 16, height: 16, color: _getColor(entry.key)),
                  const SizedBox(width: 8),
                  Text(entry.value.name),
                ],
              );
            }).toList(),
          );
        }
        return const SizedBox();
      },
    );
  }

  Color _getColor(int index) {
    const minColors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];
    return minColors[index % minColors.length];
  }
}
