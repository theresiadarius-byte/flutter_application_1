import '../models/course.dart';
import '../services/course_service.dart';

// TAHAP 10: Repository sebagai abstraksi data
// Nama: Theresia Darius | NIM: 2415051116
class CourseRepository {
  final CourseService service;
  CourseRepository(this.service);

  Future<List<Course>> getCourses() {
    return service.loadCourses();
  }

  Future<Map<String, dynamic>> getStudent() {
    return service.loadStudent();
  }
}