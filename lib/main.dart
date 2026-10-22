import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/course_provider.dart';
import 'repositories/course_repository.dart';
import 'screens/main_shell.dart';
import 'services/course_service.dart';

// Nama: Theresia Darius | NIM: 2415051116

void main() {
  final repository = CourseRepository(CourseService());
  runApp(
    ChangeNotifierProvider(
      create: (_) => CourseProvider(repository)..loadCourses(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Course Explorer',
      theme: ThemeData(useMaterial3: true),
      home: const MainShell(),
    );
  }
}
