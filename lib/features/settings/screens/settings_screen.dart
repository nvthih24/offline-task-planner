import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../task_manager/logic/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          "Cài Đặt",
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Mục Cài đặt giao diện
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: SwitchListTile(
              title: const Text("Chế độ tối (Dark Mode)",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              secondary: Icon(
                isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                color: isDark ? Colors.yellow : Colors.orange,
              ),
              value: isDark,
              onChanged: (val) {
                context.read<ThemeProvider>().toggleTheme();
              },
              activeColor: theme.primaryColor,
            ),
          ),

          const SizedBox(height: 16),

          // Mục thông tin App
          Center(
            child: Text(
              "Task Planner v1.0.0",
              style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5)),
            ),
          )
        ],
      ),
    );
  }
}
