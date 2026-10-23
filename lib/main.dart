import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/course_provider.dart';
import 'repositories/course_repository.dart';
import 'services/course_service.dart';
import 'temp_get_test.dart';

// Nama: Theresia Darius
// NIM: 2415051116 | Kelas: PTI 5 A

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
      debugShowCheckedModeBanner: true,
      theme: ThemeData(useMaterial3: true),
      // Sementara untuk pengujian Tahap 3.
      home: const GetTestPage(),
    );
  }
}
