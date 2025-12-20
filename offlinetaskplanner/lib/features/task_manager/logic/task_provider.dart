import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/task_model.dart'; // Chú ý đường dẫn import

class TaskProvider extends ChangeNotifier {
  final Box<Task> _box = Hive.box<Task>('tasks');

  // --- SỬA ĐOẠN NÀY ---
  // Thay vì trả về một biến _tasks, hãy lấy trực tiếp từ hộp
  List<Task> get tasks {
    // values.toList() lấy tất cả dữ liệu đang có trong hộp ra
    final taskList = _box.values.toList().cast<Task>();

    // Sắp xếp: Công việc chưa xong lên đầu, ngày gần nhất lên đầu
    taskList.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1; // Chưa xong lên trước
      }
      return b.date.compareTo(a.date); // Ngày mới nhất lên trước
    });

    return taskList;
  }
  // --------------------

  void addTask({
    required String title,
    required String note,
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
    required int colorIndex,
  }) {
    final newTask = Task(
      id: const Uuid().v4(),
      title: title,
      note: note,
      date: date,
      startTime: startTime,
      endTime: endTime,
      isCompleted: false,
      colorIndex: colorIndex,
    );

    _box.add(newTask);
    notifyListeners(); // Báo giao diện cập nhật lại
  }

  void updateTask({
    required String id,
    required String title,
    required String note,
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
    required int colorIndex,
  }) {
    // Tìm task có id tương ứng
    final task = _box.values.firstWhere((element) => element.id == id);

    task.title = title;
    task.note = note;
    task.date = date;
    task.startTime = startTime;
    task.endTime = endTime;
    task.colorIndex = colorIndex;

    task.save();
    notifyListeners();
  }

  void deleteTask(String id) {
    final task = _box.values.firstWhere((element) => element.id == id);
    task.delete();
    notifyListeners();
  }

  void toggleTaskStatus(String id) {
    final task = _box.values.firstWhere((element) => element.id == id);
    task.isCompleted = !task.isCompleted;
    task.save();
    notifyListeners();
  }
}
