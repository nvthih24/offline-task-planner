import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart'; // Bắt buộc phải có
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/task_model.dart';
import '../../task_manager/logic/task_provider.dart';
import 'highlight_text.dart';
import 'package:audioplayers/audioplayers.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final Function(bool?)? onCheckboxChanged;

  static final AudioPlayer _audioPlayer = AudioPlayer();

  const TaskTile({
    super.key,
    required this.task,
    this.onTap,
    this.onCheckboxChanged,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Lấy controller của Slidable một cách an toàn nhất
    // Có thể null nếu widget chưa được build xong hoặc không nằm trong Slidable
    final slidable = Slidable.of(context);

    final searchQuery = context.watch<TaskProvider>().searchQuery;
    final priorityColor = AppColors.getPriorityColor(task.colorIndex);
    final isDone = task.isCompleted;

    final Color cardColor = Theme.of(context).cardColor;
    final Color textColor = Theme.of(context).textTheme.bodyLarge!.color!;
    final Color subTextColor =
        Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.7);

    // Định nghĩa 2 trạng thái
    const BorderRadius roundedRadius = BorderRadius.all(Radius.circular(20));
    const BorderRadius squaredRightRadius =
        BorderRadius.horizontal(left: Radius.circular(20));

    return GestureDetector(
      onTap: onTap,
      // 2. Dùng AnimatedBuilder để lắng nghe từng pixel khi kéo
      child: AnimatedBuilder(
        animation: slidable?.animation ?? const AlwaysStoppedAnimation(0.0),
        builder: (context, child) {
          // 3. MẸO: Tăng tốc độ biến hình
          // Thay vì đợi kéo hết (value=1) mới vuông, ta cho vuông ngay khi kéo được 20%
          // Điều này giúp cảm giác "dính" vào nút xóa mượt hơn nhiều
          final double animationValue = slidable?.animation.value ?? 0;
          final double t = (animationValue * 5).clamp(0.0, 1.0);

          final currentRadius = BorderRadius.lerp(
            roundedRadius,
            squaredRightRadius,
            t,
          );

          return AnimatedContainer(
            duration: const Duration(
                milliseconds: 100), // Giảm duration để phản hồi nhanh hơn
            // LƯU Ý: Không được có margin ở đây (để khớp với nút xóa)
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: currentRadius, // Áp dụng góc bo động
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                  spreadRadius: 2,
                ),
              ],
              border: isDone
                  ? Border.all(color: Colors.grey.withOpacity(0.1))
                  : null,
            ),
            child: Row(
              children: [
                // Checkbox
                GestureDetector(
                  onTap: () {
                    onCheckboxChanged?.call(!isDone);
                    if (!isDone) {
                      try {
                        _audioPlayer.play(AssetSource('sounds/ting.mp3'));
                      } catch (e) {
                        print("Lỗi phát nhạc: $e");
                      }
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: isDone ? priorityColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDone ? priorityColor : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: isDone
                        ? const Icon(Icons.check, size: 18, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),

                // Nội dung text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HighlightText(
                        text: task.title,
                        query: searchQuery,
                        normalStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDone
                              ? subTextColor.withOpacity(0.5)
                              : textColor,
                          decoration:
                              isDone ? TextDecoration.lineThrough : null,
                          decorationColor: AppColors.textSecondary,
                        ),
                        highlightStyle: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (task.note.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        HighlightText(
                          text: task.note,
                          query: searchQuery,
                          normalStyle: TextStyle(
                            fontSize: 13,
                            color: isDone
                                ? subTextColor.withOpacity(0.5)
                                : textColor,
                            height: 1.4,
                          ),
                          highlightStyle: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),

                      // Footer (Giờ & Chấm màu)
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.access_time_rounded,
                                    size: 14, color: subTextColor),
                                const SizedBox(width: 6),
                                Text(
                                  '${DateFormat('HH:mm').format(task.startTime)} - ${DateFormat('HH:mm').format(task.endTime)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: subTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: priorityColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: priorityColor.withOpacity(0.4),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
