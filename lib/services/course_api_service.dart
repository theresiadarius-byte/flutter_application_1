import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;

import '../models/course.dart';

// TAHAP 4, 6 & 7: Service Layer - seluruh komunikasi HTTP berada di sini.
// Nama: Theresia Darius | NIM: 2415051116 | Kelas: PTI 5 A
class CourseApiService {
  CourseApiService(this.baseUrl);

  final String baseUrl;

  /// GET {baseUrl}/courses -> List<Course>
  Future<List<Course>> getCourses() async {
    final uri = Uri.parse('$baseUrl/courses');
    final response = await http.get(uri);

    debugPrint('GET $uri -> ${response.statusCode}');

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil course (HTTP ${response.statusCode})');
    }

    final Object? decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const FormatException('Response API bukan berupa JSON list.');
    }

    return decoded
        .map((e) => Course.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Course> createCourse(Course course) async {
    final uri = Uri.parse('$baseUrl/courses');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(course.toJson()),
    );

    debugPrint('POST $uri -> ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Course.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw Exception('Gagal membuat course (HTTP ${response.statusCode})');
  }

  Future<void> updateCourse(int id, Course course) async {
    final uri = Uri.parse('$baseUrl/courses/$id');
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(course.toJson()),
    );

    debugPrint('PUT $uri -> ${response.statusCode}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Gagal memperbarui course (HTTP ${response.statusCode})');
    }
  }
}