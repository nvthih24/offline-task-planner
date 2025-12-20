import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
// Giữ nguyên các đường dẫn import theo đúng cấu trúc GitHub của Người
import '../data/models/task_model.dart';
import '../providers/task_provider.dart';
import '../widgets/add_task_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Công Việc Của Tôi',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            Text('Hôm nay là ngày khởi đầu mới',
                style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () {
              // Tính năng tìm kiếm sẽ làm sau
            },
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          final tasks = taskProvider.tasks;

          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_add, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text("Hoàng thượng chưa có chỉ dụ nào!",
                      style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return _buildTaskItem(context, task, taskProvider);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddTaskSheet(),
          );
        },
        label: const Text('Thêm việc'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, Task task, TaskProvider provider) {
    // Dùng DateFormat từ package intl để format ngày tháng
    String formattedDate = DateFormat('dd/MM HH:mm').format(task.date);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        key: ValueKey(task.id),

        // === THAY ĐỔI CHÍNH TẠI ĐÂY ===
        // 1. startActionPane: VUỐT TỪ TRÁI SANG PHẢI (->)
        // Gom cả nút Sửa và Xóa vào đây
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.5, // Chiếm 50% chiều rộng để đủ chỗ cho 2 nút
          children: [
             // NÚT SỬA (Màu Xanh)
             SlidableAction(
              onPressed: (context) {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => AddTaskSheet(task: task),
                );
              },
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Sửa',
              // Bo góc trái cho đẹp
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
            ),

            // NÚT XÓA (Màu Đỏ)
            SlidableAction(
              onPressed: (context) {
                provider.deleteTask(task.id);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Đã trảm công việc!"), duration: Duration(seconds: 1)));
              },
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Xóa',
              // Không cần bo góc bên phải vì nó nằm giữa card và mép màn hình khi vuốt
            ),
          ],
        ),

        // 2. endActionPane: BỎ TRỐNG (Không vuốt từ phải sang trái nữa)
        endActionPane: null,

        // === NỘI DUNG CARD (GIỮ NGUYÊN) ===
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border(
              left: BorderSide(
                color: _getPriorityColor(task.colorIndex), 
                width: 6,
              ),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Checkbox(
              value: task.isCompleted,
              activeColor: _getPriorityColor(task.colorIndex),
              onChanged: (value) {
                provider.toggleTaskStatus(task.id);
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            title: Text(
              task.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                color: task.isCompleted ? Colors.grey : Colors.black87,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (task.note.isNotEmpty)
                  Text(
                    task.note,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(
                      formattedDate,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(int index) {
    switch (index) {
      case 0: return Colors.blue;
      case 1: return Colors.orange;
      case 2: return Colors.red;
      case 3: return Colors.green;
      default: return Colors.blue;
    }
  }
}