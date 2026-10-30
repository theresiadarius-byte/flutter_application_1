import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'constants.dart';
import 'providers/course_provider.dart';
import 'repositories/course_repository.dart';
import 'screens/main_shell.dart';
import 'services/course_api_service.dart';
import 'services/course_data_source.dart';
import 'supabase_config.dart';

// Nama: Theresia Darius
// NIM: 2415051116 | Kelas: PTI 5 A

// TAHAP 10: Supabase diinisialisasi sebelum runApp().
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  // service -> repository -> provider
  // TAHAP 9: hanya baris dataSource ini yang berubah saat ganti sumber data.
  final CourseDataSource dataSource = CourseApiService(apiBaseUrl);
  final repository = CourseRepository(dataSource);

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
      home: const MainShell(),
    );
  }
}