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
    final accentColor = AppColors.getAccentColor(task.colorIndex);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12), // Bo góc vừa phải
          // Đổ bóng cực nhẹ tạo độ nổi tinh tế
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          // Viền bên trái để phân loại mức độ ưu tiên
          border: Border(left: BorderSide(color: accentColor, width: 4)),
        ),
        child: Row(
          children: [
            // 1. Checkbox cổ điển
            Transform.scale(
              scale: 1.1,
              child: Checkbox(
                value: task.isCompleted,
                activeColor: accentColor, // Màu tick trùng màu phân loại
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                onChanged: onCheckboxChanged,
              ),
            ),
            const SizedBox(width: 12),

            // 2. Nội dung
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: task.isCompleted
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Dòng thời gian & Ghi chú
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${DateFormat('HH:mm').format(task.startTime)} - ${DateFormat('HH:mm').format(task.endTime)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (task.note.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.sticky_note_2_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            task.note,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
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
