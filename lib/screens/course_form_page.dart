import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';

// TAHAP 6: Form tambah course (POST)
// Nama: Theresia Darius | NIM: 2415051116 | Kelas: PTI 5 A
class CourseFormPage extends StatefulWidget {
  const CourseFormPage({super.key});

  @override
  State<CourseFormPage> createState() => _CourseFormPageState();
}

class _CourseFormPageState extends State<CourseFormPage> {
  static const _statuses = ['planned', 'active', 'done'];

  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _creditsCtrl = TextEditingController();
  String _status = 'planned';

  @override
  void dispose() {
    _codeCtrl.dispose();
    _titleCtrl.dispose();
    _creditsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<CourseProvider>();
    if (provider.isSaving) return;

    final course = Course(
      code: _codeCtrl.text.trim(),
      title: _titleCtrl.text.trim(),
      credits: int.parse(_creditsCtrl.text.trim()),
      status: _status,
    );

    final error = await provider.createCourse(course);

    // Wajib setelah await sebelum memakai context.
    if (!context.mounted) return;

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Course ${course.code} berhasil ditambahkan')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.select<CourseProvider, bool>((p) => p.isSaving);

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tambah Course', style: TextStyle(fontSize: 18)),
            Text('$studentId - $studentName',
                style: TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _codeCtrl,
                  enabled: !isSaving,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Kode course',
                    hintText: 'contoh: MOB07',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final value = v?.trim() ?? '';
                    if (value.isEmpty) return 'Kode wajib diisi';
                    // code dipakai sebagai kunci favorites -> harus unik
                    final exists = context
                        .read<CourseProvider>()
                        .courses
                        .any((c) => c.code.toLowerCase() == value.toLowerCase());
                    if (exists) return 'Kode sudah dipakai';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleCtrl,
                  enabled: !isSaving,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Judul course',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Judul wajib diisi'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _creditsCtrl,
                  enabled: !isSaving,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Credits (SKS)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final n = int.tryParse(v?.trim() ?? '');
                    if (n == null) return 'Credits harus berupa angka';
                    if (n <= 0) return 'Credits harus lebih dari 0';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final s in _statuses)
                      DropdownMenuItem(value: s, child: Text(s)),
                  ],
                  onChanged:
                      isSaving ? null : (v) => setState(() => _status = v!),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  // null = tombol nonaktif selama request berjalan
                  onPressed: isSaving ? null : _submit,
                  icon: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(isSaving ? 'Menyimpan...' : 'Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}