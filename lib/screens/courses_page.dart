import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import '../widgets/course_card.dart';
import 'course_detail_page.dart';

class CoursesPage extends StatelessWidget {
  final List<Course> courses;
  const CoursesPage({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    final cs = context.watch<CourseProvider>();
    final cols = MediaQuery.of(context).size.width < 600 ? 1 : 2;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Daftar Mata Kuliah',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold, color: Colors.indigo)),
        Text('${courses.length} course | ${cs.favoriteCount} favorit | '
            '$studentId - $studentName'),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              mainAxisExtent: 88),
          itemCount: courses.length,
          itemBuilder: (context, i) {
            final c = courses[i];
            return CourseCard(
              course: c,
              isFavorite: cs.isFavorite(c.code),
              onFavoriteChanged: () =>
                  context.read<CourseProvider>().toggleFavorite(c.code),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => CourseDetailPage(course: c))),
            );
          },
        ),
      ],
    );
  }
}