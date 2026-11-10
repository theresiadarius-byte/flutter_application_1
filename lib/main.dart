import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_keys.dart';
import 'firebase_options.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase SEBELUM Supabase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inisialisasi Supabase
  await Supabase.initialize(
    url: AppKeys.supabaseUrl,
    anonKey: AppKeys.supabaseAnonKey,
  );

  // Mendengarkan perubahan session auth: jika logout/signedOut otomatis kembali ke LoginPage
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    debugPrint('Auth event: ${data.event}');
    if (data.event == AuthChangeEvent.signedOut) {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  });

  runApp(const KosFinderApp());
}

class KosFinderApp extends StatelessWidget {
  const KosFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KosFinder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: messengerKey,
      // Check Session: jika session tersimpan tampilkan HomePage, jika tidak ke LoginPage
      home: AuthService.instance.isLoggedIn
          ? const HomePage()
          : const LoginPage(),
    );
  }
}
