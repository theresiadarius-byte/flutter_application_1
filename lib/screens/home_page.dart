import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import '../widgets/common.dart';
import '../widgets/course_card.dart';
import '../widgets/demo_widgets.dart';
import '../widgets/favorite_chips.dart';

class HomePage extends StatelessWidget {
  final Map<String, dynamic> student;
  final List<Course> courses;
  const HomePage({super.key, required this.student, required this.courses});

  @override
  Widget build(BuildContext context) {
    final cs = context.watch<CourseProvider>();
    final sks = courses.fold<int>(0, (s, c) => s + c.credits);
    final name = student['name'] as String? ?? studentName;
    final nim = student['nim'] as String? ?? studentId;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Colors.indigo, Color(0xFF5C6BC0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(children: [
            const CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, color: Colors.white, size: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Selamat Datang,',
                    style: TextStyle(color: Colors.white70)),
                Text(name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                Text('NIM: $nim', style: const TextStyle(color: Colors.white70)),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 20),
        const SectionTitle('Ringkasan Pembelajaran'),
        Row(children: [
          Expanded(child: SummaryCard(Icons.menu_book, 'Courses', '${courses.length}')),
          const SizedBox(width: 8),
          Expanded(child: SummaryCard(Icons.school, 'Total SKS', '$sks')),
          const SizedBox(width: 8),
          Expanded(
              child: SummaryCard(Icons.favorite, 'Favorit', '${cs.favoriteCount}',
                  color: Colors.red)),
        ]),
        const SizedBox(height: 20),
        const SectionTitle('Favorit Saya'),
        FavoriteChips(courses: courses),
        const SizedBox(height: 20),
        const SectionTitle('Course Pertama (dari model Course)'),
        CourseModelCard(course: courses.first),
        const SizedBox(height: 20),
        const DetailToggle(),
        const SizedBox(height: 8),
        const Card(
          clipBehavior: Clip.antiAlias,
          child: ExpansionTile(
            shape: Border(),
            collapsedShape: Border(),
            leading: Icon(Icons.science, color: Colors.indigo),
            title: Text('Tahap 4: ValueNotifier'),
            childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [ValueNotifierDemo()],
          ),
        ),
      ],
    );
  }
}