import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;

import '../models/course.dart';

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
}