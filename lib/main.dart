import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

// Identitas Mahasiswa
const String studentName = 'Theresia Darius';
const String studentId = '2415051116';

Future<Map<String, dynamic>> loadStudentData() async {
  final jsonString = await rootBundle.loadString(
    'assets/data/student_data.json',
  );
  return jsonDecode(jsonString) as Map<String, dynamic>;
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Course Explorer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const MainShell(),
    );
  }
}

// -----------------------------------------------------------------------------
// RESPONSIVE SHELL (Adaptive Navigation: NavigationBar vs NavigationRail)
// -----------------------------------------------------------------------------
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  late Future<Map<String, dynamic>> _studentFuture;

  @override
  void initState() {
    super.initState();
    _studentFuture = loadStudentData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _studentFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text('Gagal memuat data course')),
          );
        }

        final data = snapshot.data!;
        final student = data['student'] as Map<String, dynamic>;
        final courses = data['courses'] as List<dynamic>;

        final List<Widget> pages = [
          HomePage(student: student, courses: courses),
          CoursesPage(student: student, courses: courses),
          ProfilePage(student: student),
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            final isExpanded = constraints.maxWidth >= 840;

            if (isExpanded) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Course Explorer - Web/Tablet'),
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                body: Row(
                  children: [
                    NavigationRail(
                      selectedIndex: _selectedIndex,
                      onDestinationSelected: (index) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      labelType: NavigationRailLabelType.all,
                      destinations: const [
                        NavigationRailDestination(
                          icon: Icon(Icons.home_outlined),
                          selectedIcon: Icon(Icons.home),
                          label: Text('Home'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.school_outlined),
                          selectedIcon: Icon(Icons.school),
                          label: Text('Courses'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.person_outline),
                          selectedIcon: Icon(Icons.person),
                          label: Text('Profile'),
                        ),
                      ],
                    ),
                    const VerticalDivider(thickness: 1, width: 1),
                    Expanded(
                      child: SafeArea(child: pages[_selectedIndex]),
                    ),
                  ],
                ),
              );
            } else {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Course Explorer'),
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                body: SafeArea(child: pages[_selectedIndex]),
                bottomNavigationBar: NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.school_outlined),
                      selectedIcon: Icon(Icons.school),
                      label: 'Courses',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person),
                      label: 'Profile',
                    ),
                  ],
                ),
              );
            }
          },
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// 1. HOME PAGE
// -----------------------------------------------------------------------------
class HomePage extends StatelessWidget {
  final Map<String, dynamic> student;
  final List<dynamic> courses;

  const HomePage({super.key, required this.student, required this.courses});

  @override
  Widget build(BuildContext context) {
    final name = student['name'] as String? ?? studentName;
    final nim = student['nim'] as String? ?? studentId;

    final totalCourses = courses.length;
    final totalCredits = courses.fold<int>(
      0,
      (sum, course) => sum + (course['credits'] as int),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            color: Colors.indigo,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selamat Datang,',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'NIM: $nim',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Ringkasan Pembelajaran',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),

          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 400) {
                return Column(
                  children: [
                    SummaryCard(
                      icon: Icons.menu_book,
                      title: 'Courses',
                      value: '$totalCourses',
                    ),
                    const SizedBox(height: 12),
                    SummaryCard(
                      icon: Icons.school,
                      title: 'Total SKS',
                      value: '$totalCredits',
                    ),
                  ],
                );
              } else {
                return Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        icon: Icons.menu_book,
                        title: 'Courses',
                        value: '$totalCourses',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SummaryCard(
                        icon: Icons.school,
                        title: 'Total SKS',
                        value: '$totalCredits',
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 2. COURSES PAGE
// -----------------------------------------------------------------------------
class CoursesPage extends StatelessWidget {
  final Map<String, dynamic> student;
  final List<dynamic> courses;

  const CoursesPage({super.key, required this.student, required this.courses});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final isCompact = size.width < 600;

    final name = student['name'] as String? ?? studentName;
    final nim = student['nim'] as String? ?? studentId;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Daftar Mata Kuliah',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
          ),
          const SizedBox(height: 12),

          Card(
            color: Colors.indigo.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dimensi Layar: ${size.width.toStringAsFixed(0)} x ${size.height.toStringAsFixed(0)} px (${orientation.name})'),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isCompact ? Colors.orange : Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Layout: ${isCompact ? 'Compact (1 Kolom)' : 'Wide (2 Kolom)'}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (context, constraints) {
              int columns = constraints.maxWidth < 600 ? 1 : 2;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  mainAxisExtent: 105,
                ),
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final course = courses[index] as Map<String, dynamic>;

                  return CourseCard(
                    course: course,
                    studentName: name,
                    studentId: nim,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 3. PROFILE PAGE & FEEDBACK FORM
// -----------------------------------------------------------------------------
class ProfilePage extends StatelessWidget {
  final Map<String, dynamic> student;

  const ProfilePage({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final name = student['name'] as String? ?? studentName;
    final nim = student['nim'] as String? ?? studentId;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/images/profile.jpg'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'NIM: $nim',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                  ),
                  const Divider(height: 32),
                  const ListTile(
                    leading: Icon(Icons.school, color: Colors.indigo),
                    title: Text('Program Studi'),
                    subtitle: Text('Pendidikan Teknik Informatika'),
                  ),
                  const ListTile(
                    leading: Icon(Icons.apartment, color: Colors.indigo),
                    title: Text('Fakultas'),
                    subtitle: Text('Fakultas Teknik dan Kejuruan'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          FeedbackFormSection(
            studentName: name,
            studentId: nim,
          ),
        ],
      ),
    );
  }
}

class FeedbackFormSection extends StatefulWidget {
  final String studentName;
  final String studentId;

  const FeedbackFormSection({
    super.key,
    required this.studentName,
    required this.studentId,
  });

  @override
  State<FeedbackFormSection> createState() => _FeedbackFormSectionState();
}

class _FeedbackFormSectionState extends State<FeedbackFormSection> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _nimController;
  final TextEditingController _commentController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.studentName);
    _nimController = TextEditingController(text: widget.studentId);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Pengiriman'),
          content: Text(
            'Kirim feedback ini sebagai ${widget.studentName} (${widget.studentId})?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
              child: const Text('Kirim'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Feedback dari ${_nameController.text} berhasil disimpan!',
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );

    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Form Feedback & Masukan',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Mahasiswa',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _nimController,
                decoration: const InputDecoration(
                  labelText: 'NIM',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'NIM wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _commentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Komentar / Masukan',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.comment),
                  hintText: 'Tuliskan komentar Anda di sini...',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Komentar wajib diisi';
                  }
                  if (value.trim().length < 5) {
                    return 'Komentar minimal 5 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _isLoading ? null : _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.indigo,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send),
                          SizedBox(width: 8),
                          Text('Kirim Feedback'),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// REUSABLE WIDGETS
// -----------------------------------------------------------------------------
class SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const SummaryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 28, color: Colors.indigo),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(title),
          ],
        ),
      ),
    );
  }
}

