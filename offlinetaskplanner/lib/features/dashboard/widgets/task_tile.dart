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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. Checkbox tùy chỉnh
          Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: task.isCompleted,
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              onChanged: onCheckboxChanged,
            ),
          ),
          const SizedBox(width: 12),

          // 2. Nội dung Task
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: task.isCompleted
                        ? AppColors.greyText
                        : AppColors.grey,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: AppColors.greyText,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${DateFormat('HH:mm').format(task.startTime)} - ${DateFormat('HH:mm').format(task.endTime)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.greyText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 3. Vạch màu phân loại (Trang trí cho đẹp)
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: _getTaskColor(task.colorIndex),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTaskColor(int index) {
    switch (index) {
      case 0:
        return AppColors.primary;
      case 1:
        return AppColors.orange;
      case 2:
        return AppColors.pink;
      default:
        return AppColors.primary;
    }
  }
}
