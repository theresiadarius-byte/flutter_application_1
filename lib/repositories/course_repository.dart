import '../models/course.dart';
import '../services/course_api_service.dart';

// TAHAP 4, 6, 7 & 8: Repository memakai CourseApiService.
// Nama: Theresia Darius | NIM: 2415051116
class CourseRepository {
  final CourseApiService service;
  CourseRepository(this.service);

  Future<List<Course>> getCourses() {
    return service.getCourses();
  }

  Future<Course> createCourse(Course course) {
    return service.createCourse(course);
  }

  Future<void> updateCourse(int id, Course course) {
    return service.updateCourse(id, course);
  }

  Future<void> deleteCourse(int id) {
    return service.deleteCourse(id);
  }
}