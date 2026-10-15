import 'package:flutter/material.dart';
import '../models/course.dart';
import 'common.dart';

// CourseCard: data dan aksi (termasuk navigasi) dari parent
class CourseCard extends StatelessWidget {
  final Course course;
  final bool isFavorite;
  final VoidCallback onFavoriteChanged;
  final VoidCallback onTap;
  const CourseCard({
    super.key,
    required this.course,
    required this.isFavorite,
    required this.onFavoriteChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final (label, color) = statusInfo(course.status);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
          child: Row(children: [
            CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(statusIcon(course.status), color: color)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(course.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 6),
                    Wrap(spacing: 6, runSpacing: 4, children: [
                      Tag(course.code, Colors.indigo),
                      Tag('${course.credits} SKS', Colors.deepOrange),
                      Tag(label, color),
                    ]),
                  ]),
            ),
            IconButton(icon: favIcon(isFavorite), onPressed: onFavoriteChanged),
          ]),
        ),
      ),
    );
  }
}

// TAHAP 8: membaca field object Course, bukan Map
class CourseModelCard extends StatelessWidget {
  final Course course;
  const CourseModelCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final (label, color) = statusInfo(course.status);
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(statusIcon(course.status), color: color)),
        title: Text(course.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Wrap(spacing: 6, runSpacing: 4, children: [
            Tag(course.code, Colors.indigo),
            Tag('${course.credits} SKS', Colors.deepOrange),
            Tag(label, color),
          ]),
        ),
      ),
    );
  }
}