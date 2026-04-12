import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../auth/logic/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../task_manager/logic/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // --- SECTION 1: TÀI KHOẢN ---
          const Text(
            'Tài khoản',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              final user = authProvider.currentUser;

              if (user != null) {
                // Giao diện khi ĐÃ ĐĂNG NHẬP
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Text(
                            // Đổi user.name thành user.displayName
                            user.displayName.isNotEmpty
                                ? user.displayName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Đổi user.name thành user.displayName
                              Text(user.displayName,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(user.email,
                                  style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => authProvider.logout(),
                          icon: const Icon(Icons.logout_rounded,
                              color: Colors.redAccent),
                          tooltip: 'Đăng xuất',
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                // Giao diện khi CHƯA ĐĂNG NHẬP
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(Icons.account_circle_outlined,
                            size: 60, color: Colors.grey),
                        const SizedBox(height: 8),
                        const Text('Chưa đăng nhập',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('Đăng nhập để đồng bộ dữ liệu của bạn',
                            style: TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const LoginScreen()),
                              );
                            },
                            icon: const Icon(Icons.login_rounded),
                            label: const Text('Đăng nhập ngay'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),

          const SizedBox(height: 32),

          // --- SECTION 2: CÀI ĐẶT HỆ THỐNG (DARK MODE) ---
          const Text(
            'Hệ thống',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode
                          ? Colors.amber.withOpacity(0.2)
                          : Colors.blueGrey.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      themeProvider.isDarkMode
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: themeProvider.isDarkMode
                          ? Colors.amber
                          : Colors.blueGrey,
                    ),
                  ),
                  title: const Text('Chế độ tối (Dark Mode)',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme();
                    },
                    activeColor: AppColors.primary,
                  ),
                );
              },
            ),
          ),

          // Sau này ông có thể thêm các nút như "Giới thiệu", "Đánh giá app" ở dưới này
        ],
      ),
    );
  }
}
