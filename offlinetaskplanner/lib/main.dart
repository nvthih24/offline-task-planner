import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; // Import font
import 'core/constants/app_colors.dart';
import 'data/models/task_model.dart';
import 'features/task_manager/logic/task_provider.dart';
import 'features/home/screens/home_screen.dart';
import 'features/task_manager/logic/theme_provider.dart';

const String taskBoxName = 'tasks';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  await Hive.openBox<Task>(taskBoxName);
  await Hive.openBox('settings');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simple Task',
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      // === THIẾT LẬP THEME SÁNG TINH TẾ ===
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.scaffoldBackground,
        primaryColor: AppColors.primary,
        cardColor: AppColors.cardColor,
        // Font chữ sạch sẽ (Inter hoặc Roboto)
        textTheme: GoogleFonts.nunitoTextTheme().apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        ),

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
            brightness: Brightness.light,
            surface: AppColors.cardColor),
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.scaffoldDark,
        primaryColor: AppColors.primary,
        cardColor: AppColors.cardDark, // Màu thẻ tối
        // Cấu hình chữ cho nền tối
        textTheme: GoogleFonts.nunitoTextTheme().apply(
          bodyColor: AppColors.textPrimaryDark,
          displayColor: AppColors.textPrimaryDark,
        ),
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          surface: AppColors.cardDark,
          background: AppColors.scaffoldDark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
