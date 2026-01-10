import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// --- CÁC IMPORT LOGIC & MODEL ---
import '../../../core/constants/app_colors.dart';
import '../../../data/models/task_model.dart';
import '../../task_manager/logic/task_provider.dart';
import '../../task_manager/logic/theme_provider.dart';

// --- CÁC IMPORT GIAO DIỆN CON (WIDGETS) ---
import '../../task_manager/widgets/add_task_sheet.dart';
import '../widgets/task_tile.dart';
import '../widgets/statistics_card.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7);
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: scaffoldBg,
      
      // Nút Thêm công việc (FAB)
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20, right: 10),
        child: FloatingActionButton.extended(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const AddTaskSheet(),
            );
          },
          backgroundColor: AppColors.primary,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
          label: const Text(
            "Thêm Việc", 
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
          ),
        ),
      ),

      body: SafeArea(
        bottom: false,
        child: Consumer<TaskProvider>(
          builder: (context, taskProvider, child) {
            // Lấy danh sách task (đã được lọc bởi logic trong Provider)
            final tasks = taskProvider.tasks;
            
            // Tính toán số liệu thống kê (Lấy tổng quát để biểu đồ luôn đẹp)
            // Lưu ý: Nếu muốn biểu đồ thay đổi theo bộ lọc thì dùng biến 'tasks' ở trên
            // Ở đây nô tài dùng 'tasks' hiện tại để thống kê theo đúng cái mình đang nhìn thấy
            final int total = tasks.length;
            final int completed = tasks.where((t) => t.isCompleted).length;
            final int activeCount = total - completed;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 1. HEADER
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Xin chào,", 
                                style: TextStyle(fontSize: 16, color: textSecondary, fontWeight: FontWeight.w600)
                              ),
                              const SizedBox(height: 4),
                              Text(
                                activeCount > 0 ? "Còn $activeCount việc cần làm" : "Tuyệt vời! 🎉",
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
                              ),
                            ],
                          ),
                        ),
                        // Nút Đổi Theme
                        _buildCircleBtn(
                          context, 
                          icon: isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                          color: isDark ? Colors.yellow : AppColors.primary,
                          onTap: () => context.read<ThemeProvider>().toggleTheme(),
                        ),
                        const SizedBox(width: 10),
                        // Nút Tìm Kiếm
                        _buildCircleBtn(
                          context, 
                          icon: Icons.search_rounded,
                          color: AppColors.primary,
                          onTap: () => Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (_) => const SearchScreen())
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                // 2. BIỂU ĐỒ THỐNG KÊ
                if (tasks.isNotEmpty)
                  SliverToBoxAdapter(
                    child: StatisticsCard(
                      totalTasks: total, 
                      completedTasks: completed
                    ),
                  ),

                // --- 3. BỘ LỌC TAG (SCROLL NGANG) ---
                SliverToBoxAdapter(
                  child: Container(
                    height: 50,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        // Tag: Lọc theo Thời gian (Chọn ngày)
                        _buildDateFilterChip(context),
                        
                        const SizedBox(width: 8),

                        // Tag: Lọc theo Trạng thái
                        _buildStatusChip(context, "Chưa xong", false),
                        const SizedBox(width: 8),
                        _buildStatusChip(context, "Đã xong", true),
                        
                        const SizedBox(width: 8),
                        // Vạch ngăn cách
                        Container(width: 1, height: 20, color: Colors.grey.withOpacity(0.3)),
                        const SizedBox(width: 8),

                        // Tag: Lọc theo Mức độ ưu tiên (Màu sắc)
                        // 0: Bình thường (Blue), 1: Lưu ý (Amber), 2: Khẩn cấp (Red), 3: Thư giãn (Green)
                        _buildPriorityChip(context, "Bình thường", 0),
                        const SizedBox(width: 8),
                        _buildPriorityChip(context, "Lưu ý", 1),
                        const SizedBox(width: 8),
                        _buildPriorityChip(context, "Khẩn cấp", 2),
                        const SizedBox(width: 8),
                        _buildPriorityChip(context, "Thư giãn", 3),
                      ],
                    ),
                  ),
                ),
                // -------------------------------------

                // 4. DANH SÁCH CÔNG VIỆC
                tasks.isEmpty
                    ? SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.filter_alt_off_rounded, 
                                size: 60, 
                                color: AppColors.textSecondary.withOpacity(0.2)
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "Không tìm thấy kết quả", 
                                style: TextStyle(fontSize: 16, color: AppColors.textSecondary)
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final task = tasks[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Slidable(
                                key: ValueKey(task.id),
                                endActionPane: ActionPane(
                                  motion: const ScrollMotion(),
                                  extentRatio: 0.25,
                                  children: [
                                    SlidableAction(
                                      onPressed: (context) => taskProvider.deleteTask(task.id),
                                      backgroundColor: scaffoldBg,
                                      foregroundColor: Colors.red,
                                      icon: Icons.delete_outline_rounded,
                                      label: 'Xóa',
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ],
                                ),
                                child: TaskTile(
                                  task: task,
                                  onCheckboxChanged: (val) => taskProvider.toggleTaskStatus(task.id),
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) => AddTaskSheet(task: task),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                          childCount: tasks.length,
                        ),
                      ),
                
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- CÁC WIDGET CON CHO CHIP LỌC ---

  // 1. Chip Lọc Ngày
  Widget _buildDateFilterChip(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final selectedDate = provider.filterDate;
    final isSelected = selectedDate != null;
    
    return FilterChip(
      avatar: isSelected 
        ? null 
        : const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.textSecondary),
      label: Text(
        isSelected ? DateFormat('dd/MM/yyyy').format(selectedDate) : "Thời gian",
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
      ),
      selected: isSelected,
      onSelected: (bool value) async {
        if (!value) {
          context.read<TaskProvider>().setFilterDate(null);
        } else {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
          );
          if (picked != null && context.mounted) {
            context.read<TaskProvider>().setFilterDate(picked);
          }
        }
      },
      backgroundColor: Theme.of(context).cardColor,
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.2)
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  // 2. Chip Lọc Trạng Thái
  Widget _buildStatusChip(BuildContext context, String label, bool statusValue) {
    final provider = context.watch<TaskProvider>();
    final isSelected = provider.filterStatus == statusValue;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => context.read<TaskProvider>().toggleFilterStatus(statusValue),
      backgroundColor: Theme.of(context).cardColor,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
      side: BorderSide(
        color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.2)
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      checkmarkColor: Colors.white,
    );
  }

  // 3. Chip Lọc Màu (Tag Priority)
  Widget _buildPriorityChip(BuildContext context, String label, int colorIndex) {
    final provider = context.watch<TaskProvider>();
    final isSelected = provider.filterPriority == colorIndex;
    final color = AppColors.getPriorityColor(colorIndex);

    return FilterChip(
      avatar: CircleAvatar(backgroundColor: color, radius: 6),
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => context.read<TaskProvider>().toggleFilterPriority(colorIndex),
      backgroundColor: Theme.of(context).cardColor,
      selectedColor: color.withOpacity(0.2), 
      labelStyle: TextStyle(
        color: isSelected ? color : AppColors.textPrimary, 
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
      side: BorderSide(
        color: isSelected ? color : Colors.grey.withOpacity(0.2),
        width: isSelected ? 1.5 : 1,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      showCheckmark: false, 
    );
  }

  // 4. Helper Nút tròn
  Widget _buildCircleBtn(BuildContext context, {required IconData icon, required Color color, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, 
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), 
            blurRadius: 10, 
            offset: const Offset(0, 4)
          )
        ],
      ),
      child: IconButton(
        onPressed: onTap, 
        icon: Icon(icon, color: color)
      ),
    );
  }
}