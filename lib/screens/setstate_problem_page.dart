import 'package:flutter/material.dart';

const String studentName = 'Theresia Darius';
const String studentId = '2415051116';

// PARENT: pemilik tunggal state favorites
class SetStateProblemPage extends StatefulWidget {
  const SetStateProblemPage({super.key});
  @override
  State<SetStateProblemPage> createState() => _SetStateProblemPageState();
}

class _SetStateProblemPageState extends State<SetStateProblemPage> {
  final Set<String> favorites = {};

  final List<Map<String, String>> courses = [
    {'code': 'PTI101', 'title': 'Pemrograman Mobile'},
    {'code': 'PTI102', 'title': 'Basis Data'},
    {'code': 'PTI103', 'title': 'Rekayasa Perangkat Lunak'},
  ];

  // Callback: child meminta parent mengubah state
  void toggleFavorite(String code) {
    setState(() {
      if (favorites.contains(code)) {
        favorites.remove(code);
      } else {
        favorites.add(code);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tahap 2: Masalah setState')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              '$studentName - $studentId',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          // CHILD 1: daftar course (menerima data + callback)
          Expanded(
            child: CourseListChild(
              courses: courses,
              favorites: favorites,
              onToggle: toggleFavorite,
            ),
          ),
          const Divider(),
          // CHILD 2: ringkasan favorit (menerima data + callback juga)
          FavoriteSummaryChild(favorites: favorites, onToggle: toggleFavorite),
        ],
      ),
    );
  }
}

// CHILD 1 -> meneruskan lagi ke CourseTile (inilah prop drilling)
class CourseListChild extends StatelessWidget {
  final List<Map<String, String>> courses;
  final Set<String> favorites;
  final void Function(String) onToggle;

  const CourseListChild({
    super.key,
    required this.courses,
    required this.favorites,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: courses.length,
      itemBuilder: (context, i) {
        final c = courses[i];
        return CourseTile(
          code: c['code']!,
          title: c['title']!,
          isFavorite: favorites.contains(c['code']),
          onToggle: onToggle, // diteruskan lagi
        );
      },
    );
  }
}

class CourseTile extends StatelessWidget {
  final String code;
  final String title;
  final bool isFavorite;
  final void Function(String) onToggle;

  const CourseTile({
    super.key,
    required this.code,
    required this.title,
    required this.isFavorite,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(code),
      trailing: IconButton(
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? Colors.red : null,
        ),
        onPressed: () => onToggle(code),
      ),
    );
  }
}

class FavoriteSummaryChild extends StatelessWidget {
  final Set<String> favorites;
  final void Function(String) onToggle;

  const FavoriteSummaryChild({
    super.key,
    required this.favorites,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Jumlah favorit: ${favorites.length}'),
          Wrap(
            spacing: 6,
            children: favorites
                .map(
                  (code) =>
                      Chip(label: Text(code), onDeleted: () => onToggle(code)),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
