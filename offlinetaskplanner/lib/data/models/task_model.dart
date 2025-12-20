import 'package:hive/hive.dart';

// Dòng này cực quan trọng, nó là tên file sẽ được sinh ra tự động
part 'task_model.g.dart';

@HiveType(typeId: 0) // typeId phải là duy nhất cho mỗi model
class Task extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title; // Tên công việc

  @HiveField(2)
  String note; // Ghi chú thêm

  @HiveField(3)
  DateTime date; // Ngày thực hiện

  @HiveField(4)
  DateTime startTime; // Giờ bắt đầu

  @HiveField(5)
  DateTime endTime; // Giờ kết thúc

  @HiveField(6)
  bool isCompleted; // Đã xong chưa?

  @HiveField(7)
  int colorIndex; // Lưu màu sắc của Task (0: Xanh, 1: Đỏ...) để UI đẹp hơn

  Task({
    required this.id,
    required this.title,
    required this.note,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.isCompleted,
    required this.colorIndex,
  });
}
