import 'package:flutter/material.dart';

class AppColors {
  // Light Mode
  static const Color scaffoldBackground = Color(0xFFF4F6F8);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1E293B); // Đen than (Slate 800)
  static const Color textSecondary = Color(0xFF64748B); // Xám xanh (Slate 500)

// Dark Mode
  static const Color scaffoldDark = Color(0xFF0F172A); // Màu nền tối (Xanh đen)
  static const Color cardDark = Color(0xFF1E293B); // Màu thẻ tối
  static const Color textPrimaryDark = Color(0xFFF1F5F9); // Chữ trắng sáng
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Chữ xám sáng

  static const Color primary = Color(0xFF2563EB);

  // Màu phân loại mức độ (Pastel - Nhẹ nhàng nhưng vẫn rõ ràng)
  static const List<Color> priorityColors = [
    Color(0xFF3B82F6), // Blue (Bình thường)
    Color(0xFFF59E0B), // Amber (Lưu ý)
    Color(0xFFEF4444), // Red (Khẩn cấp)
    Color(0xFF10B981), // Emerald (Thư giãn/Xong)
  ];

  static Color getPriorityColor(int index) {
    if (index >= 0 && index < priorityColors.length) {
      return priorityColors[index];
    }
    return priorityColors[0];
  }
}
