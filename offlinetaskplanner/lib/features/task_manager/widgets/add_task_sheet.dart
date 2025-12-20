import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/task_model.dart';
import '../logic/task_provider.dart';

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

      // Xử lý logic cộng giờ an toàn
      final now = DateTime.now();
      final endDateTime = now.add(const Duration(minutes: 30));
      _endTime = TimeOfDay.fromDateTime(endDateTime);

      _selectedColorIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.task != null;
    // Lấy padding bàn phím
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: bottomInset + 20, // Đẩy nội dung lên khi bàn phím hiện
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        // Thêm cuộn để tránh lỗi overflow màn hình nhỏ
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Thanh nắm kéo (Handle bar)
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Tiêu đề
            Text(
              isEdit ? "Cập Nhật Công Việc" : "Thêm Công Việc Mới",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            // 3. Ô nhập Tiêu đề
            _buildInputField(
              controller: _titleController,
              hint: "Tiêu đề công việc",
              icon: Icons.title,
              autoFocus: true,
            ),
            const SizedBox(height: 16),

            // 4. Ô nhập Ghi chú
            _buildInputField(
              controller: _noteController,
              hint: "Ghi chú chi tiết...",
              icon: Icons.notes,
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            // 5. Chọn Ngày & Giờ
            Row(
              children: [
                Expanded(
                  child: _buildDateTimePicker(
                    label: DateFormat('dd/MM/yyyy').format(_selectedDate),
                    icon: Icons.calendar_today_outlined,
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateTimePicker(
                    label:
                        "${_startTime.format(context)} - ${_endTime.format(context)}",
                    icon: Icons.access_time,
                    onTap: _pickTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 6. Chọn Màu (Mức độ ưu tiên)
            const Text(
              "Mức độ ưu tiên",
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Wrap(
                  spacing: 8,
                  children: List.generate(4, (index) {
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColorIndex = index),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.getAccentColor(index),
                        child: _selectedColorIndex == index
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              )
                            : null,
                      ),
                    );
                  }),
                ),

                // 7. Nút Lưu (Nằm bên phải hàng chọn màu)
                ElevatedButton(
                  onPressed: _saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isEdit ? "Lưu lại" : "Tạo việc",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- CÁC WIDGET CON (Được tách ra cho code sạch) ---

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    bool autoFocus = false,
  }) {
    return TextField(
      controller: controller,
      autofocus: autoFocus,
      maxLines: maxLines,
      style: TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: AppColors.primary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.05), // Nền xám cực nhạt
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildDateTimePicker({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- CÁC HÀM LOGIC ---

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _pickTime() async {
    // 1. Chọn giờ bắt đầu
    TimeOfDay? start = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (start != null) {
      setState(() => _startTime = start);

      // 2. Chọn giờ kết thúc (Optional: có thể bỏ qua nếu muốn đơn giản)
      if (mounted) {
        // Tự động set giờ kết thúc = giờ bắt đầu + 1 tiếng (cho nhanh)
        // Hoặc mở popup chọn tiếp nếu muốn kỹ
        setState(() {
          final now = DateTime.now();
          final dtStart = DateTime(
            now.year,
            now.month,
            now.day,
            start.hour,
            start.minute,
          );
          final dtEnd = dtStart.add(const Duration(hours: 1));
          _endTime = TimeOfDay.fromDateTime(dtEnd);
        });
      }
    }
  }

  void _saveTask() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập tên công việc!")),
      );
      return;
    }

    // Kết hợp Ngày + Giờ để ra DateTime chuẩn
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
      // THÊM MỚI
      context.read<TaskProvider>().addTask(
        title: _titleController.text,
        note: _noteController.text,
        date: _selectedDate,
        startTime: startDateTime,
        endTime: endDateTime,
        colorIndex: _selectedColorIndex,
      );
    } else {
      // SỬA
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
