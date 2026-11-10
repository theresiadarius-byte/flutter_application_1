import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../widgets/role_guard.dart';
import 'kos_detail_page.dart';
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
    return FutureBuilder<UserProfile?>(
      future: _profileFuture,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final p = snap.data;
        if (snap.hasError || p == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('KosFinder'),
              actions: [
                IconButton(
                  tooltip: 'Logout',
                  icon: const Icon(Icons.logout),
                  onPressed: _logout,
                ),
              ],
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 8),
                    Text(
                      snap.hasError ? 'Error: ${snap.error}' : 'Gagal memuat profil',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadProfile,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('KosFinder (${p.role})'),
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
          // Menu yang tampil berbeda untuk tiap role
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            children: [
              // Info Identitas Pengguna
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: const Icon(Icons.person),
                ),
                title: Text(
                  p.name.isEmpty ? p.email : p.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${p.email} • ${p.role.toUpperCase()}'),
              ),
              const Divider(),

              // Fitur untuk SEMUA role: Daftar Kos
              ListTile(
                leading: const Icon(Icons.list_alt),
                title: const Text('Daftar Kos'),
                subtitle: const Text('Jelajahi pilihan kos yang tersedia'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Daftar kos dari database akan dibuat di Praktik 5')),
                  );
                },
              ),

              // Fitur Seeker: Contoh Lihat Detail Kos
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Detail Kos (Preview)'),
                subtitle: const Text('Pratinjau halaman detail kos'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const KosDetailPage(kosId: 'demo-sample-01'),
                    ),
                  );
                },
              ),

              // Fitur KHUSUS Owner dan Admin: My Kos
              if (p.isOwner || p.isAdmin) ...[
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.home_work),
                  title: const Text('My Kos'),
                  subtitle: const Text('Kelola properti kos milik Anda'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Halaman My Kos akan aktif di Praktik 5')),
                    );
                  },
                ),
              ],

              // Fitur KHUSUS Admin: Kelola Seluruh Data
              if (p.isAdmin) ...[
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings),
                  title: const Text('Kelola Data (Admin)'),
                  subtitle: const Text('Panel kontrol administratif data kos dan pengguna'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Akses panel administratif khusus Admin')),
                    );
                  },
                ),
              ],
            ],
          ),

          // Tombol "Tambah Kos" HANYA untuk role owner dan admin
          floatingActionButton: RoleGuard(
            role: p.role,
            allowed: const ['owner', 'admin'],
            child: FloatingActionButton.extended(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Form Tambah Kos akan dibuat di Praktik 5')),
                );
              },
              icon: const Icon(Icons.add_home),
              label: const Text('Tambah Kos'),
            ),
          ),
        );
      },
    );
  }
}
