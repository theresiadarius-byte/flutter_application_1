import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/course.dart';
import 'course_data_source.dart';

// TAHAP 12-15: Data source Supabase (SELECT, INSERT, UPDATE, DELETE).
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

  // TAHAP 14: UPDATE berdasarkan id. select() dipakai agar kita tahu berapa
  // row yang benar-benar berubah (RLS tanpa izin update = 0 row, tanpa error).
  @override
  Future<void> updateCourse(int id, Course course) async {
    try {
      final rows = await supabase
          .from('courses')
          .update(course.toJson())
          .eq('id', id)
          .select();
      if (rows.isEmpty) {
        throw Exception('Course tidak ditemukan atau tidak boleh diubah');
      }
    } on PostgrestException catch (e) {
      if (e.code == '23505') throw Exception('Kode course sudah dipakai');
      if (e.code == '23514') {
        throw Exception('Status harus planned, active, atau done');
      }
      throw Exception('Gagal memperbarui course: ${e.message}');
    }
  }

  // TAHAP 15: DELETE berdasarkan id. select() dipakai agar tahu apakah ada
  // row yang benar-benar terhapus (RLS tanpa izin delete = 0 row, tanpa error).
  @override
  Future<void> deleteCourse(int id) async {
    try {
      final rows =
          await supabase.from('courses').delete().eq('id', id).select();
      if (rows.isEmpty) {
        throw Exception('Course tidak ditemukan atau tidak boleh dihapus');
      }
    } on PostgrestException catch (e) {
      throw Exception('Gagal menghapus course: ${e.message}');
    }
  }
}