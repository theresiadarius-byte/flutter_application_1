import '../models/course.dart';


// Nama: Theresia Darius | NIM: 2415051116 | Kelas: PTI 5 A
abstract class CourseDataSource {
  Future<List<Course>> getCourses();
  Future<Course> createCourse(Course course);
  Future<void> updateCourse(int id, Course course);
  Future<void> deleteCourse(int id);
}
