import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart'; // Import thêm Provider
import 'data/models/task_model.dart';
import 'providers/task_provider.dart'; // Import file provider vừa tạo
import 'screens/home_screen.dart';
const String taskBoxName = 'tasks';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  await Hive.openBox<Task>(taskBoxName);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Dùng MultiProvider để bọc toàn bộ app
    return MultiProvider(
      providers: [
        // Khởi tạo TaskProvider và gọi luôn hàm getTasks() để load dữ liệu ngay khi mở app
        ChangeNotifierProvider(create: (_) => TaskProvider()..getTasks()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Offline Task Planner',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        // Thay vì hiển thị Text, ta sẽ trỏ tới HomeScreen (sẽ làm ở bước sau)
        home: const HomeScreen(),
      ),
    );
  }
}