import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<UserProfile?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    setState(() {
      _profileFuture = ProfileService().getMyProfile();
    });
  }

  Future<void> _logout() async {
    await AuthService.instance.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('KosFinder'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _loadProfile,
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: FutureBuilder<UserProfile?>(
        future: _profileFuture,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          // Jika terjadi error koneksi / database, tampilkan pesan error detailnya
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 8),
                    Text(
                      'Error: ${snap.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _loadProfile,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Jika data null (belum ada baris profil di tabel profiles)
          if (snap.data == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person_off, size: 48, color: Colors.orange),
                    const SizedBox(height: 8),
                    const Text(
                      'Data profil belum ditemukan di tabel public.profiles.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Email: ${currentUser?.email ?? "-"}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _loadProfile,
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
              ),
            );
          }

          final p = snap.data!;
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: const Text('Nama Lengkap'),
                        subtitle: Text(
                          p.name.isEmpty ? '-' : p.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.email),
                        ),
                        title: const Text('Email'),
                        subtitle: Text(
                          p.email,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: p.isAdmin
                              ? Colors.red.shade100
                              : (p.isOwner
                                  ? Colors.orange.shade100
                                  : Colors.blue.shade100),
                          child: Icon(
                            Icons.badge,
                            color: p.isAdmin
                                ? Colors.red
                                : (p.isOwner ? Colors.orange : Colors.blue),
                          ),
                        ),
                        title: const Text('Role'),
                        subtitle: Text(
                          p.role.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: p.isAdmin
                                ? Colors.red
                                : (p.isOwner ? Colors.orange : Colors.blue),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
