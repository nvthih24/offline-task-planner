import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../../data/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final Box<UserModel> _usersBox = Hive.box<UserModel>('usersBox');
  final Box _sessionBox = Hive.box('sessionBox');

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  // Hàm Đăng ký
  Future<bool> register(String email, String password, String name) async {
    if (_usersBox.containsKey(email)) {
      return false; // Email đã tồn tại
    }
    final newUser = UserModel(
        id: DateTime.now().toString(),
        email: email,
        password: password,
        displayName: name);
    await _usersBox.put(email, newUser); // Dùng email làm Key luôn cho dễ tìm
    return true;
  }

  // Hàm Đăng nhập
  Future<bool> login(String email, String password) async {
    final user = _usersBox.get(email);
    if (user != null && user.password == password) {
      _currentUser = user;
      await _sessionBox.put('loggedInEmail', email); // Lưu phiên
      notifyListeners();
      return true;
    }
    return false; // Sai email hoặc pass
  }
}
