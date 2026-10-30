import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/course.dart';
import 'course_data_source.dart';

// TAHAP 12-13: Data source Supabase (SELECT & INSERT). Update/Delete masih stub.
// Nama: Theresia Darius | NIM: 2415051116 | Kelas: PTI 5 A
class CourseSupabaseService implements CourseDataSource {
  final supabase = Supabase.instance.client;

  @override
  Future<List<Course>> getCourses() async {
    final data = await supabase.from('courses').select().order('id');
    return (data as List)
        .map((e) => Course.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // TAHAP 13: INSERT row baru, lalu kembalikan row hasil insert sebagai Course
  // (return type sama dengan versi REST, sehingga repository tidak berubah).
  @override
  Future<Course> createCourse(Course course) async {
    try {
      final row = await supabase
          .from('courses')
          .insert(course.toJson())
          .select()
          .single();
      return Course.fromJson(row);
    } on PostgrestException catch (e) {
      // Ubah error database menjadi pesan yang mudah dibaca di SnackBar.
      if (e.code == '23505') {
        throw Exception('Kode course sudah dipakai');
      }
      if (e.code == '23514') {
        throw Exception('Status harus planned, active, atau done');
      }
      if (e.code == '42501') {
        throw Exception('Tidak punya izin menambah data (cek policy RLS)');
      }
      throw Exception('Gagal menambah course: ${e.message}');
    }
  }

  @override
  Future<void> updateCourse(int id, Course course) =>
      throw UnimplementedError();

  @override
  Future<void> deleteCourse(int id) => throw UnimplementedError();
}