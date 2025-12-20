import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class StatisticsCard extends StatelessWidget {
  final int totalTasks;
  final int completedTasks;

  const StatisticsCard({
    super.key,
    required this.totalTasks,
    required this.completedTasks,
  });

  @override
  Widget build(BuildContext context) {
    // If no tasks, show nothing (safe mode)
    if (totalTasks == 0) return const SizedBox.shrink();

    final double percentage = (completedTasks / totalTasks) * 100;
    final int remaining = totalTasks - completedTasks;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Progress",
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text("${percentage.toInt()}%",
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary)),
                const SizedBox(height: 5),
                Text(remaining == 0 ? "Done!" : "$remaining left",
                    style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
          SizedBox(
            height: 80,
            width: 80,
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 25,
                sections: [
                  PieChartSectionData(
                    color: AppColors.primary,
                    value: completedTasks.toDouble(),
                    radius: 10,
                    showTitle: false,
                    title: "", // Required for older versions
                  ),
                  PieChartSectionData(
                    color: const Color(0xFFF1F5F9),
                    value: (totalTasks - completedTasks).toDouble(),
                    radius: 10,
                    showTitle: false,
                    title: "",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
