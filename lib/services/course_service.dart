import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/course.dart';

// TAHAP 9: Service / Data Source
// Nama: Theresia Darius | NIM: 2415051116
class CourseService {
  Future<Map<String, dynamic>> _loadJson() async {
    final jsonString =
        await rootBundle.loadString('assets/data/student_data.json');
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> loadStudent() async {
    final data = await _loadJson();
    return data['student'] as Map<String, dynamic>;
  }

  Future<List<Course>> loadCourses() async {
    final data = await _loadJson();
    final list = data['courses'] as List<dynamic>;
    return list
        .map((e) => Course.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}