// Nama: Theresia Darius | NIM: 2415051116
class Course {
  final String code;
  final String title;
  final int credits;
  final String status;
  final String category;

  Course({
    required this.code,
    required this.title,
    required this.credits,
    required this.status,
    this.category = '',
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      code: json['code'] as String,
      title: json['title'] as String,
      credits: json['credits'] as int,
      status: json['status'] as String,
      category: json['category'] as String? ?? '',
    );
  }
}