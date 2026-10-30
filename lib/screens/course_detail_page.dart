import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import 'course_form_page.dart';
import '../widgets/common.dart';

// TAHAP 8: tombol Delete + dialog konfirmasi (DELETE)
// TAHAP 7: tombol Edit membuka form edit (PUT)
// TAHAP 13: status favorit tampil di halaman detail (state dari CourseProvider)
// Nama: Theresia Darius | NIM: 2415051116
class CourseDetailPage extends StatelessWidget {
  final Course course;
  const CourseDetailPage({super.key, required this.course});

  Future<void> _confirmDelete(BuildContext context) async {
    final provider = context.read<CourseProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final errorColor = Theme.of(context).colorScheme.error;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus course?'),
        content: Text('${course.code} - ${course.title} akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    final error = await provider.deleteCourse(course);

    // Wajib setelah dialog dan await sebelum memakai context.
    if (!context.mounted) return;

    if (error == null) {
      messenger.showSnackBar(
        SnackBar(content: Text('Course ${course.code} berhasil dihapus')),
      );
      Navigator.pop(context);
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(error), backgroundColor: errorColor),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFav = context.watch<CourseProvider>().isFavorite(course.code);
    final (label, color) = statusInfo(course.status);

    Widget row(IconData icon, String title, String value) => ListTile(
          leading: Icon(icon, color: Colors.indigo),
          title: Text(title,
              style: const TextStyle(fontSize: 13, color: Colors.grey)),
          subtitle: Text(value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Course'),
        actions: [
          IconButton(
            tooltip: 'Edit course',
            icon: const Icon(Icons.edit),
            onPressed: course.id == null
                ? null
                : () async {
                    final updated = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CourseFormPage(course: course),
                      ),
                    );
                    // Data detail dikirim lewat constructor (lama), jadi
                    // kembali ke list yang sudah di-refresh dari server.
                    if (updated == true && context.mounted) {
                      Navigator.pop(context);
                    }
                  },
          ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(course.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold, color: Colors.indigo)),
              const SizedBox(height: 8),
              Wrap(spacing: 6, children: [
                Tag(course.code, Colors.indigo),
                Tag(label, color),
                if (isFav) const Tag('Favorit', Colors.red),
              ]),
            ]),
          ),
        ),
        Card(
          child: Column(children: [
            row(Icons.code, 'Kode Mata Kuliah', course.code),
            row(Icons.credit_card, 'Jumlah SKS', '${course.credits} SKS'),
            row(Icons.category, 'Kategori', course.category),
          ]),
        ),
        const SizedBox(height: 8),
        const Text('$studentId - $studentName',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () =>
              context.read<CourseProvider>().toggleFavorite(course.code),
          icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
          label: Text(isFav ? 'Hapus dari Favorit' : 'Tandai Favorit'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: course.id == null ? null : () => _confirmDelete(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          icon: const Icon(Icons.delete),
          label: const Text('Hapus Course'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          label: const Text('Kembali'),
        ),
      ]),
    );
  }
}