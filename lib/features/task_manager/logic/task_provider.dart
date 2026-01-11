import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/task_model.dart';
import '../../../core/services/notification_service.dart';

class TaskProvider extends ChangeNotifier {
  final Box<Task> _box = Hive.box<Task>('tasks');

  // --- GAMIFICATION VARIABLES ---
  late Box _statsBox;

  int _xp = 0;
  int _streak = 0;
  DateTime? _lastCompletionDate;

  int get xp => _xp;
  int get streak => _streak;
  int get level => (_xp / 100).floor() + 1;
  int get xpToNextLevel => 100 - (_xp % 100);
  double get levelProgress => (_xp % 100) / 100;

  String get userTitle {
    if (level < 5) return "Tập sự (Novice)";
    if (level < 10) return "Junior Planner";
    if (level < 20) return "Senior Planner";
    return "Master of Time 👑";
  }

  // --- SEARCH & FILTER ---
  String _searchQuery = '';
  DateTime? _filterDate;
  bool? _filterStatus;
  int _filterPriority = -1;

  String get searchQuery => _searchQuery;
  DateTime? get filterDate => _filterDate;
  bool? get filterStatus => _filterStatus;
  int get filterPriority => _filterPriority;

  List<Task> get tasks {
    var taskList = _box.values.toList().cast<Task>();

    if (_filterPriority != -1) {
      taskList =
          taskList.where((t) => t.colorIndex == _filterPriority).toList();
    }

    if (_filterStatus != null) {
      taskList = taskList.where((t) => t.isCompleted == _filterStatus).toList();
    }

    if (_filterDate != null) {
      taskList = taskList.where((t) {
        return t.date.year == _filterDate!.year &&
            t.date.month == _filterDate!.month &&
            t.date.day == _filterDate!.day;
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      taskList = taskList.where((task) {
        return task.title.toLowerCase().contains(query) ||
            task.note.toLowerCase().contains(query);
      }).toList();
    }

    taskList.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      return b.date.compareTo(a.date);
    });

    return taskList;
  }

  TaskProvider() {
    _initStats();
  }

  // --- GAMIFICATION ---
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
      _xp += 10;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if (_lastCompletionDate == null) {
        _streak = 1;
        _lastCompletionDate = today;
      } else {
        final last = DateTime(
          _lastCompletionDate!.year,
          _lastCompletionDate!.month,
          _lastCompletionDate!.day,
        );

        if (today.difference(last).inDays == 1) {
          _streak++;
          _lastCompletionDate = today;
        } else if (today.difference(last).inDays > 1) {
          _streak = 1;
          _lastCompletionDate = today;
        }
      }
    } else {
      if (_xp >= 10) _xp -= 10;
    }

    _statsBox.put('xp', _xp);
    _statsBox.put('streak', _streak);
    if (_lastCompletionDate != null) {
      _statsBox.put('last_date', _lastCompletionDate!.millisecondsSinceEpoch);
    }
    notifyListeners();
  }

  // ================== TASK CRUD ==================

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

    final scheduledDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      startTime.hour,
      startTime.minute,
    );

    NotificationService().scheduleNotification(
      id: newTask.id.hashCode,
      title: "Đến giờ: $title",
      body: note.isNotEmpty ? note : "Đã đến lúc thực hiện công việc này!",
      scheduledDate: scheduledDateTime,
    );

    notifyListeners();
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
    final task = _box.values.firstWhere((e) => e.id == id);

    NotificationService().cancelNotification(task.id.hashCode);

    task
      ..title = title
      ..note = note
      ..date = date
      ..startTime = startTime
      ..endTime = endTime
      ..colorIndex = colorIndex;

    task.save();

    final scheduledDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      startTime.hour,
      startTime.minute,
    );

    NotificationService().scheduleNotification(
      id: task.id.hashCode,
      title: "Đến giờ: $title",
      body: note.isNotEmpty ? note : "Bạn có công việc cần làm ngay.",
      scheduledDate: scheduledDateTime,
    );

    notifyListeners();
  }

  void deleteTask(String id) {
    final task = _box.values.firstWhere((e) => e.id == id);
    NotificationService().cancelNotification(task.id.hashCode);
    task.delete();
    notifyListeners();
  }

  void toggleTaskStatus(String id) {
    final task = _box.values.firstWhere((e) => e.id == id);
    task.isCompleted = !task.isCompleted;

    if (task.isCompleted) {
      NotificationService().cancelNotification(task.id.hashCode);
    } else {
      final scheduledDateTime = DateTime(
        task.date.year,
        task.date.month,
        task.date.day,
        task.startTime.hour,
        task.startTime.minute,
      );

      NotificationService().scheduleNotification(
        id: task.id.hashCode,
        title: "Đến giờ: ${task.title}",
        body: task.note,
        scheduledDate: scheduledDateTime,
      );
    }

    task.save();
    _updateGamification(task.isCompleted);
    notifyListeners();
  }

  // --- SEARCH & FILTER ---
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearchQuery() {
    _searchQuery = '';
    notifyListeners();
  }

  void toggleFilterPriority(int index) {
    _filterPriority = _filterPriority == index ? -1 : index;
    notifyListeners();
  }

  void toggleFilterStatus(bool? status) {
    _filterStatus = _filterStatus == status ? null : status;
    notifyListeners();
  }

  void setFilterDate(DateTime? date) {
    _filterDate = date;
    notifyListeners();
  }
}
