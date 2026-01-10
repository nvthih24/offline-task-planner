import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';

import '../../task_manager/logic/task_provider.dart';
import '../../task_manager/widgets/add_task_sheet.dart';

import '../widgets/task_tile.dart';
import '../widgets/filter_chips.dart';

import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // Lấy màu chữ phụ động theo Theme
    final textSecondaryColor =
        Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // Nút thêm việc (FAB)

      body: SafeArea(
        bottom: false,
        child: Consumer<TaskProvider>(
          builder: (context, taskProvider, child) {
            final tasks = taskProvider.tasks;
            final int total = tasks.length;
            final int completed = tasks.where((t) => t.isCompleted).length;
            final int activeTasks = total - completed;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 1. HEADER (Bọc trong SliverToBoxAdapter)
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
                                "Chào bạn,",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: textSecondaryColor,
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                activeTasks > 0
                                    ? "Bạn có $activeTasks việc cần làm"
                                    : "Mọi việc đã hoàn tất! 🎉",
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Nút tìm kiếm (Giả lập)
                        Container(
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4))
                            ],
                          ),
                          child: IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SearchScreen(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.search_rounded,
                              color: AppColors.primary,
                            ),
                            tooltip: 'Tìm kiếm',
                          ),
                        ),

                        // Box Ngày tháng
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4))
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(DateFormat('d').format(DateTime.now()),
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary)),
                              Text(
                                  DateFormat('MMM')
                                      .format(DateTime.now())
                                      .toUpperCase(),
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: textSecondaryColor)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                // --- 2. BỘ LỌC TAG (SCROLL NGANG) ---
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 10),
                    child: Row(
                      children: const [
                        // 1. Lọc Ngày
                        DateFilterChip(),
                        SizedBox(width: 8),

                        // 2. Lọc Trạng thái
                        StatusFilterChip(
                            label: "Chưa xong", statusValue: false),
                        SizedBox(width: 8),
                        StatusFilterChip(label: "Đã xong", statusValue: true),
                        SizedBox(width: 8),

                        // 3. Lọc Màu (Ví dụ)
                        PriorityFilterChip(label: "Thường", colorIndex: 0),
                        SizedBox(width: 8),
                        PriorityFilterChip(label: "Lưu ý", colorIndex: 1),
                        SizedBox(width: 8),
                        PriorityFilterChip(label: "Gấp", colorIndex: 2),
                        SizedBox(width: 8),
                        PriorityFilterChip(label: "Thư giãn", colorIndex: 3),
                      ],
                    ),
                  ),
                ),
                // -------------------------------------

                // 4. DANH SÁCH CÔNG VIỆC
                tasks.isEmpty
                    ? SliverFillRemaining(
                        // Dùng cái này thay cho Expanded khi ở trong CustomScrollView
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.checklist_rtl_rounded,
                                  size: 80,
                                  color:
                                      AppColors.textSecondary.withOpacity(0.2)),
                              const SizedBox(height: 16),
                              const Text("Danh sách trống trơn",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      )
                    : SliverList(
                        // Dùng SliverList thay vì ListView
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final task = tasks[index];
                            return Padding(
                              padding: const EdgeInsets.only(
                                  left: 24,
                                  right: 24,
                                  bottom: 16 // <--- CHUYỂN MARGIN VỀ ĐÂY
                                  ),
                              child: Slidable(
                                key: ValueKey(task.id),
                                endActionPane: ActionPane(
                                  motion: const ScrollMotion(),
                                  extentRatio: 0.25,
                                  children: [
                                    SlidableAction(
                                      onPressed: (context) =>
                                          taskProvider.deleteTask(task.id),
                                      backgroundColor: Colors.redAccent,
                                      foregroundColor: Colors.white,
                                      icon: Icons.delete_outline_rounded,
                                      label: 'Xóa',
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius
                                            .zero, // VUÔNG (để khớp với Card)
                                        bottomLeft: Radius
                                            .zero, // VUÔNG (để khớp với Card)
                                        topRight: Radius.circular(20), // TRÒN
                                        bottomRight:
                                            Radius.circular(20), // TRÒN
                                      ),
                                    ),
                                  ],
                                ),
                                child: TaskTile(
                                  task: task,
                                  onCheckboxChanged: (val) =>
                                      taskProvider.toggleTaskStatus(task.id),
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) =>
                                          AddTaskSheet(task: task),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                          childCount: tasks.length,
                        ),
                      ),

                // Padding dưới cùng
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
        ),
      ),
    );
  }
}
