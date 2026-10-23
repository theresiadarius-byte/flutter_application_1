import 'package:flutter/material.dart';

import '../models/course.dart';

// Nama: Theresia Darius
// NIM: 2415051116 | Kelas: PTI 5 A

class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onFavoriteChanged;

  const CourseCard({
    super.key,
    required this.course,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteTap,
    this.onFavoriteChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Mendukung kedua nama callback agar kompatibel
    // dengan halaman yang sudah ada.
    final favoriteCallback = onFavoriteChanged ?? onFavoriteTap;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          child: Text(
            course.code.isNotEmpty
                ? course.code.substring(0, 1).toUpperCase()
                : 'C',
          ),
        ),
        title: Text(course.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Kode: ${course.code}'),
              Text('SKS: ${course.credits}'),
              const SizedBox(height: 4),
              Chip(
                label: Text(course.status),
                visualDensity: VisualDensity.compact,
              ),
              if (course.category.isNotEmpty)
                Text('Kategori: ${course.category}'),
            ],
          ),
        ),
        isThreeLine: true,
        trailing: favoriteCallback == null
            ? null
            : IconButton(
                tooltip: isFavorite
                    ? 'Hapus dari favorit'
                    : 'Tambahkan ke favorit',
                onPressed: favoriteCallback,
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
              ),
      ),
    );
  }
}

class CourseModelCard extends StatelessWidget {
  final Course course;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onFavoriteChanged;

  const CourseModelCard({
    super.key,
    required this.course,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteTap,
    this.onFavoriteChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CourseCard(
      course: course,
      onTap: onTap,
      isFavorite: isFavorite,
      onFavoriteTap: onFavoriteTap,
      onFavoriteChanged: onFavoriteChanged,
    );
  }
}
