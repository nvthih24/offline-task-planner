import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/task_model.dart';
import '../../task_manager/logic/task_provider.dart';
import '../../task_manager/widgets/add_task_sheet.dart';
import '../widgets/task_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        bottom: false,
        child: Consumer<TaskProvider>(
          builder: (context, taskProvider, child) {
            final tasks = taskProvider.tasks;
            final activeTasks = tasks.where((t) => !t.isCompleted).length;

            return Column(
              children: [
                // 1. PHẦN HEADER TÙY CHỈNH
                Padding(
                  padding: const EdgeInsets.all(24.0),
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
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              activeTasks > 0
                                  ? "Bạn có $activeTasks việc cần làm"
                                  : "Mọi việc đã hoàn tất! 🎉",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // --- NÚT TÌM KIẾM MỚI ---
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () {}, // nhớ
                          icon: const Icon(
                            Icons.search_rounded,
                            color: AppColors.primary,
                          ),
                          tooltip: 'Tìm kiếm',
                        ),
                      ),
                      // Ngày tháng hiện tại trong 1 cái box nhỏ xinh
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              DateFormat('d').format(DateTime.now()),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              DateFormat(
                                'MMM',
                              ).format(DateTime.now()).toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. DANH SÁCH CÔNG VIỆC
                Expanded(
                  child: tasks.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            24,
                            0,
                            24,
                            100,
                          ), // Padding dưới để tránh FAB
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return Slidable(
                              key: ValueKey(task.id),
                              endActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                extentRatio: 0.25,
                                children: [
                                  SlidableAction(
                                    onPressed: (context) {
                                      taskProvider.deleteTask(task.id);
                                    },
                                    backgroundColor:
                                        AppColors.scaffoldBackground,
                                    foregroundColor: Colors.red,
                                    icon: Icons.delete_outline_rounded,
                                    label: 'Xóa',
                                    borderRadius: BorderRadius.circular(16),
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
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),

      // 3. NÚT ADD MỚI (Nổi bật nhưng không thô)
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
          label: const Text(
            "Thêm Việc",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.checklist_rtl_rounded,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            "Danh sách trống trơn",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Hãy thêm công việc mới để bắt đầu!",
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
