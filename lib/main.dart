import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'course_provider.dart';
import 'models/course.dart';

const String studentName = 'Theresia Darius';
const String studentId = '2415051116';

Future<Map<String, dynamic>> loadStudentData() async => jsonDecode(
    await rootBundle.loadString('assets/data/student_data.json'));

// TAHAP 6: Provider di root | Nama: Theresia Darius | NIM: 2415051116
void main() => runApp(ChangeNotifierProvider(
    create: (_) => CourseProvider(), child: const MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Course Explorer',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
              backgroundColor: Colors.indigo, foregroundColor: Colors.white),
        ),
        home: const MainShell(),
      );
}

// ------------------------------------------------------------------ HELPERS
Icon favIcon(bool fav) => Icon(fav ? Icons.favorite : Icons.favorite_border,
    color: fav ? Colors.red : Colors.grey);

(String, Color) statusInfo(String? s) => switch (s) {
      'done' => ('Selesai', Colors.green),
      'active' => ('Berjalan', Colors.orange),
      _ => ('Belum', Colors.blueGrey),
    };

IconData statusIcon(String? s) => switch (s) {
      'done' => Icons.check_circle,
      'active' => Icons.play_circle,
      _ => Icons.schedule,
    };

class Tag extends StatelessWidget {
  final String text;
  final Color color;
  const Tag(this.text, this.color, {super.key});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(text,
            style: TextStyle(
                fontSize: 11, color: color, fontWeight: FontWeight.w600)),
      );
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
      );
}

// ------------------------------------------------------------------ SHELL
class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;
  late final Future<Map<String, dynamic>> future = loadStudentData();

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
        final courses = snap.data!['courses'] as List<dynamic>;
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
                // TAHAP 7: Consumer hanya membangun ulang badge kecil ini
                Consumer<CourseProvider>(builder: (_, cs, __) {
                  debugPrint('[$studentId] build Consumer badge AppBar');
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
      },
    );
  }
}

// ------------------------------------------------------------------ HOME
class HomePage extends StatelessWidget {
  final Map<String, dynamic> student;
  final List<dynamic> courses;
  const HomePage({super.key, required this.student, required this.courses});

  @override
  Widget build(BuildContext context) {
    // TAHAP 7: watch() -> halaman ini rebuild saat favorit berubah
    final cs = context.watch<CourseProvider>();
    final sks = courses.fold<int>(0, (s, c) => s + (c['credits'] as int));
    final name = student['name'] as String? ?? studentName;
    final nim = student['nim'] as String? ?? studentId;
    // TAHAP 8: satu data JSON diubah menjadi object Course
    final featured = Course.fromJson(courses.first as Map<String, dynamic>);

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
        CourseModelCard(course: featured),
        const SizedBox(height: 20),
        const DetailToggle(),
        const SizedBox(height: 8),
        // TAHAP 4: eksperimen kecil, dilipat agar Home tetap bersih
        const Card(
          child: ExpansionTile(
            leading: Icon(Icons.science, color: Colors.indigo),
            title: Text('Eksperimen Praktikum (Tahap 4)'),
            childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [ValueNotifierDemo()],
          ),
        ),
      ],
    );
  }
}

class SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title, value;
  final Color color;
  const SummaryCard(this.icon, this.title, this.value,
      {super.key, this.color = Colors.indigo});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(children: [
            Icon(icon, color: color),
            const SizedBox(height: 6),
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(fontSize: 12)),
          ]),
        ),
      );
}

// TAHAP 3 + 7: daftar favorit membaca provider yang sama dengan halaman Courses
class FavoriteChips extends StatelessWidget {
  final List<dynamic> courses;
  const FavoriteChips({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    final cs = context.watch<CourseProvider>();
    final favs = courses.where((c) => cs.isFavorite(c['code'] as String)).toList();
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
            label: Text('${c['title']}'),
            onDeleted: () =>
                context.read<CourseProvider>().toggleFavorite(c['code'] as String),
          ),
      ],
    );
  }
}

// TAHAP 8: widget membaca field object Course, bukan Map
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
            leading: const Icon(Icons.badge, color: Colors.indigo),
            title: const Text('Info Mahasiswa'),
            trailing: Icon(show ? Icons.expand_less : Icons.expand_more),
            onTap: () => setState(() => show = !show),
          ),
          if (show)
            const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('$studentId - $studentName'))),
        ]),
      );
}

// TAHAP 4: ValueNotifier vs setState, dua counter berdampingan
class ValueNotifierDemo extends StatefulWidget {
  const ValueNotifierDemo({super.key});
  @override
  State<ValueNotifierDemo> createState() => _ValueNotifierDemoState();
}

class _ValueNotifierDemoState extends State<ValueNotifierDemo> {
  final counter = ValueNotifier<int>(0);
  int setStateCount = 0;
  int parentBuilds = 0;

