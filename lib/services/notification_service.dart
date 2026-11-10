import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../app_keys.dart';
import '../firebase_options.dart';

/// Top-level background message handler untuk kondisi Background dan Terminated.
/// Harus berada di luar class dan ditandai dengan @pragma('vm:entry-point').
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('[BACKGROUND] ${message.notification?.title}');
  debugPrint('[BACKGROUND] ${message.notification?.body}');
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Meminta izin notifikasi ke sistem operasi dan mengembalikan statusnya:
  /// authorized | provisional | denied | notDetermined
  Future<AuthorizationStatus> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('Notification permission: ${settings.authorizationStatus.name}');
    return settings.authorizationStatus;
  }

  /// Mendapatkan token FCM identifier unik perangkat ini
  Future<String?> getToken() async {
    final token = await _messaging.getToken();
    debugPrint('FCM Token: $token');
    return token;
  }

  /// Mendengarkan pembaruan token FCM secara berkala
  void listenTokenRefresh(void Function(String token) onRefresh) {
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('FCM Token diperbarui');
      onRefresh(newToken);
    });
  }

  /// Opsional: Menyimpan token perangkat ke tabel device_tokens di Supabase
  Future<void> saveTokenToSupabase(String token) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      await Supabase.instance.client.from('device_tokens').upsert({
        'token': token,
        'user_id': user.id,
        'platform': defaultTargetPlatform.name,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
      debugPrint('FCM Token berhasil disimpan ke Supabase');
    } catch (e) {
      debugPrint('Gagal menyimpan token ke Supabase: $e');
    }
  }

  /// Menginisialisasi seluruh alur notifikasi:
  /// izin, token, simpan database, serta penanganan pesan Foreground & Background.
  Future<void> init() async {
    await requestPermission();
    final token = await getToken();
    if (token != null) {
      await saveTokenToSupabase(token);
    }
    listenTokenRefresh(saveTokenToSupabase);

    // iOS: tampilkan banner saat aplikasi di foreground
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // FOREGROUND: aplikasi sedang aktif di layar
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[FOREGROUND] Notification received');
      debugPrint('title: ${message.notification?.title}');
      debugPrint('body : ${message.notification?.body}');
      debugPrint('data : ${message.data}');

      // Android secara default tidak menampilkan banner notifikasi di status bar
      // saat aplikasi berada di foreground, jadi tampilkan di dalam aplikasi lewat SnackBar.
      final title = message.notification?.title ?? 'Notifikasi KosFinder';
      final body = message.notification?.body ?? '';

      messengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('$title\n$body'),
          backgroundColor: Colors.indigo,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    });
  }
}
