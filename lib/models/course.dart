// Nama: Theresia Darius
// NIM: 2415051116 | Kelas: PTI 5 A

class Course {
  final int? id;
  final String code;
  final String title;
  final int credits;
  final String status;
  final String category;

  const Course({
    this.id,
    required this.code,
    required this.title,
    required this.credits,
    this.status = 'planned',
    this.category = '',
  });

  // Mengubah JSON menjadi objek Course.
  factory Course.fromJson(Map<String, dynamic> json) {
    // ID bersifat nullable sesuai worksheet.
    final rawId = json['id'];
    final int? parsedId = rawId is int
        ? rawId
        : int.tryParse(rawId?.toString() ?? '');

    // JSONPlaceholder /todos tidak memiliki field code.
    // Gunakan kode sementara berdasarkan ID.
    final rawCode = json['code'];
    final String parsedCode = rawCode is String && rawCode.trim().isNotEmpty
        ? rawCode
        : 'TODO${parsedId ?? ''}';

    final rawTitle = json['title'];
    final String parsedTitle = rawTitle is String ? rawTitle : 'Tanpa judul';

    // JSONPlaceholder /todos tidak memiliki field credits.
    final rawCredits = json['credits'];
    final int parsedCredits = rawCredits is int
        ? rawCredits
        : int.tryParse(rawCredits?.toString() ?? '') ?? 0;

    // Jika status tidak dikirim API, gunakan planned.
    final rawStatus = json['status'];
    final String parsedStatus =
        rawStatus is String && rawStatus.trim().isNotEmpty
        ? rawStatus
        : 'planned';

    final rawCategory = json['category'];
    final String parsedCategory = rawCategory is String ? rawCategory : '';

    return Course(
      id: parsedId,
      code: parsedCode,
      title: parsedTitle,
      credits: parsedCredits,
      status: parsedStatus,
      category: parsedCategory,
    );
  }

  // Mengubah objek Course menjadi Map JSON.
  Map<String, dynamic> toJson() {
    return {'code': code, 'title': title, 'credits': credits, 'status': status};
  }
}
