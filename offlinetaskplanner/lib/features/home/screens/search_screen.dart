import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;
    final hintColor =
        Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5);
    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: cardColor,
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
          decoration: InputDecoration(
            hintText: 'Tìm công việc...',
            border: InputBorder.none,
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: hintColor),
                    onPressed: () {
                      _controller.clear();
                      context.read<TaskProvider>().setSearchQuery('');
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            context.read<TaskProvider>().setSearchQuery(value);
            setState(() {});
          },
        ),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          final tasks = provider.tasks;

          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded, size: 60, color: hintColor),
                  const SizedBox(height: 10),
                  Text(
                    'Không tìm thấy công việc phù hợp',
                    style: TextStyle(color: hintColor, fontSize: 16),
                  ),
                ],
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
