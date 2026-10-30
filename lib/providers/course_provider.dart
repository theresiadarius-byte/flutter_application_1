import 'package:flutter/foundation.dart';
import '../models/course.dart';
import '../repositories/course_repository.dart';

// Nama: Theresia Darius | NIM: 2415051116
class CourseProvider extends ChangeNotifier {
  final CourseRepository repository;
  CourseProvider(this.repository);

  // Data mahasiswa tidak lagi dibaca dari asset JSON. Halaman Home/Profile
  // otomatis memakai studentName & studentId dari constants.dart.
  final Map<String, dynamic> student = {};
  List<Course> courses = [];
  bool isLoading = false;
  bool isSaving = false; // TAHAP 6: mencegah submit ganda
  String? error;

  Future<void> loadCourses() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      courses = await repository.getCourses();
      debugPrint('CourseProvider memuat ${courses.length} course');
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// TAHAP 6: kirim course baru lalu refresh list (isi list diganti, bukan
  /// ditambah). Mengembalikan null jika sukses, atau pesan error jika gagal.
  Future<String?> createCourse(Course course) async {
    if (isSaving) return 'Penyimpanan sedang berjalan';
    isSaving = true;
    notifyListeners();
    try {
      await repository.createCourse(course);
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    } finally {
      isSaving = false;
      notifyListeners();
    }
    await loadCourses();
    return null;
  }

  /// TAHAP 7: perbarui course lalu refresh list. Mengembalikan null jika
  /// sukses, atau pesan error jika gagal. Favorites tetap aman karena
  /// memakai code (yang tidak berubah) sebagai kunci.
  Future<String?> updateCourse(int id, Course course) async {
    if (isSaving) return 'Penyimpanan sedang berjalan';
    isSaving = true;
    notifyListeners();
    try {
      await repository.updateCourse(id, course);
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    } finally {
      isSaving = false;
      notifyListeners();
    }
    await loadCourses();
    return null;
  }

  /// TAHAP 8: hapus course, bersihkan dari favorites (hindari data yatim),
  /// lalu refresh list. Mengembalikan null jika sukses, atau pesan error.
  Future<String?> deleteCourse(Course course) async {
    final id = course.id;
    if (id == null) return 'Course tidak memiliki ID';
    if (isSaving) return 'Proses sedang berjalan';
    isSaving = true;
    notifyListeners();
    try {
      await repository.deleteCourse(id);
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    } finally {
      isSaving = false;
      notifyListeners();
    }
    _favorites.remove(course.code);
    await loadCourses();
    return null;
  }

  final Set<String> _favorites = {};
  Set<String> get favorites => Set.unmodifiable(_favorites);
  int get favoriteCount => _favorites.length;
  bool isFavorite(String code) => _favorites.contains(code);

  void toggleFavorite(String code) {
    if (_favorites.contains(code)) {
      _favorites.remove(code);
    } else {
      _favorites.add(code);
    }
    notifyListeners();
  }
}