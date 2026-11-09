import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import 'main_shell.dart';
import 'package:provider/provider.dart';
import '../providers/course_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailC = TextEditingController();
  final _nameC = TextEditingController();
  final _passC = TextEditingController();
  final _confirmC = TextEditingController();
  String _role = 'seeker';
  bool _loading = false;

  @override
  void dispose() {
    _nameC.dispose();
    _emailC.dispose();
    _passC.dispose();
    _confirmC.dispose();
    super.dispose();
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  
Future<void> _register() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _loading = true);

  try {
    final res = await AuthService.instance.register(
      email: _emailC.text.trim(),
      password: _passC.text,
      name: _nameC.text.trim(),
      role: _role,
    );

    if (!mounted) return;

    context.read<CourseProvider>().loadCourses();

    if (res.session != null) {
      // Registrasi berhasil dan langsung login.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const MainShell(),
        ),
        (route) => false,
      );
    } else {
      // Pengguna harus melakukan konfirmasi email.
      _showMessage(
        'Registrasi berhasil. Silakan cek email Anda.',
      );
      Navigator.of(context).pop();
    }
  } on AuthException catch (e) {
    _showMessage(e.message);
  } catch (e) {
    _showMessage('Terjadi kesalahan: $e');
  } finally {
    if (mounted) {
      setState(() => _loading = false);
    }
  }
}


 
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Register')),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            // FIELD NAMA
            TextFormField(
              controller: _nameC,
              decoration: const InputDecoration(
                labelText: 'Nama',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty)
                      ? 'Nama wajib diisi'
                      : null,
            ),
            const SizedBox(height: 12),

            // PILIH ROLE
            DropdownButtonFormField<String>(
              value: _role,
              decoration: const InputDecoration(
                labelText: 'Daftar sebagai',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'seeker',
                  child: Text('Pencari Kos'),
                ),
                DropdownMenuItem(
                  value: 'owner',
                  child: Text('Pemilik Kos'),
                ),
              ],
              onChanged: (v) =>
                  setState(() => _role = v ?? 'seeker'),
            ),
            const SizedBox(height: 12),

            // FIELD EMAIL
            TextFormField(
              controller: _emailC,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Email wajib diisi';
                }
                if (!v.contains('@')) {
                  return 'Format email tidak valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // FIELD PASSWORD
            TextFormField(
              controller: _passC,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Password wajib diisi';
                }
                if (v.length < 6) {
                  return 'Minimal 6 karakter';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // KONFIRMASI PASSWORD
            TextFormField(
              controller: _confirmC,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Konfirmasi Password',
              ),
              validator: (v) =>
                  v != _passC.text
                      ? 'Password tidak sama'
                      : null,
            ),
            const SizedBox(height: 24),

            // TOMBOL REGISTER
            FilledButton(
              onPressed: _loading ? null : _register,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Register'),
            ),
          ],
        ),
      ),
    ),
  );
}
}