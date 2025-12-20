import 'package:flutter/material.dart';

class AppColors {
  // Nền chính (Trắng sứ & Xám khói)
  static const Color background = Color(0xFFF3F4F6); // Xám rất nhạt cho nền
  static const Color surface = Color(0xFFFFFFFF); // Trắng cho Card

  // Màu chữ (Đen xám dịu mắt)
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);

  // Màu chủ đạo (Indigo - Xanh cổ điển)
  static const Color primary = Color(0xFF4F46E5);

  // Các màu trạng thái (Pastel nhẹ nhàng)
  static const Color pastelBlue = Color(0xFFE0F2FE);
  static const Color pastelRed = Color(0xFFFEE2E2);
  static const Color pastelGreen = Color(0xFFDCFCE7);
  static const Color pastelOrange = Color(0xFFFFEDD5);

  // Hàm lấy màu thẻ task dựa trên index
  static Color getCardColor(int index) {
    // Trả về màu trắng (cổ điển) hoặc màu pastel nhẹ nếu muốn phân loại
    return surface;
  }

  // Hàm lấy màu điểm nhấn (vạch màu bên trái)
  static Color getAccentColor(int index) {
    switch (index % 4) {
      case 0:
        return const Color(0xFF3B82F6); // Blue
      case 1:
        return const Color(0xFFEF4444); // Red
      case 2:
        return const Color(0xFF10B981); // Green
      case 3:
        return const Color(0xFFF59E0B); // Orange
      default:
        return primary;
    }
  }
}
