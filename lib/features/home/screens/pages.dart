import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../../home/screens/home_screen.dart';
import '../../stats/screens/stats_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../task_manager/widgets/add_task_sheet.dart';
import '../../focus/screens/focus_screen.dart';
import '../../../core/constants/app_colors.dart';

class Pages extends StatefulWidget {
  const Pages({super.key});

  @override
  State<Pages> createState() => _PagesState();
}

class _PagesState extends State<Pages> {
  int _selectedIndex = 0;

  // Danh sách các màn hình tương ứng với các tab
  final List<Widget> _pages = [
    const HomeScreen(), // Index 0
    const FocusScreen(), // Index 1
    const StatsScreen(), // Index 2
    const SettingsScreen(), // Index 3
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // Hiển thị màn hình theo index đang chọn
      // Dùng IndexedStack để giữ trạng thái (không bị load lại khi chuyển tab)
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      // Nút Thêm việc (FAB) nằm ở giữa, nổi lên
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddTaskSheet(),
          );
        },
        backgroundColor: theme.primaryColor,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      // Vị trí FAB
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // Thanh điều hướng dưới cùng
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(0.05),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.grey[300]!, // Màu hiệu ứng gợn sóng
              hoverColor: Colors.grey[100]!, // Màu khi di chuột (Web)
              gap: 8, // Khoảng cách giữa Icon và Chữ (khi được chọn)
              activeColor: AppColors.primary, // Màu Icon và Chữ khi được chọn
              iconSize: 24, // Kích thước Icon
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 12), // Độ dày của nút
              duration: const Duration(milliseconds: 400), // Tốc độ hiệu ứng

              // Màu nền của Tab khi được chọn (Quan trọng cho style Soft Minimalist)
              tabBackgroundColor: AppColors.primary.withOpacity(0.1),

              // Màu Icon khi KHÔNG được chọn
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
              tabs: const [
                GButton(
                  icon: Icons.home_rounded,
                  text: 'Trang chủ',
                ),
                GButton(
                  icon: Icons.timer_outlined,
                  text: 'Tập trung',
                ),
                GButton(
                  icon: Icons.pie_chart_outline_rounded,
                  text: 'Thống kê',
                ),
                GButton(
                  icon: Icons.settings_outlined,
                  text: 'Cài đặt',
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
