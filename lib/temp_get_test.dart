import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'constants.dart';
import 'models/course.dart';
import 'widgets/common.dart';

// Nama: Theresia Darius
// NIM: 2415051116 | Kelas: PTI 5 A

const String apiUrl = 'https://course-api-pearl.vercel.app/courses';

/// Mengambil data dari REST API dan mengubahnya menjadi List<Course>.
Future<List<Course>> fetchCourses() async {
  final response = await http.get(Uri.parse(apiUrl));

  debugPrint('Endpoint: $apiUrl');
  debugPrint('HTTP Status Code: ${response.statusCode}');

  if (response.statusCode != 200) {
    throw Exception('HTTP ${response.statusCode}');
  }

  final Object? decoded = jsonDecode(response.body);

  if (decoded is! List) {
    throw const FormatException('Response API bukan berupa JSON list.');
  }

  final List<Course> courses = decoded.map<Course>((item) {
    if (item is! Map<String, dynamic>) {
      throw const FormatException('Item JSON bukan berupa object yang valid.');
    }

    return Course.fromJson(item);
  }).toList();

  debugPrint('Jumlah item: ${courses.length}');

  if (courses.isNotEmpty) {
    debugPrint(
      'Data pertama: id=${courses.first.id}, '
      'data=${courses.first.toJson()}',
    );
  }

  return courses;
}

class GetTestPage extends StatefulWidget {
  const GetTestPage({super.key});

  @override
  State<GetTestPage> createState() => _GetTestPageState();
}

class _GetTestPageState extends State<GetTestPage> {
  bool _isLoading = true;
  String? _error;
  int _totalItems = 0;
  List<Course> _courses = [];
  final Set<String> _favorites = {};
  int _tab = 1; // 0 Home, 1 Courses, 2 Favorit, 3 Profile

  @override
  void initState() {
    super.initState();
    _ambilData();
  }

  Future<void> _ambilData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await fetchCourses();

      if (!mounted) return;

      setState(() {
        _totalItems = data.length;
        _courses = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error GET: $e');

      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _totalItems = 0;
        _courses = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tampilan meniru Course Explorer v2 (Pertemuan 6): AppBar indigo,
    // badge favorit, kartu course, dan NavigationBar.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Course Explorer v2', style: TextStyle(fontSize: 18)),
            Text(
              '$studentId - $studentName',
              style: TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _ambilData,
            tooltip: 'Muat ulang',
            icon: const Icon(Icons.refresh),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(Icons.favorite, size: 20, color: Colors.redAccent),
                const SizedBox(width: 4),
                Text(
                  '${_favorites.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.school_outlined),
              selectedIcon: Icon(Icons.school),
              label: 'Courses'),
          NavigationDestination(
              icon: Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite),
              label: 'Favorit'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_tab) {
      case 0:
        return _homeTab();
      case 2:
        return _favoritTab();
      case 3:
        return _profileTab();
      default:
        return _coursesTab();
    }
  }

  Widget _coursesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Daftar Mata Kuliah',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
        ),
        Text(_statusText()),
        const SizedBox(height: 12),
        ..._buildCourseList(),
      ],
    );
  }

  Widget _homeTab() {
    final totalSks = _courses.fold<int>(0, (sum, c) => sum + c.credits);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: Colors.indigo,
          child: const ListTile(
            contentPadding: EdgeInsets.all(20),
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text('Selamat Datang,',
                style: TextStyle(color: Colors.white70, fontSize: 14)),
            subtitle: Text('$studentName\nNIM: $studentId',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 16),
        const SectionTitle('Ringkasan Pembelajaran'),
        Row(
          children: [
            Expanded(
                child: SummaryCard(
                    Icons.menu_book, 'Courses', '${_courses.length}')),
            Expanded(
                child: SummaryCard(Icons.school, 'Total SKS', '$totalSks')),
            Expanded(
                child: SummaryCard(Icons.favorite, 'Favorit',
                    '${_favorites.length}',
                    color: Colors.red)),
          ],
        ),
      ],
    );
  }

  Widget _favoritTab() {
    final favs = _courses.where((c) => _favorites.contains(c.code)).toList();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Course Favorit',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
        ),
        const SizedBox(height: 12),
        if (favs.isEmpty)
          const Text('Belum ada favorit. Tekan ikon hati di tab Courses.')
        else
          for (final c in favs) _buildCourseCard(c),
      ],
    );
  }

  Widget _profileTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Card(
          child: ListTile(
            leading: Icon(Icons.person),
            title: Text(studentName),
            subtitle: Text('NIM: $studentId | Kelas: PTI 5 A'),
          ),
        ),
      ],
    );
  }

  String _statusText() {
    if (_isLoading) return 'Memuat data...';
    if (_error != null) return 'Request GET gagal: $_error';
    return 'GET 200 OK | $_totalItems course | ${_favorites.length} favorit | '
        '$studentId - $studentName';
  }

  List<Widget> _buildCourseList() {
    if (_isLoading) {
      return const [Center(child: CircularProgressIndicator())];
    }
    if (_error != null) {
      return const [Center(child: Text('Data tidak dapat ditampilkan.'))];
    }
    if (_courses.isEmpty) {
      return const [Center(child: Text('Belum ada data course.'))];
    }
    return [for (final c in _courses) _buildCourseCard(c)];
  }

  Widget _buildCourseCard(Course c) {
    final (label, color) = statusInfo(c.status);
    final fav = _favorites.contains(c.code);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(statusIcon(c.status), color: color),
        ),
        title: Text(
          c.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              Tag(c.code, Colors.indigo),
              Tag('${c.credits} SKS', Colors.deepOrange),
              Tag(label, color),
            ],
          ),
        ),
        trailing: IconButton(
          onPressed: () => setState(() {
            fav ? _favorites.remove(c.code) : _favorites.add(c.code);
          }),
          icon: favIcon(fav),
        ),
      ),
    );
  }
}