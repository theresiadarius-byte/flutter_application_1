import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import '../widgets/error_view.dart';
import 'course_form_page.dart';
import 'courses_page.dart';
import 'favorites_page.dart';
import 'home_page.dart';
import 'profile_page.dart';

// TAHAP 14, 5 & 6: integrasi Course Explorer v2 + loading/empty/error state
// Nama: Theresia Darius | NIM: 2415051116
class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;

  static const _items = [
    (Icons.home_outlined, Icons.home, 'Home'),
    (Icons.school_outlined, Icons.school, 'Courses'),
    (Icons.favorite_border, Icons.favorite, 'Favorit'),
    (Icons.person_outline, Icons.person, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<CourseProvider, bool>((p) => p.isLoading);
    final error = context.select<CourseProvider, String?>((p) => p.error);
    final courses =
        context.select<CourseProvider, List<Course>>((p) => p.courses);
    final student =
        context.select<CourseProvider, Map<String, dynamic>>((p) => p.student);

    // state Loading
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // state Error
    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Course Explorer v2')),
        body: ErrorView(
          message: error,
          onRetry: () => context.read<CourseProvider>().loadCourses(),
        ),
      );
    }

    // state Empty
    if (courses.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Course Explorer v2')),
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            const Text('Data course belum tersedia',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            const Text('$studentId - $studentName',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 16),
            // TAHAP 16: tetap bisa menambah data saat tabel masih kosong
            FilledButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CourseFormPage()),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Course'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => context.read<CourseProvider>().loadCourses(),
              icon: const Icon(Icons.refresh),
              label: const Text('Muat Ulang'),
            ),
          ]),
        ),
      );
    }

    // state Success
    final pages = [
      HomePage(student: student, courses: courses),
      CoursesPage(courses: courses),
      FavoritesPage(courses: courses),
      ProfilePage(student: student),
    ];

    return LayoutBuilder(builder: (context, c) {
      final wide = c.maxWidth >= 840;
      return Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  wide
                      ? 'Course Explorer v2 - Web/Tablet'
                      : 'Course Explorer v2',
                  style: const TextStyle(fontSize: 18)),
              const Text('$studentId - $studentName',
                  style: TextStyle(fontSize: 11, color: Colors.white70)),
            ],
          ),
          actions: [
            // Consumer: hanya badge kecil ini yang rebuild saat favorit berubah
            Consumer<CourseProvider>(builder: (_, cs, __) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(children: [
                  const Icon(Icons.favorite, size: 20, color: Colors.redAccent),
                  const SizedBox(width: 4),
                  Text('${cs.favoriteCount}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ]),
              );
            }),
          ],
        ),
        // TAHAP 6: tombol tambah hanya di tab Courses
        floatingActionButton: index == 1
            ? FloatingActionButton.extended(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CourseFormPage()),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Tambah'),
              )
            : null,
        body: wide
            ? Row(children: [
                NavigationRail(
                  selectedIndex: index,
                  onDestinationSelected: (i) => setState(() => index = i),
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (final e in _items)
                      NavigationRailDestination(
                          icon: Icon(e.$1),
                          selectedIcon: Icon(e.$2),
                          label: Text(e.$3)),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: SafeArea(child: pages[index])),
              ])
            : SafeArea(child: pages[index]),
        bottomNavigationBar: wide
            ? null
            : NavigationBar(
                selectedIndex: index,
                onDestinationSelected: (i) => setState(() => index = i),
                destinations: [
                  for (final e in _items)
                    NavigationDestination(
                        icon: Icon(e.$1),
                        selectedIcon: Icon(e.$2),
                        label: e.$3),
                ],
              ),
      );
    });
  }
}