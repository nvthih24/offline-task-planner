import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/task_model.dart';
import '../../task_manager/logic/task_provider.dart';
import '../../task_manager/widgets/add_task_sheet.dart';
import '../widgets/task_tile.dart'; // Đảm bảo import đúng file task_tile vừa sửa

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Nút thêm việc đơn giản, tròn trịa
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddTaskSheet(),
          );
        },
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),

      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          final tasks = taskProvider.tasks;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. AppBar lớn kiểu iOS/Classic
              SliverAppBar(
                expandedHeight: 120.0,
                floating: false,
                pinned: true,
                backgroundColor: AppColors.background,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  title: Text(
                    "Công Việc Của Tôi",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 22, // Size chữ khi thu nhỏ
                    ),
                  ),
                  background: Container(
                    color: AppColors.background,
                  ), // Nền khi kéo giãn
                ),
              ),

              // 2. Dòng hiển thị ngày tháng
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat.yMMMMEEEEd().format(DateTime.now()),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Bạn có ${tasks.where((t) => !t.isCompleted).length} việc cần làm",
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      // Avatar nhỏ gọn
                      const CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage(
                          "https://i.pravatar.cc/300",
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Danh sách công việc
              tasks.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(
                        child: Text(
                          "Hôm nay rảnh rỗi! 🎉",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final task = tasks[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Slidable(
                            key: ValueKey(task.id),
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (ctx) {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (context) =>
                                          AddTaskSheet(task: task),
                                    );
                                  },
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.blue,
                                  icon: Icons.edit,
                                  label: 'Sửa',
                                ),
                                SlidableAction(
                                  onPressed: (ctx) =>
                                      taskProvider.deleteTask(task.id),
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.red,
                                  icon: Icons.delete,
                                  label: 'Xóa',
                                ),
                              ],
                            ),
                            child: TaskTile(
                              task: task,
                              onCheckboxChanged: (val) {
                                taskProvider.toggleTaskStatus(task.id);
                              },
                            ),
                          ),
                        );
                      }, childCount: tasks.length),
                    ),

              // Padding dưới cùng để không bị nút FAB che mất task cuối
              const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
            ],
          );
        },
      ),
    );
  }
}
