import 'package:flutter/material.dart';

class AppColors {
  // Nền chủ đạo: Màu kem xám nhẹ (Rất dịu mắt, không bị chói như màu trắng tinh)
  static const Color scaffoldBackground = Color(0xFFF4F6F8);

  // Màu trắng cho các Card (Thẻ công việc)
  static const Color cardColor = Color(0xFFFFFFFF);

  // Màu chính (Primary): Xanh Navy hiện đại - tạo cảm giác ổn định, tin cậy
  static const Color primary = Color(0xFF2563EB);

  // Màu chữ
  static const Color textPrimary = Color(0xFF1E293B); // Đen than (Slate 800)
  static const Color textSecondary = Color(0xFF64748B); // Xám xanh (Slate 500)

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
