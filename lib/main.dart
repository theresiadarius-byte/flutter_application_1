import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/course_provider.dart';
import 'repositories/course_repository.dart';
import 'screens/main_shell.dart';
import 'services/course_service.dart';

// Nama: Theresia Darius | NIM: 2415051116
void main() => runApp(ChangeNotifierProvider(
    create: (_) =>
        CourseProvider(CourseRepository(CourseService()))..loadCourses(),
    child: const MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Course Explorer',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
              backgroundColor: Colors.indigo, foregroundColor: Colors.white),
        ),
        home: const MainShell(),
      );
}