class CourseCard extends StatefulWidget {
  final Map<String, dynamic> course;
  final String studentName;
  final String studentId;

  const CourseCard({
    super.key,
    required this.course,
    required this.studentName,
    required this.studentId,
  });

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  bool _isFavorite = false;

  IconData get statusIcon {
    final status = widget.course['status'] as String? ?? '';
    if (status == 'done') return Icons.check_circle;
    if (status == 'active') return Icons.play_circle;
    return Icons.schedule;
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.course['title'] as String? ?? '';
    final code = widget.course['code'] as String? ?? '';
    final credits = widget.course['credits'] as int? ?? 0;
    final category = widget.course['category'] as String? ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final result = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (context) => CourseDetailPage(
                  course: widget.course,
                  studentName: widget.studentName,
                  studentId: widget.studentId,
                ),
              ),
            );

            if (result == true && mounted) {
              setState(() {
                _isFavorite = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Mata kuliah "$title" ditandai Favorit!'),
                  backgroundColor: Colors.indigo,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          onLongPress: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(title),
                content: Text(
                  'Kode: $code\nSKS: $credits SKS\nKategori: $category\n\nIdentitas Mahasiswa:\n${widget.studentId} - ${widget.studentName}',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tutup'),
                  ),
                ],
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Icon(statusIcon, color: Colors.indigo),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6.0,
                        runSpacing: 2.0,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(code, style: const TextStyle(fontSize: 11)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('$credits SKS', style: const TextStyle(fontSize: 11)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isFavorite = !_isFavorite;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _isFavorite
                              ? '"$title" ditambahkan ke favorit!'
                              : '"$title" dihapus dari favorit.',
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// COURSE DETAIL PAGE
// -----------------------------------------------------------------------------
class CourseDetailPage extends StatelessWidget {
  final Map<String, dynamic> course;
  final String studentName;
  final String studentId;

  const CourseDetailPage({
    super.key,
    required this.course,
    required this.studentName,
    required this.studentId,
  });

  @override
  Widget build(BuildContext context) {
    final title = course['title'] as String? ?? '';
    final code = course['code'] as String? ?? '';
    final credits = course['credits'] as int? ?? 0;
    final category = course['category'] as String? ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.indigo.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.indigo),
                    const SizedBox(width: 8),
                    Text(
                      '$studentId - $studentName',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                    ),
                    const Divider(height: 24),
                    ListTile(
                      leading: const Icon(Icons.code),
                      title: const Text('Kode Mata Kuliah'),
                      subtitle: Text(code),
                    ),
                    ListTile(
                      leading: const Icon(Icons.credit_card),
                      title: const Text('Jumlah SKS'),
                      subtitle: Text('$credits SKS'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.category),
                      title: const Text('Kategori'),
                      subtitle: Text(category),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Kembali'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  label: const Text('Tandai Favorit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}