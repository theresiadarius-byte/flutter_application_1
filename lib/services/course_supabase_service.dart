import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/course.dart';
import 'course_data_source.dart';

// TAHAP 12-17: Data source Supabase (CRUD) + error handling terpusat.
// Nama: Theresia Darius | NIM: 2415051116 | Kelas: PTI 5 A
class CourseSupabaseService implements CourseDataSource {
  final supabase = Supabase.instance.client;

  @override
  Future<List<Course>> getCourses() async {
    try {
      final data = await supabase.from('courses').select().order('id');
      return (data as List)
          .map((e) => Course.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _mapError(e);
    }
  }

  // TAHAP 13: INSERT, mengembalikan row baru sebagai Course.
  @override
  Future<Course> createCourse(Course course) async {
    try {
      final row = await supabase
          .from('courses')
          .insert(course.toJson())
          .select()
          .single();
      return Course.fromJson(row);
    } catch (e) {
      throw _mapError(e);
    }
  }

  // TAHAP 14: UPDATE berdasarkan id. select() agar 0 row (ditolak RLS) terdeteksi.
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
    } catch (e) {
      throw _mapError(e);
    }
  }

  // TAHAP 15: DELETE berdasarkan id. select() agar 0 row (ditolak RLS) terdeteksi.
  @override
  Future<void> deleteCourse(int id) async {
    try {
      final rows =
          await supabase.from('courses').delete().eq('id', id).select();
      if (rows.isEmpty) {
        throw Exception('Course tidak ditemukan atau tidak boleh dihapus');
      }
    } catch (e) {
      throw _mapError(e);
    }
  }

  // TAHAP 17: ubah error teknis menjadi pesan yang informatif untuk UI.
  // Detail teknis hanya dicetak ke console (debug), bukan ke pengguna.
  Exception _mapError(Object e) {
    // ignore: avoid_print
    print('CourseSupabaseService error: $e');

    if (e is PostgrestException) {
      switch (e.code) {
        case '23505':
          return Exception('Kode course sudah dipakai');
        case '23514':
          return Exception('Status harus planned, active, atau done');
        case '42501':
          return Exception('Akses ditolak oleh policy database (RLS)');
        case 'PGRST205':
        case '42P01':
          return Exception('Tabel courses tidak ditemukan di database');
        case '42703':
          return Exception('Kolom yang diminta tidak ada di tabel courses');
        default:
          return Exception('Kesalahan database: ${e.message}');
      }
    }

    final text = e.toString();
    if (text.contains('SocketException') ||
        text.contains('ClientException') ||
        text.contains('Failed host lookup') ||
        text.contains('TimeoutException')) {
      return Exception(
          'Tidak ada koneksi internet. Periksa jaringan lalu coba lagi.');
    }

    // Exception buatan sendiri (mis. 0 row terubah) diteruskan apa adanya.
    if (e is Exception) return e;
    return Exception('Terjadi kesalahan: $text');
  }
}