import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../mock_data.dart';

class ChartsModal extends StatefulWidget {
  final String title;
  final ChartData chartData;

  const ChartsModal({super.key, required this.title, required this.chartData});

  @override
  State<ChartsModal> createState() => _ChartsModalState();
}

class _ChartsModalState extends State<ChartsModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 500,
      decoration: BoxDecoration(
        color: theme.dialogBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Analytics: ${widget.title}",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  color: theme.iconTheme.color,
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            labelColor: theme.primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: theme.primaryColor,
            tabs: const [
              Tab(text: "Breakdown (Pie)", icon: Icon(Icons.pie_chart)),
              Tab(text: "History (Graph)", icon: Icon(Icons.show_chart)),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildPieChart(theme), _buildLineChart(theme)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(ThemeData theme) {
    final data = widget.chartData;
    // Basic color palette
    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.red,
      Colors.purple,
    ];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: List.generate(data.pieValues.length, (index) {
            final value = data.pieValues[index];
            final label =
                data.pieLabels.length > index ? data.pieLabels[index] : "";
            return PieChartSectionData(
              color: colors[index % colors.length],
              value: value,
              title: '$label\n${value.toInt()}%',
              radius: 60, // Bigger radius
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildLineChart(ThemeData theme) {
    final data = widget.chartData;

    // Convert Y-values to spots
    final spots =
        data.graphValues.asMap().entries.map((e) {
          return FlSpot(e.key.toDouble(), e.value);
        }).toList();

    // Find min/max for scaling (simple auto-scale)
    double maxY = 0;
    if (data.graphValues.isNotEmpty) {
      maxY =
          data.graphValues.reduce((curr, next) => curr > next ? curr : next) *
          1.2;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int idx = value.toInt();
                  if (idx >= 0 && idx < data.graphLabels.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        data.graphLabels[idx],
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return const Text('');
                },
                interval: 1,
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: theme.dividerColor),
          ),
          minX: 0,
          maxX: (data.graphValues.length - 1).toDouble(),
          minY: 0,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: theme.primaryColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: theme.primaryColor.withAlpha(51),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