  @override
  void dispose() {
    counter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    parentBuilds++;
    final big = Theme.of(context)
        .textTheme
        .headlineMedium
        ?.copyWith(fontWeight: FontWeight.bold);
    return Column(children: [
      const Text('$studentId - $studentName', style: TextStyle(fontSize: 12)),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
          child: Column(children: [
            const Text('ValueNotifier'),
            ValueListenableBuilder<int>(
              valueListenable: counter,
              builder: (_, v, __) => Text('$v', style: big),
            ),
            IconButton.filledTonal(
                icon: const Icon(Icons.add), onPressed: () => counter.value++),
          ]),
        ),
        Expanded(
          child: Column(children: [
            const Text('setState'),
            Text('$setStateCount', style: big),
            IconButton.filledTonal(
                icon: const Icon(Icons.add),
                onPressed: () => setState(() => setStateCount++)),
          ]),
        ),
      ]),
      const SizedBox(height: 8),
      Text(
          'Widget induk dibuild $parentBuilds x. Tombol ValueNotifier tidak menambahnya, '
          'tombol setState menambahnya.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: Colors.grey)),
    ]);
  }
}

// ------------------------------------------------------------------ COURSES
class CoursesPage extends StatelessWidget {
  final List<dynamic> courses;
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
            final c = courses[i] as Map<String, dynamic>;
            final code = c['code'] as String;
            return CourseCard(
              course: c,
              isFavorite: cs.isFavorite(code),
              // TAHAP 7: read() untuk aksi, tanpa listen
              onFavoriteChanged: () =>
                  context.read<CourseProvider>().toggleFavorite(code),
            );
          },
        ),
      ],
    );
  }
}

// TAHAP 3: tanpa state favorit lokal, data dan aksi dari parent
class CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final bool isFavorite;
  final VoidCallback onFavoriteChanged;
  const CourseCard(
      {super.key,
      required this.course,
      required this.isFavorite,
      required this.onFavoriteChanged});

  @override
  Widget build(BuildContext context) {
    final (label, color) = statusInfo(course['status'] as String?);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => CourseDetailPage(course: course))),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
          child: Row(children: [
            CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(statusIcon(course['status'] as String?), color: color)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${course['title']}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 6),
                    Wrap(spacing: 6, runSpacing: 4, children: [
                      Tag('${course['code']}', Colors.indigo),
                      Tag('${course['credits']} SKS', Colors.deepOrange),
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

class CourseDetailPage extends StatelessWidget {
  final Map<String, dynamic> course;
  const CourseDetailPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final code = course['code'] as String;
    final isFav = context.watch<CourseProvider>().isFavorite(code);
    final (label, color) = statusInfo(course['status'] as String?);

    Widget row(IconData icon, String title, String value) => ListTile(
          leading: Icon(icon, color: Colors.indigo),
          title: Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          subtitle: Text(value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Course')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${course['title']}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold, color: Colors.indigo)),
              const SizedBox(height: 8),
              Wrap(spacing: 6, children: [Tag(code, Colors.indigo), Tag(label, color)]),
            ]),
          ),
        ),
        Card(
          child: Column(children: [
            row(Icons.code, 'Kode Mata Kuliah', code),
            row(Icons.credit_card, 'Jumlah SKS', '${course['credits']} SKS'),
            row(Icons.category, 'Kategori', '${course['category']}'),
          ]),
        ),
        const SizedBox(height: 8),
        Text('$studentId - $studentName',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => context.read<CourseProvider>().toggleFavorite(code),
          icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
          label: Text(isFav ? 'Hapus dari Favorit' : 'Tandai Favorit'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          label: const Text('Kembali'),
        ),
      ]),
    );
  }
}

// ------------------------------------------------------------------ PROFILE
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

  String? _req(String? v, String label) =>
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
          FilledButton(
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
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating));
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
                      labelText: 'Nama Mahasiswa',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder()),
                  validator: (v) => _req(v, 'Nama')),
              const SizedBox(height: 12),
              TextFormField(
                  controller: nimC,
                  decoration: const InputDecoration(
                      labelText: 'NIM',
                      prefixIcon: Icon(Icons.badge),
                      border: OutlineInputBorder()),
                  validator: (v) => _req(v, 'NIM')),
              const SizedBox(height: 12),
              TextFormField(
                controller: commentC,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: 'Komentar',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.comment),
                    border: OutlineInputBorder()),
                validator: (v) =>
                    _req(v, 'Komentar') ??
                    (v!.trim().length < 5 ? 'Komentar minimal 5 karakter' : null),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: loading ? null : submit,
                  icon: loading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.send),
                  label: const Text('Kirim Feedback'),
                ),
              ),
            ]),
          ),
        ),
      );
}