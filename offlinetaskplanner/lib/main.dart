import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; // Import font
import 'core/constants/app_colors.dart';
import 'data/models/task_model.dart';
import 'features/task_manager/logic/task_provider.dart';
import 'features/home/screens/home_screen.dart';

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
      title: 'Simple Task',
      // === THIẾT LẬP THEME SÁNG TINH TẾ ===
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.scaffoldBackground,
        primaryColor: AppColors.primary,

        // Font chữ sạch sẽ (Inter hoặc Roboto)
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),

        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.scaffoldBackground,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: AppColors.textPrimary),
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          background: AppColors.scaffoldBackground,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
