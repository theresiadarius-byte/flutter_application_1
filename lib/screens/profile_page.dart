import 'package:flutter/material.dart';
import '../constants.dart';
import '../widgets/feedback_form.dart';

class ProfilePage extends StatelessWidget {
  final Map<String, dynamic> student;
  const ProfilePage({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final name = student['name'] as String? ?? studentName;
    final nim = student['nim'] as String? ?? studentId;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const CircleAvatar(
                radius: 50, backgroundImage: AssetImage('assets/images/profile.jpg')),
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
      FeedbackForm(name: name, nim: nim),
    ]);
  }
}