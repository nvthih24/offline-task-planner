import 'package:hive/hive.dart';

// Dòng này bắt buộc phải có để build_runner tạo file .g.dart
part 'user_model.g.dart';

// Lưu ý: typeId phải là một số DUY NHẤT.
// Nếu file task_model.dart của ông đang dùng typeId: 0, thì ở đây phải dùng typeId: 1
@HiveType(typeId: 1)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String password;

  @HiveField(3)
  final String displayName;

  UserModel({
    required this.id,
    required this.email,
    required this.password,
    required this.displayName,
  });
}
