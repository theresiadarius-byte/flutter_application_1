import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import '../widgets/course_card.dart';
import 'course_detail_page.dart';

// TAHAP 13: halaman yang hanya menampilkan course favorit
// Nama: Theresia Darius | NIM: 2415051116
class FavoritesPage extends StatelessWidget {
  final List<Course> courses;
  const FavoritesPage({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    final cs = context.watch<CourseProvider>();
    final favs = courses.where((c) => cs.isFavorite(c.code)).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Course Favorit',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold, color: Colors.indigo)),
        Text('${favs.length} dari ${courses.length} course | '
            '$studentId - $studentName'),
        const SizedBox(height: 12),
        if (favs.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(children: [
                Icon(Icons.favorite_border, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text('Belum ada favorit',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Ketuk ikon hati pada tab Courses atau halaman detail.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey)),
              ]),
            ),
          )
        else
          for (final c in favs)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SizedBox(
                height: 88,
                child: CourseCard(
                  course: c,
                  isFavorite: true,
                  onFavoriteChanged: () =>
                      context.read<CourseProvider>().toggleFavorite(c.code),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => CourseDetailPage(course: c))),
                ),
              ),
            ),
      ],
    );
  }
}