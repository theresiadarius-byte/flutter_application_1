import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

const String studentName = 'Theresia Darius';
const String studentId = '2415051116';

Future<Map<String, dynamic>> loadData() async => jsonDecode(
    await rootBundle.loadString('assets/data/student_data.json'));

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Course Explorer',
        theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
            useMaterial3: true),
        home: const MainShell(),
      );
}

// ---------------------------------------------------------------- SHELL
class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;
  late final Future<Map<String, dynamic>> future = loadData();

  // TAHAP 3: single source of truth untuk favorit
  final Set<String> favorites = {};
  void toggleFavorite(String code) => setState(() {
        favorites.contains(code) ? favorites.remove(code) : favorites.add(code);
      });

  static const _items = [
    (Icons.home_outlined, Icons.home, 'Home'),
    (Icons.school_outlined, Icons.school, 'Courses'),
    (Icons.person_outline, Icons.person, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snap.hasError || !snap.hasData) {
          return const Scaffold(
              body: Center(child: Text('Gagal memuat data course')));
        }
        final student = snap.data!['student'] as Map<String, dynamic>;
        final courses = (snap.data!['courses'] as List).cast<Map<String, dynamic>>();
        final pages = [
          HomePage(courses: courses, favorites: favorites, onToggle: toggleFavorite),
          CoursesPage(
              student: student,
              courses: courses,
              favorites: favorites,
              onToggle: toggleFavorite),
          ProfilePage(student: student),
        ];

        return LayoutBuilder(builder: (context, c) {
          final wide = c.maxWidth >= 840;
          return Scaffold(
            appBar: AppBar(
              title: Text(wide ? 'Course Explorer - Web/Tablet' : 'Course Explorer'),
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
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
      },
    );
  }
}

// ---------------------------------------------------------------- HOME
class HomePage extends StatelessWidget {
  final List<Map<String, dynamic>> courses;
  final Set<String> favorites;
  final void Function(String) onToggle;
  const HomePage(
      {super.key,
      required this.courses,
      required this.favorites,
      required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final sks = courses.fold<int>(0, (s, c) => s + (c['credits'] as int));
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: Colors.indigo,
          child: const ListTile(
            title: Text('Selamat Datang,',
                style: TextStyle(color: Colors.white70)),
            subtitle: Text('$studentName\nNIM: $studentId',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            isThreeLine: true,
          ),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: SummaryCard(Icons.menu_book, 'Courses', '${courses.length}')),
          const SizedBox(width: 12),
          Expanded(child: SummaryCard(Icons.school, 'Total SKS', '$sks')),
        ]),
        const SizedBox(height: 12),
        const DetailToggle(),
        const SizedBox(height: 12),
        FavoritePanel(courses: courses, favorites: favorites, onToggle: onToggle),
        const SizedBox(height: 12),
        ValueNotifierDemo(initialFavorites: favorites.length),
      ],
    );
  }
}

class SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title, value;
  const SummaryCard(this.icon, this.title, this.value, {super.key});
  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Icon(icon, color: Colors.indigo),
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            Text(title),
          ]),
        ),
      );
}

// TAHAP 1: local state
class DetailToggle extends StatefulWidget {
  const DetailToggle({super.key});
  @override
  State<DetailToggle> createState() => _DetailToggleState();
}

class _DetailToggleState extends State<DetailToggle> {
  bool show = false;
  @override
  Widget build(BuildContext context) => Card(
        child: Column(children: [
          ListTile(
            leading: const Icon(Icons.person, color: Colors.indigo),
            title: const Text('Info Mahasiswa'),
            trailing: Icon(show ? Icons.expand_less : Icons.expand_more),
            onTap: () => setState(() => show = !show),
          ),
          if (show)
            const Padding(
                padding: EdgeInsets.all(12),
                child: Text('$studentId - $studentName')),
        ]),
      );
}

// TAHAP 3: stateless, state dimiliki MainShell
class FavoritePanel extends StatelessWidget {
  final List<Map<String, dynamic>> courses;
  final Set<String> favorites;
  final void Function(String) onToggle;
  const FavoritePanel(
      {super.key,
      required this.courses,
      required this.favorites,
      required this.onToggle});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Tahap 3: Favorit (lifting state up)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            for (final c in courses)
              ListTile(
                dense: true,
                title: Text(c['title'] as String),
                trailing: IconButton(
                  icon: favIcon(favorites.contains(c['code'])),
                  onPressed: () => onToggle(c['code'] as String),
                ),
              ),
            const Divider(),
            Text('Total favorit: ${favorites.length} | $studentId - $studentName'),
          ]),
        ),
      );
}

Icon favIcon(bool fav) => Icon(fav ? Icons.favorite : Icons.favorite_border,
    color: fav ? Colors.red : Colors.grey);

// TAHAP 4: ValueNotifier
class ValueNotifierDemo extends StatefulWidget {
  final int initialFavorites;
  const ValueNotifierDemo({super.key, required this.initialFavorites});
  @override
  State<ValueNotifierDemo> createState() => _ValueNotifierDemoState();
}

class _ValueNotifierDemoState extends State<ValueNotifierDemo> {
  late final count = ValueNotifier<int>(widget.initialFavorites);
  int setStateCount = 0, parentBuilds = 0, builderBuilds = 0;

