import 'package:flutter/material.dart';

class CustomCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final Color? bgColor;
  final double size;
  final double iconSize;

  const CustomCircleButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color,
    this.bgColor,
    this.size = 60,
    this.iconSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    // Nếu không truyền màu thì tự lấy theo Theme
    final theme = Theme.of(context);
    final backgroundColor = bgColor ?? theme.cardColor;
    final iconColor = color ?? theme.textTheme.bodyMedium?.color;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Icon(icon, color: iconColor, size: iconSize),
      ),
    );
  }
}
