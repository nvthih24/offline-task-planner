import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../home/widgets/statistics_card.dart';
import '../../task_manager/logic/task_provider.dart';
import '../widgets/gamification_card.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy màu nền động
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(
          "Thống Kê",
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
        ),
        centerTitle: false,
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          final tasks = provider.tasks;
          final int total = tasks.length;
          final int completed = tasks.where((t) => t.isCompleted).length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const GamificationCard(),
              const SizedBox(height: 24),
              // Tái sử dụng Widget biểu đồ cũ
              StatisticsCard(
                totalTasks: total,
                completedTasks: completed,
              ),

              const SizedBox(height: 24),

              // Có thể thêm các thống kê khác ở đây sau này
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Icon(Icons.emoji_events_rounded,
                        size: 40, color: Colors.orange),
                    const SizedBox(height: 10),
                    Text(
                      "Bạn đang làm rất tốt! 💪",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Hãy duy trì thói quen này nhé.",
                      style: TextStyle(color: textColor?.withOpacity(0.6)),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
