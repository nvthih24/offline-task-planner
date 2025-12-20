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
    if (totalTasks == 0)
      return const SizedBox.shrink(); // Không có việc thì ẩn đi

    final double percentage = (completedTasks / totalTasks) * 100;
    final int remaining = totalTasks - completedTasks;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24), // Bo góc tròn trịa
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
          // 1. Thông số bên trái
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Tiến độ hôm nay",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${percentage.toInt()}%",
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  remaining == 0
                      ? "Xuất sắc! Đã xong hết."
                      : "Còn $remaining việc cần làm",
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        remaining == 0 ? Colors.green : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // 2. Biểu đồ tròn bên phải
          SizedBox(
            height: 100,
            width: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 35,
                    startDegreeOffset: 270, // Bắt đầu từ 12h
                    sections: [
                      // Phần đã làm
                      PieChartSectionData(
                        color: AppColors.primary,
                        value: completedTasks.toDouble(),
                        radius: 12,
                        showTitle: false,
                        title: "",
                      ),
                      // Phần chưa làm (nền xám)
                      PieChartSectionData(
                        color: const Color(0xFFF1F5F9),
                        value: (totalTasks - completedTasks).toDouble(),
                        radius: 12,
                        showTitle: false,
                        title: "",
                      ),
                    ],
                  ),
                ),
                // Icon ở giữa
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    percentage == 100
                        ? Icons.emoji_events_rounded
                        : Icons.trending_up_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
