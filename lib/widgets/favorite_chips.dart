import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';

class FavoriteChips extends StatelessWidget {
  final List<Course> courses;
  const FavoriteChips({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    final cs = context.watch<CourseProvider>();
    final favs = courses.where((c) => cs.isFavorite(c.code)).toList();
    if (favs.isEmpty) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.favorite_border, color: Colors.grey),
          title: Text('Belum ada favorit'),
          subtitle: Text('Ketuk ikon hati pada tab Courses.'),
        ),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        for (final c in favs)
          InputChip(
            avatar: const Icon(Icons.favorite, color: Colors.red, size: 18),
            label: Text(c.title),
            onDeleted: () => context.read<CourseProvider>().toggleFavorite(c.code),
          ),
      ],
    );
  }
}