import 'package:flutter/material.dart';

/// Key global agar navigasi/snackbar bisa dipanggil dari luar widget
final navigatorKey = GlobalKey<NavigatorState>();
final messengerKey = GlobalKey<ScaffoldMessengerState>();

class AppKeys {
  static const String supabaseUrl = 'https://furlwjwkarynhzacjawq.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ1cmx3andrYXJ5bmh6YWNqYXdxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTMzNjYxNzUsImV4cCI6MjEwODk0MjE3NX0.dG6ENtsG9LJEoke96FEhh1WHWvhtpk0yKbcRPiQXXtU';
}
