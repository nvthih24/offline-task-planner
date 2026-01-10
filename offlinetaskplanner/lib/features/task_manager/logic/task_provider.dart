import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../data/models/task_model.dart';

class TaskProvider extends ChangeNotifier {
  final Box<Task> _box = Hive.box<Task>('tasks');

  // --- 1. CÁC BIẾN LƯU TRẠNG THÁI BỘ LỌC ---
  String _searchQuery = '';
  
  // Lọc theo màu (Priority): -1 là tắt, 0..3 là theo index màu
  int _filterPriority = -1; 
  
  // Lọc theo trạng thái: null (Tất cả), false (Chưa xong), true (Đã xong)
  bool? _filterStatus; 
  
  // Lọc theo ngày: null là tắt
  DateTime? _filterDate;

  // --- 2. GETTER (ĐỂ GIAO DIỆN LẤY DỮ LIỆU) ---
  String get searchQuery => _searchQuery;
  int get filterPriority => _filterPriority;
  bool? get filterStatus => _filterStatus;
  DateTime? get filterDate => _filterDate;

  // --- 3. LOGIC LỌC ĐA TẦNG (CÁI PHỄU) ---
  List<Task> get tasks {
    // Lấy tất cả dữ liệu gốc
    var list = _box.values.toList().cast<Task>();

    // TẦNG 1: Lọc theo TAG MÀU (Priority)
    if (_filterPriority != -1) {
      list = list.where((t) => t.colorIndex == _filterPriority).toList();
    }

    // TẦNG 2: Lọc theo TRẠNG THÁI (Status)
    if (_filterStatus != null) {
      list = list.where((t) => t.isCompleted == _filterStatus).toList();
    }

    // TẦNG 3: Lọc theo NGÀY (Date)
    if (_filterDate != null) {
      list = list.where((t) {
        return t.date.year == _filterDate!.year &&
               t.date.month == _filterDate!.month &&
               t.date.day == _filterDate!.day;
      }).toList();
    }

    // TẦNG 4: Lọc theo TỪ KHÓA TÌM KIẾM
    // (Tìm kiếm hoạt động trên danh sách ĐÃ ĐƯỢC LỌC bởi 3 bước trên)
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      list = list.where((t) {
        return t.title.toLowerCase().contains(query) ||
               t.note.toLowerCase().contains(query);
      }).toList();
    }

    // CUỐI CÙNG: Sắp xếp
    // Ưu tiên 1: Việc chưa xong đưa lên đầu
    // Ưu tiên 2: Ngày mới nhất đưa lên đầu
    list.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1; 
      }
      return b.date.compareTo(a.date);
    });

    return list;
  }

  // --- 4. CÁC HÀM ĐIỀU KHIỂN BỘ LỌC ---

  // Chọn/Bỏ chọn lọc theo Màu
  void toggleFilterPriority(int index) {
    if (_filterPriority == index) {
      _filterPriority = -1; // Đang chọn thì bỏ chọn
    } else {
      _filterPriority = index; // Chọn mới
    }
    notifyListeners();
  }

  // Chọn/Bỏ chọn lọc theo Trạng thái
  void toggleFilterStatus(bool? status) {
    if (_filterStatus == status) {
      _filterStatus = null; // Bỏ chọn (về Tất cả)
    } else {
      _filterStatus = status;
    }
    notifyListeners();
  }

  // Chọn/Bỏ chọn lọc theo Ngày
  void setFilterDate(DateTime? date) {
    _filterDate = date;
    notifyListeners();
  }

  // Nhập từ khóa tìm kiếm
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearchQuery() {
    _searchQuery = '';
    notifyListeners();
  }

  // --- 5. CÁC HÀM CRUD (THÊM, SỬA, XÓA) ---

  void addTask({
    required String title,
    required String note,
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
    required int colorIndex,
  }) {
    final newTask = Task(
      // Tạo ID bằng thời gian hiện tại
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      note: note,
      date: date,
      startTime: startTime,
      endTime: endTime,
      isCompleted: false,
      colorIndex: colorIndex,
    );
    _box.add(newTask);
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
    try {
      final task = _box.values.firstWhere((e) => e.id == id);
      task.title = title;
      task.note = note;
      task.date = date;
      task.startTime = startTime;
      task.endTime = endTime;
      task.colorIndex = colorIndex;
      task.save();
      notifyListeners();
    } catch (e) {
      debugPrint("Lỗi cập nhật: $e");
    }
  }

  void deleteTask(String id) {
    try {
      final task = _box.values.firstWhere((e) => e.id == id);
      task.delete();
      notifyListeners();
    } catch (e) {
      debugPrint("Lỗi xóa: $e");
    }
  }

  void toggleTaskStatus(String id) {
    try {
      final task = _box.values.firstWhere((e) => e.id == id);
      task.isCompleted = !task.isCompleted;
      task.save();
      notifyListeners();
    } catch (e) {
      debugPrint("Lỗi đổi trạng thái: $e");
    }
  }
}