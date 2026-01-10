import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/task_model.dart';

class TaskProvider extends ChangeNotifier {
  final Box<Task> _box = Hive.box<Task>('tasks');

// --- GAMIFICATION VARIABLES ---
  // dùng box tạm tên 'user_stats' để lưu cho gọn
  late Box _statsBox;

  int _xp = 0;
  int _streak = 0;
  DateTime? _lastCompletionDate;

  // Getters
  int get xp => _xp;
  int get streak => _streak;
  int get level => (_xp / 100).floor() + 1; // 100 XP = 1 Level
  int get xpToNextLevel => 100 - (_xp % 100); // Còn thiếu bao nhiêu để lên cấp
  double get levelProgress => (_xp % 100) / 100; // % thanh tiến độ (0.0 -> 1.0)

  // Danh hiệu theo Level
  String get userTitle {
    if (level < 5) return "Tập sự (Novice)";
    if (level < 10) return "Junior Planner";
    if (level < 20) return "Senior Planner";
    return "Master of Time 👑";
  }
  // ------------------------------------

  //them bien search
  String _searchQuery = '';

  DateTime? _filterDate;
  bool? _filterStatus; // true: completed, false: not completed, null: all
  int _filterPriority = -1;

  String get searchQuery => _searchQuery;
  DateTime? get filterDate => _filterDate;
  bool? get filterStatus => _filterStatus;
  int get filterPriority => _filterPriority;

  // Thay vì trả về một biến _tasks, hãy lấy trực tiếp từ hộp
  List<Task> get tasks {
    //khoi tao
    var taskList = _box.values.toList().cast<Task>();

    //loc theo tag mau
    if (_filterPriority != -1) {
      taskList =
          taskList.where((t) => t.colorIndex == _filterPriority).toList();
    }

    //loc theo trang thai
    if (_filterStatus != null) {
      taskList = taskList.where((t) => t.isCompleted == _filterStatus).toList();
    }

    //loc theo ngay
    if (_filterDate != null) {
      taskList = taskList.where((t) {
        return t.date.year == _filterDate!.year &&
            t.date.month == _filterDate!.month &&
            t.date.day == _filterDate!.day;
      }).toList();
    }

    //loc theo search
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      taskList = taskList.where((task) {
        return task.title.toLowerCase().contains(query) ||
            task.note.toLowerCase().contains(query);
      }).toList();
    }

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

  TaskProvider() {
    _initStats(); // Khởi tạo Stats
  }

  // --- LOGIC GAMIFICATION ---
  Future<void> _initStats() async {
    _statsBox = await Hive.openBox('user_stats');
    _xp = _statsBox.get('xp', defaultValue: 0);
    _streak = _statsBox.get('streak', defaultValue: 0);
    final lastDateMillis = _statsBox.get('last_date');
    if (lastDateMillis != null) {
      _lastCompletionDate = DateTime.fromMillisecondsSinceEpoch(lastDateMillis);
    }
    notifyListeners();
  }

  void _updateGamification(bool isCompleted) {
    if (isCompleted) {
      // 1. Cộng XP
      _xp += 10;

      // 2. Tính Streak
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if (_lastCompletionDate == null) {
        // Lần đầu tiên hoàn thành
        _streak = 1;
        _lastCompletionDate = today;
      } else {
        final last = DateTime(_lastCompletionDate!.year,
            _lastCompletionDate!.month, _lastCompletionDate!.day);

        if (today.difference(last).inDays == 1) {
          // Đúng là ngày hôm qua -> Tăng chuỗi
          _streak++;
          _lastCompletionDate = today;
        } else if (today.difference(last).inDays > 1) {
          // Bị đứt quãng (quá 1 ngày) -> Reset về 1
          _streak = 1;
          _lastCompletionDate = today;
        } else {
          // Vẫn là hôm nay -> Không tăng streak, chỉ tăng XP
        }
      }
    } else {
      // Nếu bỏ tick (undo) -> Trừ XP lại để tránh hack điểm
      if (_xp >= 10) _xp -= 10;
      // Streak thì thôi, tha cho user, không trừ :D
    }

    // Lưu vào Hive
    _statsBox.put('xp', _xp);
    _statsBox.put('streak', _streak);
    if (_lastCompletionDate != null) {
      _statsBox.put('last_date', _lastCompletionDate!.millisecondsSinceEpoch);
    }
    notifyListeners();
  }
  // ------------------------------------

  void addTask({
    required String title,
    required String note,
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
    required int colorIndex,
  }) {
    try {
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
    } catch (e) {
      debugPrint('Lỗi khi thêm task: $e');
    }
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
    try {
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
    } catch (e) {
      // Xử lý lỗi nếu không tìm thấy task
      debugPrint('Lỗi không tìm thấy task: $e');
    }
  }

  void deleteTask(String id) {
    try {
      final task = _box.values.firstWhere((element) => element.id == id);
      task.delete();
      notifyListeners();
    } catch (e) {
      debugPrint('Lỗi không thể xóa task: $e');
    }
  }

  void toggleTaskStatus(String id) {
    try {
      final task = _box.values.firstWhere((element) => element.id == id);
      task.isCompleted = !task.isCompleted;
      task.save();
      _updateGamification(task.isCompleted);
      notifyListeners();
    } catch (e) {
      debugPrint('Lỗi không thể thay đổi trạng thái task: $e');
    }
  }

  // them ham search
  void setSearchQuery(String query) {
    try {
      _searchQuery = query;
      notifyListeners();
    } catch (e) {
      debugPrint('Lỗi khi đặt truy vấn tìm kiếm: $e');
    }
  }

  // ham xoa search
  void clearSearchQuery() {
    try {
      _searchQuery = '';
      notifyListeners();
    } catch (e) {
      debugPrint('Lỗi khi xóa truy vấn tìm kiếm: $e');
    }
  }

// chon/bo chon loc muc theo mau
  void toggleFilterPriority(int index) {
    try {
      if (_filterPriority == index) {
        _filterPriority = -1; // Đang chọn thì bỏ chọn
      } else {
        _filterPriority = index; // Chọn mới
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Lỗi khi thay đổi bộ lọc mức độ ưu tiên: $e');
    }
  }

  // Chọn/Bỏ chọn lọc theo Trạng thái
  void toggleFilterStatus(bool? status) {
    try {
      if (_filterStatus == status) {
        _filterStatus = null; // Bỏ chọn (về Tất cả)
      } else {
        _filterStatus = status;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Lỗi khi thay đổi bộ lọc trạng thái: $e');
    }
  }

  // Chọn/Bỏ chọn lọc theo Ngày
  void setFilterDate(DateTime? date) {
    try {
      _filterDate = date;
      notifyListeners();
    } catch (e) {
      debugPrint('Lỗi khi thay đổi bộ lọc ngày: $e');
    }
  }
}
