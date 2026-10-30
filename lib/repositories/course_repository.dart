import '../models/course.dart';
import '../services/course_data_source.dart';

// TAHAP 9: Repository bergantung pada kontrak CourseDataSource,
// bukan pada service konkret (REST/Supabase).
// Nama: Theresia Darius | NIM: 2415051116
class CourseRepository {
  CourseRepository(this.dataSource);

  final CourseDataSource dataSource;

  Future<List<Course>> getCourses() => dataSource.getCourses();

  Future<Course> createCourse(Course course) =>
      dataSource.createCourse(course);

  Future<void> updateCourse(int id, Course course) =>
      dataSource.updateCourse(id, course);

  Future<void> deleteCourse(int id) => dataSource.deleteCourse(id);
}
