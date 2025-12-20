import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/task_model.dart';
import '../../task_manager/logic/task_provider.dart';

class AddTaskSheet extends StatefulWidget {
  final Task? task;

  const AddTaskSheet({super.key, this.task});

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  late TextEditingController _titleController;
  late TextEditingController _noteController;

  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late int _selectedColorIndex;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      // Chế độ Sửa
      _titleController = TextEditingController(text: widget.task!.title);
      _noteController = TextEditingController(text: widget.task!.note);
      _selectedDate = widget.task!.date;
      _startTime = TimeOfDay.fromDateTime(widget.task!.startTime);
      _endTime = TimeOfDay.fromDateTime(widget.task!.endTime);
      _selectedColorIndex = widget.task!.colorIndex;
    } else {
      // Chế độ Thêm mới
      _titleController = TextEditingController();
      _noteController = TextEditingController();
      _selectedDate = DateTime.now();
      _startTime = TimeOfDay.now();

      final now = DateTime.now();
      final endDateTime = now.add(const Duration(minutes: 30));
      _endTime = TimeOfDay.fromDateTime(endDateTime);

      _selectedColorIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.task != null;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    // --- LẤY MÀU ĐỘNG TỪ THEME ---
    final theme = Theme.of(context);
    final cardColor = theme.cardColor; // Nền chính của Sheet
    final inputBgColor =
        theme.scaffoldBackgroundColor; // Nền của ô input (Tương phản)
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final hintColor = theme.textTheme.bodyMedium?.color?.withOpacity(0.5);

    return Container(
      padding: EdgeInsets.only(
          left: 24, right: 24, top: 24, bottom: bottomInset + 24),
      decoration: BoxDecoration(
        color: cardColor, // SỬA: Nền động
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Thanh nắm kéo (Handle bar)
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey
                      .withOpacity(0.3), // Màu trung tính cho cả 2 mode
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 2. Tiêu đề
            Text(
              isEdit ? "Cập Nhật Công Việc" : "Thêm Công Việc Mới",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor, // SỬA: Màu chữ động
              ),
            ),
            const SizedBox(height: 24),

            // 3. Ô nhập Tiêu đề
            _buildInputField(
              controller: _titleController,
              hint: "Bạn định làm gì?",
              icon: Icons.edit_note_rounded,
              autoFocus: true,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              bgColor: inputBgColor, // Truyền màu
              textColor: textColor,
              hintColor: hintColor,
            ),
            const SizedBox(height: 16),

            // 4. Ô nhập Ghi chú
            _buildInputField(
              controller: _noteController,
              hint: "Thêm ghi chú...",
              icon: Icons.notes_rounded,
              maxLines: 3,
              fontSize: 15,
              bgColor: inputBgColor,
              textColor: textColor,
              hintColor: hintColor,
            ),
            const SizedBox(height: 24),

            // 5. Chọn Ngày & Giờ
            Row(
              children: [
                Expanded(
                  child: _buildInfoChip(
                    label: DateFormat('d MMM').format(_selectedDate),
                    icon: Icons.calendar_today_rounded,
                    onTap: _pickDate,
                    bgColor: inputBgColor,
                    textColor: textColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoChip(
                    label:
                        "${_startTime.format(context)} - ${_endTime.format(context)}",
                    icon: Icons.access_time_rounded,
                    onTap: _pickTime,
                    bgColor: inputBgColor,
                    textColor: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 6. Chọn Mức độ ưu tiên
            Text(
              "Mức độ ưu tiên",
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: hintColor, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Wrap(
                  spacing: 12,
                  children: List.generate(4, (index) {
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColorIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: _selectedColorIndex == index
                                  ? AppColors.getPriorityColor(index)
                                  : Colors.transparent,
                              width: 2),
                        ),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.getPriorityColor(index),
                            shape: BoxShape.circle,
                          ),
                          child: _selectedColorIndex == index
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 20)
                              : null,
                        ),
                      ),
                    );
                  }),
                ),

                // 7. Nút Lưu
                ElevatedButton.icon(
                  onPressed: _saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.send_rounded, size: 20),
                  label: Text(
                    isEdit ? "Lưu lại" : "Tạo việc",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget con: Ô nhập liệu (Đã tùy biến màu sắc)
  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
    Color? hintColor,
    int maxLines = 1,
    bool autoFocus = false,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor, // Màu nền ô nhập liệu (khác với nền sheet)
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        autofocus: autoFocus,
        maxLines: maxLines,
        style: TextStyle(
            color: textColor, fontSize: fontSize, fontWeight: fontWeight),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: hintColor),
          prefixIcon: Icon(icon, color: hintColor),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }

  // Widget con: Chip thông tin (Ngày/Giờ)
  Widget _buildInfoChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required Color bgColor,
    required Color textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // 1. Giảm padding ngang từ 16 xuống 12 để tiết kiệm diện tích
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.transparent),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 6), // Giảm khoảng cách icon và chữ

            // 2. Bọc Text trong Flexible để nó biết tự co lại
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    fontSize:
                        13 // 3. Giảm size chữ chút xíu (14 -> 13) cho an toàn
                    ),
                overflow: TextOverflow.ellipsis, // Cắt bớt nếu dài quá
                maxLines: 1, // Chỉ hiện 1 dòng
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickDate() async {
    // Không dùng builder ép theme nữa để nó tự động theo App Theme
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _pickTime() async {
    TimeOfDay? start =
        await showTimePicker(context: context, initialTime: _startTime);
    if (start != null) {
      setState(() => _startTime = start);
      if (mounted) {
        setState(() {
          final now = DateTime.now();
          final dtStart =
              DateTime(now.year, now.month, now.day, start.hour, start.minute);
          final dtEnd = dtStart.add(const Duration(hours: 1));
          _endTime = TimeOfDay.fromDateTime(dtEnd);
        });
      }
    }
  }

  void _saveTask() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Đừng quên nhập tên công việc nhé!"),
          backgroundColor: AppColors.priorityColors[2],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    final endDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    if (widget.task == null) {
      context.read<TaskProvider>().addTask(
            title: _titleController.text,
            note: _noteController.text,
            date: _selectedDate,
            startTime: startDateTime,
            endTime: endDateTime,
            colorIndex: _selectedColorIndex,
          );
    } else {
      context.read<TaskProvider>().updateTask(
            id: widget.task!.id,
            title: _titleController.text,
            note: _noteController.text,
            date: _selectedDate,
            startTime: startDateTime,
            endTime: endDateTime,
            colorIndex: _selectedColorIndex,
          );
    }

    Navigator.pop(context);
  }
}
