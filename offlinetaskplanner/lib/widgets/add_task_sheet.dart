import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class AddTaskSheet extends StatefulWidget {
  const AddTaskSheet({super.key});

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now().replacing(minute: TimeOfDay.now().minute + 30);
  int _selectedColorIndex = 0; // 0: Xanh, 1: Cam, 2: Đỏ

  // Danh sách màu để chọn
  final List<Color> _colors = [
    Colors.blue,
    Colors.orange,
    Colors.red,
    Colors.green,
  ];

  @override
  Widget build(BuildContext context) {
    // Lấy chiều cao bàn phím để đẩy giao diện lên
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: bottomInset + 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Chỉ chiếm chiều cao vừa đủ
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Tiêu đề bảng
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          const Text("Thêm Công Việc Mới", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          
          // 2. Nhập Tên & Ghi chú
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: "Tên công việc (VD: Họp triều đình)",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              hintText: "Ghi chú thêm...",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            maxLines: 2,
          ),

          // 3. Chọn Ngày & Giờ
          const SizedBox(height: 20),
          Row(
            children: [
              // Chọn Ngày
              Expanded(
                child: _buildDateTimePicker(
                  icon: Icons.calendar_today,
                  label: DateFormat('dd/MM/yyyy').format(_selectedDate),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Chọn Giờ Bắt đầu
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

          // 4. Chọn Màu (Mức độ ưu tiên)
          const SizedBox(height: 20),
          const Text("Mức độ quan trọng", style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Row(
            children: List.generate(_colors.length, (index) {
              return GestureDetector(
                onTap: () => setState(() => _selectedColorIndex = index),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: _selectedColorIndex == index 
                        ? Border.all(color: Colors.black, width: 2) 
                        : null,
                  ),
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: _colors[index],
                    child: _selectedColorIndex == index 
                        ? const Icon(Icons.check, size: 16, color: Colors.white) 
                        : null,
                  ),
                ),
              );
            }),
          ),

          // 5. Nút Lưu
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
                if (_titleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Xin Hoàng thượng đừng để trống tên công việc!")),
                  );
                  return;
                }

                // Gọi Provider để lưu
                // Chuyển TimeOfDay sang DateTime để lưu vào Model
                final now = DateTime.now();
                final startDateTime = DateTime(now.year, now.month, now.day, _startTime.hour, _startTime.minute);
                final endDateTime = DateTime(now.year, now.month, now.day, _endTime.hour, _endTime.minute);

                context.read<TaskProvider>().addTask(
                  title: _titleController.text,
                  note: _noteController.text,
                  date: _selectedDate,
                  startTime: startDateTime,
                  endTime: endDateTime,
                  colorIndex: _selectedColorIndex,
                );

                Navigator.pop(context); // Đóng bảng
              },
              child: const Text("Tạo Việc Ngay", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // Widget con hiển thị ô chọn ngày/giờ
  Widget _buildDateTimePicker({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
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