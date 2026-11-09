import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/course_provider.dart';
import 'repositories/course_repository.dart';
import 'services/course_data_source.dart';
import 'services/course_supabase_service.dart';
import 'supabase_config.dart';
import 'screens/login_page.dart';
import 'app_keys.dart';
import 'screens/main_shell.dart';
import 'services/auth_service.dart';

// Nama: Theresia Darius
// NIM: 2415051116 | Kelas: PTI 5 A

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // Mendengarkan perubahan session
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    debugPrint('Auth event: ${data.event}');

    if (data.event == AuthChangeEvent.signedOut) {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const LoginPage(),
        ),
        (route) => false,
      );
    }
  });

  final CourseDataSource dataSource = CourseSupabaseService();
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

      navigatorKey: navigatorKey,
      scaffoldMessengerKey: messengerKey,

  // Check Session -> Login / Home
      home: AuthService.instance.isLoggedIn
        ? const MainShell()
          : const LoginPage(),
    );
  }
}