  @override
  void dispose() {
    count.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    parentBuilds++;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Tahap 4: ValueNotifier',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const Text('$studentId - $studentName', style: TextStyle(fontSize: 12)),
          const Divider(),
          ValueListenableBuilder<int>(
            valueListenable: count,
            builder: (_, v, __) {
              builderBuilds++;
              return Text('ValueNotifier: $v (builder dibuild $builderBuilds x)');
            },
          ),
          Row(children: [
            IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  if (count.value > 0) count.value--;
                }),
            IconButton(icon: const Icon(Icons.add), onPressed: () => count.value++),
          ]),
          const Divider(),
          Text('setState: $setStateCount'),
          ElevatedButton(
              onPressed: () => setState(() => setStateCount++),
              child: const Text('Tambah (setState)')),
          Text('Parent dibuild: $parentBuilds x',
              style: const TextStyle(color: Colors.grey)),
        ]),
      ),
    );
  }
}

// ---------------------------------------------------------------- COURSES
class CoursesPage extends StatelessWidget {
  final Map<String, dynamic> student;
  final List<Map<String, dynamic>> courses;
  final Set<String> favorites;
  final void Function(String) onToggle;
  const CoursesPage(
      {super.key,
      required this.student,
      required this.courses,
      required this.favorites,
      required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final cols = w < 600 ? 1 : 2;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Daftar Mata Kuliah',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold, color: Colors.indigo)),
        const SizedBox(height: 8),
        Text('Layar ${w.toStringAsFixed(0)} px | $cols kolom'),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: cols,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: cols == 1 ? 4 : 3.2,
          children: [
            for (final c in courses)
              CourseCard(
                course: c,
                isFavorite: favorites.contains(c['code']),
                onFavoriteChanged: () => onToggle(c['code'] as String),
              ),
          ],
        ),
      ],
    );
  }
}

// TAHAP 3: stateless, tanpa state favorit lokal
class CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final bool isFavorite;
  final VoidCallback onFavoriteChanged;
  const CourseCard(
      {super.key,
      required this.course,
      required this.isFavorite,
      required this.onFavoriteChanged});

  IconData get statusIcon => switch (course['status']) {
        'done' => Icons.check_circle,
        'active' => Icons.play_circle,
        _ => Icons.schedule,
      };

  @override
  Widget build(BuildContext context) {
    final title = course['title'] as String? ?? '';
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push<bool>(context,
              MaterialPageRoute(builder: (_) => CourseDetailPage(course: course)));
          if (result == true && !isFavorite) onFavoriteChanged();
        },
        child: ListTile(
          leading: Icon(statusIcon, color: Colors.indigo),
          title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text('${course['code']} | ${course['credits']} SKS'),
          trailing: IconButton(
            icon: favIcon(isFavorite),
            onPressed: onFavoriteChanged,
          ),
        ),
      ),
    );
  }
}

class CourseDetailPage extends StatelessWidget {
  final Map<String, dynamic> course;
  const CourseDetailPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: Text(course['title'] as String? ?? ''),
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          const Card(
              child: ListTile(
                  leading: Icon(Icons.person, color: Colors.indigo),
                  title: Text('$studentId - $studentName'))),
          Card(
            child: Column(children: [
              ListTile(title: const Text('Kode'), subtitle: Text('${course['code']}')),
              ListTile(
                  title: const Text('SKS'), subtitle: Text('${course['credits']} SKS')),
              ListTile(
                  title: const Text('Kategori'),
                  subtitle: Text('${course['category']}')),
            ]),
          ),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            OutlinedButton.icon(
                onPressed: () => Navigator.pop(context, false),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Kembali')),
            ElevatedButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.favorite, color: Colors.red),
                label: const Text('Tandai Favorit')),
          ]),
        ]),
      );
}

// ---------------------------------------------------------------- PROFILE
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

class FeedbackForm extends StatefulWidget {
  final String name, nim;
  const FeedbackForm({super.key, required this.name, required this.nim});
  @override
  State<FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  final formKey = GlobalKey<FormState>();
  late final nameC = TextEditingController(text: widget.name);
  late final nimC = TextEditingController(text: widget.nim);
  final commentC = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    nameC.dispose();
    nimC.dispose();
    commentC.dispose();
    super.dispose();
  }

  String? required(String? v, String label) =>
      (v == null || v.trim().isEmpty) ? '$label wajib diisi' : null;

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Pengiriman'),
        content: Text('Kirim feedback sebagai ${widget.name} (${widget.nim})?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true), child: const Text('Kirim')),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => loading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => loading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Feedback dari ${nameC.text} berhasil disimpan!'),
        backgroundColor: Colors.green));
    commentC.clear();
  }

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(children: [
              TextFormField(
                  controller: nameC,
                  decoration: const InputDecoration(
                      labelText: 'Nama Mahasiswa', border: OutlineInputBorder()),
                  validator: (v) => required(v, 'Nama')),
              const SizedBox(height: 12),
              TextFormField(
                  controller: nimC,
                  decoration: const InputDecoration(
                      labelText: 'NIM', border: OutlineInputBorder()),
                  validator: (v) => required(v, 'NIM')),
              const SizedBox(height: 12),
              TextFormField(
                controller: commentC,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: 'Komentar', border: OutlineInputBorder()),
                validator: (v) =>
                    required(v, 'Komentar') ??
                    (v!.trim().length < 5 ? 'Komentar minimal 5 karakter' : null),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: loading ? null : submit,
                child: loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5))
                    : const Text('Kirim Feedback'),
              ),
            ]),
          ),
        ),
      );
}