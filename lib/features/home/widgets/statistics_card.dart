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
    if (totalTasks == 0) return const SizedBox.shrink();

    final double percentage = (completedTasks / totalTasks) * 100;
    final int remaining = totalTasks - completedTasks;

    // --- LẤY MÀU ĐỘNG THEO THEME ---
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor;
    final textColor =
        Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7);

    // Màu nền vòng tròn biểu đồ (Sáng: Xám nhạt / Tối: Trắng mờ 10%)
    final chartBaseColor =
        isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFF1F5F9);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor, // SỬA: Nền động
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
                isDark ? 0.2 : 0.05), // Bóng tối hơn chút ở Dark Mode
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
                Text(
                  "Tiến độ hôm nay", // Dùng tiếng Việt cho đồng bộ
                  style: TextStyle(
                      fontSize: 14,
                      color: textColor, // SỬA: Màu chữ động
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  "${percentage.toInt()}%",
                  style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary),
                ),
                const SizedBox(height: 8),
                Text(
                  remaining == 0
                      ? "Xuất sắc! Đã xong hết."
                      : "Còn $remaining việc cần làm",
                  style: TextStyle(
                      fontSize: 14,
                      color: remaining == 0
                          ? Colors.green
                          : textColor, // SỬA: Màu chữ động
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // Biểu đồ tròn
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
                    startDegreeOffset: 270,
                    sections: [
                      // Phần đã làm
                      PieChartSectionData(
                        color: AppColors.primary,
                        value: completedTasks.toDouble(),
                        radius: 12,
                        showTitle: false,
                        title: "",
                      ),
                      // Phần chưa làm
                      PieChartSectionData(
                        color: chartBaseColor, // SỬA: Màu nền vòng tròn động
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
