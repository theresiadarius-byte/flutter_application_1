import 'package:flutter/material.dart';

class FeedbackForm extends StatefulWidget {
  final String name, nim;
  const FeedbackForm({super.key, required this.name, required this.nim});
  @override
  State<FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  final formKey = GlobalKey<FormState>();
  late final nameC = TextEditingController(text: widget.name);
  late final nimC = TextEditingController(text: widget.nim);
  final commentC = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    nameC.dispose();
    nimC.dispose();
    commentC.dispose();
    super.dispose();
  }

  String? _req(String? v, String label) =>
      (v == null || v.trim().isEmpty) ? '$label wajib diisi' : null;

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Pengiriman'),
        content: Text('Kirim feedback sebagai ${widget.name} (${widget.nim})?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true), child: const Text('Kirim')),
        ],
      ),
    );
    if (ok != true) return;
        setState(() => loading = true);
    await Future.delayed(const Duration(seconds: 2));
    // if (!mounted) return;   // sengaja dimatikan
    setState(() => loading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Feedback dari ${nameC.text} berhasil disimpan!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating));
    commentC.clear();
  }

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(children: [
              TextFormField(
                  controller: nameC,
                  decoration: const InputDecoration(
                      labelText: 'Nama Mahasiswa',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder()),
                  validator: (v) => _req(v, 'Nama')),
              const SizedBox(height: 12),
              TextFormField(
                  controller: nimC,
                  decoration: const InputDecoration(
                      labelText: 'NIM',
                      prefixIcon: Icon(Icons.badge),
                      border: OutlineInputBorder()),
                  validator: (v) => _req(v, 'NIM')),
              const SizedBox(height: 12),
              TextFormField(
                controller: commentC,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: 'Komentar',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.comment),
                    border: OutlineInputBorder()),
                validator: (v) =>
                    _req(v, 'Komentar') ??
                    (v!.trim().length < 5 ? 'Komentar minimal 5 karakter' : null),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: loading ? null : submit,
                  icon: loading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.send),
                  label: const Text('Kirim Feedback'),
                ),
              ),
            ]),
          ),
        ),
      );
}