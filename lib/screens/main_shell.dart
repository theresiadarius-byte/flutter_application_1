import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import 'courses_page.dart';
import 'home_page.dart';
import 'profile_page.dart';

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
    (Icons.person_outline, Icons.person, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<CourseProvider, bool>((p) => p.isLoading);
    final error = context.select<CourseProvider, String?>((p) => p.error);
    final courses = context.select<CourseProvider, List<Course>>((p) => p.courses);
    final student =
        context.select<CourseProvider, Map<String, dynamic>>((p) => p.student);

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Course Explorer')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              const Text('Gagal memuat data course',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text(error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 4),
              const Text('$studentId - $studentName',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => context.read<CourseProvider>().loadCourses(),
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ]),
          ),
        ),
      );
    }

    final pages = [
      HomePage(student: student, courses: courses),
      CoursesPage(courses: courses),
      ProfilePage(student: student),
    ];

    return LayoutBuilder(builder: (context, c) {
      final wide = c.maxWidth >= 840;
      return Scaffold(
        appBar: AppBar(
          title: Text(wide ? 'Course Explorer - Web/Tablet' : 'Course Explorer'),
          actions: [
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