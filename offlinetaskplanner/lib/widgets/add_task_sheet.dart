import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../data/models/task_model.dart';
import '../providers/task_provider.dart';

class AddTaskSheet extends StatefulWidget {
  final Task? task; // <--- Điểm mới: Nhận vào công việc cần sửa (nếu có)

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

  final List<Color> _colors = [
    Colors.blue,
    Colors.orange,
    Colors.red,
    Colors.green,
  ];

  @override
  void initState() {
    super.initState();
    // KIỂM TRA: Đang sửa hay đang tạo mới?
    final task = widget.task;
    if (task != null) {
      // Đang sửa: Lấy dữ liệu cũ đắp vào
      _titleController = TextEditingController(text: task.title);
      _noteController = TextEditingController(text: task.note);
      _selectedDate = task.date;
      _startTime = TimeOfDay.fromDateTime(task.startTime);
      _endTime = TimeOfDay.fromDateTime(task.endTime);
      _selectedColorIndex = task.colorIndex;
    } else {
      // Tạo mới: Lấy mặc định
      _titleController = TextEditingController();
      _noteController = TextEditingController();
      _selectedDate = DateTime.now();
      _startTime = TimeOfDay.now();
      _endTime = TimeOfDay.now().replacing(minute: TimeOfDay.now().minute + 30);
      _selectedColorIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tiêu đề thay đổi tùy theo việc Tạo hay Sửa
    final String titleText = widget.task == null ? "Thêm Việc Mới" : "Sửa Công Việc";
    final String buttonText = widget.task == null ? "Tạo Việc Ngay" : "Lưu Thay Đổi";

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: bottomInset + 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Text(titleText, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: "Tên công việc",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true, fillColor: Colors.grey[100],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              hintText: "Ghi chú thêm...",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true, fillColor: Colors.grey[100],
            ),
            maxLines: 2,
          ),

          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildDateTimePicker(
                  icon: Icons.calendar_today,
                  label: DateFormat('dd/MM/yyyy').format(_selectedDate),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context, initialDate: _selectedDate,
                      firstDate: DateTime(2000), lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateTimePicker(
                  icon: Icons.access_time,
                  label: _startTime.format(context),
                  onTap: () async {
                    final picked = await showTimePicker(context: context, initialTime: _startTime);
                    if (picked != null) setState(() => _startTime = picked);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Row(
            children: List.generate(_colors.length, (index) {
              return GestureDetector(
                onTap: () => setState(() => _selectedColorIndex = index),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: _selectedColorIndex == index ? Border.all(color: Colors.black, width: 2) : null,
                  ),
                  child: CircleAvatar(
                    radius: 14, backgroundColor: _colors[index],
                    child: _selectedColorIndex == index ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (_titleController.text.isEmpty) return;

                // Xử lý Ngày Giờ
                final startDateTime = DateTime(
                    _selectedDate.year, _selectedDate.month, _selectedDate.day, 
                    _startTime.hour, _startTime.minute);
                final endDateTime = DateTime(
                    _selectedDate.year, _selectedDate.month, _selectedDate.day, 
                    _endTime.hour, _endTime.minute);

                if (widget.task == null) {
                  // === TRƯỜNG HỢP 1: TẠO MỚI ===
                  context.read<TaskProvider>().addTask(
                    title: _titleController.text,
                    note: _noteController.text,
                    date: _selectedDate,
                    startTime: startDateTime,
                    endTime: endDateTime,
                    colorIndex: _selectedColorIndex,
                  );
                } else {
                  // === TRƯỜNG HỢP 2: CẬP NHẬT (SỬA) ===
                  context.read<TaskProvider>().updateTask(
                    id: widget.task!.id, // Lấy ID cũ để biết đường sửa
                    title: _titleController.text,
                    note: _noteController.text,
                    date: _selectedDate,
                    startTime: startDateTime,
                    endTime: endDateTime,
                    colorIndex: _selectedColorIndex,
                  );
                }

                Navigator.pop(context);
              },
              child: Text(buttonText, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimePicker({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue[800], size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}