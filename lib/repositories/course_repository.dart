import '../models/course.dart';
import '../services/course_api_service.dart';

// TAHAP 4: Repository kini memakai CourseApiService (bukan CourseService).
// Nama: Theresia Darius | NIM: 2415051116
class CourseRepository {
  final CourseApiService service;
  CourseRepository(this.service);

  Future<List<Course>> getCourses() {
    return service.getCourses();
  }
}