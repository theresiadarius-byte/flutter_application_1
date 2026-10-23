import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'constants.dart';

// Nama: Theresia Darius
// NIM: 2415051116 | Kelas: PTI 5 A

const String apiUrl = 'https://jsonplaceholder.typicode.com/todos';

Future<List<dynamic>> fetchCourses() async {
  final response = await http.get(Uri.parse(apiUrl));

  debugPrint('Endpoint: $apiUrl');
  debugPrint('HTTP Status Code: ${response.statusCode}');

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body) as List<dynamic>;

    debugPrint('Jumlah item: ${data.length}');

    if (data.isNotEmpty) {
      debugPrint('Data pertama: ${data.first}');
    }

    return data;
  }

  throw Exception('HTTP ${response.statusCode}');
}

class GetTestPage extends StatefulWidget {
  const GetTestPage({super.key});

  @override
  State<GetTestPage> createState() => _GetTestPageState();
}

class _GetTestPageState extends State<GetTestPage> {
  String _hasil = 'Memuat data dari REST API...';

  @override
  void initState() {
    super.initState();
    _ambilData();
  }

  Future<void> _ambilData() async {
    try {
      final data = await fetchCourses();

      if (!mounted) return;

      setState(() {
        _hasil =
            'Request GET berhasil!\n'
            'Status: 200 OK\n'
            'Jumlah item: ${data.length}\n'
            'Endpoint: /todos';
      });
    } catch (e) {
      debugPrint('Error GET: $e');

      if (!mounted) return;

      setState(() {
        _hasil = 'Request GET gagal.\n$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tahap 2 - HTTP GET')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '$studentName | $studentId',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Icon(Icons.cloud_download_outlined, size: 48),
              const SizedBox(height: 16),
              Text(_hasil, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
