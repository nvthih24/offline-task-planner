import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../task_manager/logic/task_provider.dart';

class GamificationCard extends StatelessWidget {
  const GamificationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Hàng trên: Streak và Danh hiệu
          Row(
            children: [
              // 1. Cục Streak (Ngọn lửa)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department_rounded,
                        color: Colors.orange, size: 24),
                    const SizedBox(width: 6),
                    Text(
                      "${provider.streak} ngày",
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // 2. Level Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "LV.${provider.level}",
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Hàng giữa: Tên danh hiệu và XP
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                provider.userTitle,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color),
              ),
              Text(
                "${provider.xp % 100}/100 XP",
                style: TextStyle(
                    fontSize: 13,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Hàng dưới: Thanh tiến độ XP
          LinearPercentIndicator(
            lineHeight: 12.0,
            percent: provider.levelProgress,
            backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
            progressColor: AppColors.primary,
            barRadius: const Radius.circular(10),
            padding: EdgeInsets.zero,
            animation: true,
            animationDuration: 1000,
          ),

          const SizedBox(height: 8),

          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "Thêm ${provider.xpToNextLevel} XP để lên cấp",
              style: TextStyle(
                  fontSize: 11,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4),
                  fontStyle: FontStyle.italic),
            ),
          )
        ],
      ),
    );
  }
}
