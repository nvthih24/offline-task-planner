import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/task_model.dart'; // Đảm bảo đường dẫn import đúng file model của Người

class TaskProvider extends ChangeNotifier {
  // Tên box phải trùng với tên trong main.dart
  static const String _boxName = 'tasks';

  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  // Lấy Box đang mở (vì main.dart đã mở rồi, ta chỉ cần gọi lại)
  Box<Task> get _box => Hive.box<Task>(_boxName);

  // === HÀM KHỞI TẠO ===
  void getTasks() {
    _tasks = _box.values.toList();
    // Sắp xếp: Việc nào cần làm (date) gần nhất thì đưa lên đầu
    _tasks.sort((a, b) {
      int dateComp = a.date.compareTo(b.date);
      if (dateComp == 0) {
        return a.startTime.compareTo(b.startTime); // Cùng ngày thì so giờ
      }
      return dateComp;
    });
    notifyListeners();
  }

  // === CHIÊU 1: THÊM (CREATE) ===
  // Đã cập nhật tham số để khớp với task_model.dart của Người
  Future<void> addTask({
    required String title,
    required String note,
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
    required int colorIndex,
  }) async {
    final newTask = Task(
      id: const Uuid().v4(),
      title: title,
      note: note,
      date: date,
      startTime: startTime,
      endTime: endTime,
      isCompleted: false, // Mặc định là chưa xong
      colorIndex: colorIndex,
    );

    await _box.add(newTask);
    getTasks(); // Gọi hàm này để sort lại list và báo UI cập nhật
  }

  // === CHIÊU 2: XÓA (DELETE) ===
  Future<void> deleteTask(String id) async {
    // Tìm task trong box để xóa
    final taskToDelete = _box.values.firstWhere((element) => element.id == id);
    await taskToDelete.delete();
    getTasks();
  }

  // === CHIÊU 3: SỬA (UPDATE) ===
  Future<void> updateTask({
    required String id,
    String? title,
    String? note,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    int? colorIndex,
    bool? isCompleted,
  }) async {
    final task = _box.values.firstWhere((element) => element.id == id);

    // Chỉ cập nhật những trường có thay đổi (khác null)
    if (title != null) task.title = title;
    if (note != null) task.note = note;
    if (date != null) task.date = date;
    if (startTime != null) task.startTime = startTime;
    if (endTime != null) task.endTime = endTime;
    if (colorIndex != null) task.colorIndex = colorIndex;
    if (isCompleted != null) task.isCompleted = isCompleted;

    await task.save(); // Lưu vào Hive
    getTasks();
  }

  // === CHIÊU PHỤ: ĐÁNH DẤU XONG/CHƯA XONG ===
  Future<void> toggleTaskStatus(String id) async {
    final task = _box.values.firstWhere((element) => element.id == id);
    task.isCompleted = !task.isCompleted;
    await task.save();
    getTasks();
  }
}
