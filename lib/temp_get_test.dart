import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'constants.dart';
import 'models/course.dart';

// Nama: Theresia Darius
// NIM: 2415051116 | Kelas: PTI 5 A

const String apiUrl = 'https://jsonplaceholder.typicode.com/todos';

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
        _courses = data.take(3).toList();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tahap 3 - Model Dart'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _ambilData,
            tooltip: 'Muat ulang',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '$studentName | $studentId',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            if (_isLoading)
              const Text('Memuat data...', textAlign: TextAlign.center)
            else if (_error != null)
              Text('Request GET gagal.\n$_error', textAlign: TextAlign.center)
            else
              Text(
                'Request GET berhasil!\n'
                'Status: 200 OK\n'
                'Jumlah item: $_totalItems\n'
                'Menampilkan ${_courses.length} item pertama',
                textAlign: TextAlign.center,
              ),

            const SizedBox(height: 12),

            Expanded(child: _buildCourseList()),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return const Center(child: Text('Data tidak dapat ditampilkan.'));
    }

    if (_courses.isEmpty) {
      return const Center(child: Text('Belum ada data course.'));
    }

    return ListView.separated(
      itemCount: _courses.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final course = _courses[index];

        return Card(
          child: ListTile(
            leading: CircleAvatar(child: Text('${course.id ?? '-'}')),
            title: Text(course.title),
            subtitle: Text(
              'Kode: ${course.code}\n'
              'Status: ${course.status} | '
              'SKS: ${course.credits}',
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}
