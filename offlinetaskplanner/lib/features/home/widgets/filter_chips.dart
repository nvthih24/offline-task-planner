import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../task_manager/logic/task_provider.dart';

// 1. Chip Lọc Ngày
class DateFilterChip extends StatelessWidget {
  const DateFilterChip({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final selectedDate = provider.filterDate;
    final isSelected = selectedDate != null;

    // Lấy màu động từ Theme
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyMedium?.color;

    return FilterChip(
      avatar: isSelected
          ? null
          : Icon(Icons.calendar_today_rounded,
              size: 16, color: textColor?.withOpacity(0.7)),
      label: Text(
        isSelected
            ? DateFormat('dd/MM/yyyy').format(selectedDate)
            : "Thời gian",
        style: TextStyle(
          color: isSelected ? Colors.white : textColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
      ),
      selected: isSelected,
      onSelected: (bool value) async {
        if (!value) {
          context.read<TaskProvider>().setFilterDate(null);
        } else {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
            builder: (context, child) {
              return Theme(
                data: theme.copyWith(
                  colorScheme: isSelected
                      ? const ColorScheme.dark(
                          primary: AppColors.primary) // Dark mode picker
                      : const ColorScheme.light(primary: AppColors.primary),
                ),
                child: child!,
              );
            },
          );
          if (picked != null && context.mounted) {
            context.read<TaskProvider>().setFilterDate(picked);
          }
        }
      },
      backgroundColor: cardColor,
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.white,
      side: BorderSide(
          color:
              isSelected ? Colors.transparent : Colors.grey.withOpacity(0.2)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}

// 2. Chip Lọc Trạng Thái
class StatusFilterChip extends StatelessWidget {
  final String label;
  final bool statusValue;

  const StatusFilterChip({
    super.key,
    required this.label,
    required this.statusValue,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final isSelected = provider.filterStatus == statusValue;
    final theme = Theme.of(context);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) =>
          context.read<TaskProvider>().toggleFilterStatus(statusValue),
      backgroundColor: theme.cardColor,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
      side: BorderSide(
          color:
              isSelected ? Colors.transparent : Colors.grey.withOpacity(0.2)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      checkmarkColor: Colors.white,
    );
  }
}

// 3. Chip Lọc Mức Độ Ưu Tiên
class PriorityFilterChip extends StatelessWidget {
  final String label;
  final int colorIndex;

  const PriorityFilterChip({
    super.key,
    required this.label,
    required this.colorIndex,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final isSelected = provider.filterPriority == colorIndex;
    final color = AppColors.getPriorityColor(colorIndex);
    final theme = Theme.of(context);

    return FilterChip(
      avatar: CircleAvatar(backgroundColor: color, radius: 6),
      label: Text(label),
      selected: isSelected,
      onSelected: (_) =>
          context.read<TaskProvider>().toggleFilterPriority(colorIndex),
      backgroundColor: theme.cardColor,

      // Khi chọn thì nền nhạt theo màu đó, không chọn thì nền trắng/xám
      selectedColor: color.withOpacity(0.2),

      labelStyle: TextStyle(
        color: isSelected ? color : theme.textTheme.bodyMedium?.color,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
      side: BorderSide(
        color: isSelected ? color : Colors.grey.withOpacity(0.2),
        width: isSelected ? 1.5 : 1,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      showCheckmark: false,
    );
  }
}

// 4. Nút Tròn (Helper)
class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final Color? color; // Để null sẽ lấy theo theme
  final VoidCallback onTap;

  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = color ?? theme.primaryColor;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: iconColor),
      ),
    );
  }
}
