import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/models/task_model.dart'; // Import model vừa tạo

// Đặt tên cho cái hộp chứa dữ liệu
const String taskBoxName = 'tasks';

void main() async {
  // 1. Khởi tạo Hive
  await Hive.initFlutter();

  // 2. Đăng ký Adapter (để Hive hiểu được class Task của bạn)
  Hive.registerAdapter(TaskAdapter());

  // 3. Mở hộp dữ liệu (Load dữ liệu từ ổ cứng lên RAM)
  await Hive.openBox<Task>(taskBoxName);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Tắt chữ Debug góc phải
      title: 'Offline Task Planner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true, // Dùng giao diện Material 3 mới nhất
      ),
      home: const Scaffold(
        body: Center(child: Text("Setup xong Hive rồi nhé!")),
      ),
    );
  }
}
