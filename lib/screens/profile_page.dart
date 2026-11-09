import 'package:flutter/material.dart';
import '../constants.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../widgets/feedback_form.dart';

class ProfilePage extends StatelessWidget {
  final Map<String, dynamic> student;
  final UserProfile? profile;
  const ProfilePage({super.key, required this.student, this.profile});

  @override
  Widget build(BuildContext context) {
    final name = student['name'] as String? ?? studentName;
    final nim = student['nim'] as String? ?? studentId;
    final email =
        profile?.email ?? AuthService.instance.currentUser?.email ?? '-';
    final accountName =
        (profile == null || profile!.name.isEmpty) ? '-' : profile!.name;

    return ListView(padding: const EdgeInsets.all(16), children: [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/images/profile.jpg')),
            const SizedBox(height: 12),
            Text(name,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            Text('NIM: $nim'),
            const Divider(height: 32),
            const ListTile(
                leading: Icon(Icons.school, color: Colors.indigo),
                title: Text('Program Studi'),
                subtitle: Text('Pendidikan Teknik Informatika')),
            const ListTile(
                leading: Icon(Icons.apartment, color: Colors.indigo),
                title: Text('Fakultas'),
                subtitle: Text('Fakultas Teknik dan Kejuruan')),
          ]),
        ),
      ),
      const SizedBox(height: 16),
      // Informasi akun dari Supabase Auth + tabel profiles
      Card(
        child: Column(children: [
          ListTile(
            leading: const Icon(Icons.person, color: Colors.indigo),
            title: const Text('Nama'),
            subtitle: Text(accountName),
          ),
          ListTile(
            leading: const Icon(Icons.email, color: Colors.indigo),
            title: const Text('Email'),
            subtitle: Text(email),
          ),
          ListTile(
            leading: const Icon(Icons.badge, color: Colors.indigo),
            title: const Text('Role'),
            subtitle: Text(profile?.role ?? 'memuat...'),
          ),
        ]),
      ),
      const SizedBox(height: 16),
      FeedbackForm(name: name, nim: nim),
    ]);
  }
}