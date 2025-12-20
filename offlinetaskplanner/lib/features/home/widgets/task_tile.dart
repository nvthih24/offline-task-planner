import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/task_model.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final Function(bool?)? onCheckboxChanged;

  const TaskTile({
    super.key,
    required this.task,
    this.onTap,
    this.onCheckboxChanged,
  });

  @override
  Widget build(BuildContext context) {
    final priorityColor = AppColors.getPriorityColor(task.colorIndex);
    final isDone = task.isCompleted;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 300,
        ), // Hiệu ứng chuyển động mượt
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(20), // Bo góc mềm mại
          // Hiệu ứng bóng mờ cao cấp (Soft Shadow)
          boxShadow: [
            BoxShadow(
              color: Colors.blueGrey.withOpacity(
                0.08,
              ), // Bóng màu xám xanh rất nhạt
              blurRadius: 15,
              offset: const Offset(0, 5),
              spreadRadius: 2,
            ),
          ],
          // Viền mờ khi hoàn thành để card chìm xuống
          border: isDone
              ? Border.all(color: Colors.grey.withOpacity(0.1))
              : null,
        ),
        child: Row(
          children: [
            // 1. Checkbox cách điệu
            GestureDetector(
              onTap: () => onCheckboxChanged?.call(!isDone),
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

            // 2. Nội dung chính
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700, // Chữ đậm vừa phải
                      color: isDone
                          ? AppColors.textSecondary.withOpacity(0.5)
                          : AppColors.textPrimary,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      decorationColor: AppColors.textSecondary,
                    ),
                  ),

                  if (task.note.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      task.note,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary.withOpacity(0.8),
                        height: 1.4,
                      ),
                    ),
                  ],

                  const SizedBox(height: 10),

                  // 3. Footer: Giờ và Tag màu
                  Row(
                    children: [
                      // Badge thời gian
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.scaffoldBackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${DateFormat('HH:mm').format(task.startTime)} - ${DateFormat('HH:mm').format(task.endTime)}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Dấu chấm phân loại màu
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
      ),
    );
  }
}
