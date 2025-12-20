import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/task_model.dart';
import '../../task_manager/logic/task_provider.dart';
import '../../task_manager/widgets/add_task_sheet.dart';
import '../widgets/task_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            context.read<TaskProvider>().clearSearchQuery();
            Navigator.pop(context);
          },
        ),

        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Tìm công việc...',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            context.read<TaskProvider>().setSearchQuery(value);
          },
        ),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          final tasks = provider.tasks;

          if (tasks.isEmpty) {
            return const Center(
              child: Text(
                'Không tìm thấy công việc phù hợp',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return TaskTile(
                task: task,
                onCheckboxChanged: (val) => provider.toggleTaskStatus(task.id),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => AddTaskSheet(task: task),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
