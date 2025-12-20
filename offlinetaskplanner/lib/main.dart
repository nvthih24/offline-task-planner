import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart'; // Import thêm Provider
import 'data/models/task_model.dart';
import 'providers/task_provider.dart'; // Import file provider vừa tạo
import 'screens/home_screen.dart';
import 'core/constants/app_colors.dart';

const String taskBoxName = 'tasks';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  await Hive.openBox<Task>(taskBoxName);
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => TaskProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Planner',
      theme: ThemeData(
        // Cấu hình màu sắc chung
        primaryColor: AppColors.primary,
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      ),
      home: const HomeScreen(),
    );
  }
}
