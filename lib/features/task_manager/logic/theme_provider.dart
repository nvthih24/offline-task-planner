import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeProvider extends ChangeNotifier {
  final Box _box = Hive.box('settings');
  static const String _key = 'isDarkMode';

  // Kiểm tra xem đã lưu chế độ tối chưa, nếu chưa thì mặc định là False (Sáng)
  bool get isDarkMode => _box.get(_key, defaultValue: false);

  // Hàm đảo ngược chế độ (Sáng -> Tối -> Sáng)
  void toggleTheme() {
    _box.put(_key, !isDarkMode);
    notifyListeners(); // Báo cho toàn bộ App vẽ lại giao diện
  }
}
