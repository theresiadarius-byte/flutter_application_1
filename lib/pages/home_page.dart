import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../security_test.dart';
import '../services/auth_service.dart';
import '../services/kos_service.dart';
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
  late Future<List<Map<String, dynamic>>> _kosFuture;
  final KosService _kosService = KosService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _profileFuture = ProfileService().getMyProfile();
      _kosFuture = _kosService.fetchAll();
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

  // Dialog formulir Tambah atau Edit Kos
  void _showKosForm({Map<String, dynamic>? kos}) {
    final isEdit = kos != null;
    final nameC = TextEditingController(text: isEdit ? kos['name'] : '');
    final addressC = TextEditingController(text: isEdit ? kos['address'] : '');
    final priceC =
        TextEditingController(text: isEdit ? kos['price'].toString() : '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'Edit Kos' : 'Tambah Kos Baru'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameC,
                  decoration: const InputDecoration(labelText: 'Nama Kos'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Nama kos wajib diisi'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: addressC,
                  decoration: const InputDecoration(labelText: 'Alamat Kos'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Alamat wajib diisi'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: priceC,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Harga per Bulan (Rp)',
                    prefixText: 'Rp ',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Harga wajib diisi';
                    }
                    if (int.tryParse(v.trim()) == null) {
                      return 'Harga harus berupa angka bulat';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final name = nameC.text.trim();
              final address = addressC.text.trim();
              final price = int.parse(priceC.text.trim());

              Navigator.of(ctx).pop();

              try {
                if (isEdit) {
                  final ok = await _kosService.update(
                    kos['id'],
                    {'name': name, 'address': address, 'price': price},
                  );
                  if (!mounted) return;
                  if (ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Kos berhasil diperbarui!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Gagal memperbarui: Ditolak oleh RLS.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  await _kosService.add(
                    name: name,
                    address: address,
                    price: price,
                  );
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Kos berhasil ditambahkan!')),
                  );
                }
                _loadData();
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Terjadi error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(isEdit ? 'Simpan' : 'Tambah'),
          ),
        ],
      ),
    );
  }

  // Dialog konfirmasi hapus kos
  void _confirmDelete(String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Kos'),
        content: Text('Yakin ingin menghapus "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final ok = await _kosService.delete(id);
              if (!mounted) return;
              if (ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Kos berhasil dihapus!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Gagal menghapus: Ditolak oleh RLS.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              _loadData();
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myId = Supabase.instance.client.auth.currentUser?.id;

    return FutureBuilder<UserProfile?>(
      future: _profileFuture,
      builder: (context, profileSnap) {
        if (profileSnap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final p = profileSnap.data;
        if (profileSnap.hasError || p == null) {
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Gagal memuat profil'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('KosFinder (${p.role})'),
            actions: [
              // TEMPORARY - hapus setelah pengujian (Praktik 6: Security Testing)
              IconButton(
                tooltip: 'Security Test (RLS)',
                icon: const Icon(Icons.security, color: Colors.amber),
                onPressed: () {
                  final idC = TextEditingController();
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Security Test (RLS)'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Masukkan ID Kos milik User A untuk diuji coba diubah/dihapus oleh akun saat ini:',
                            style: TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: idC,
                            decoration: const InputDecoration(
                              labelText: 'Kos ID Milik User A',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Batal'),
                        ),
                        FilledButton(
                          onPressed: () async {
                            String targetId = idC.text.trim();
                            // Jika kosong, otomatis gunakan ID kos pertama yang ada di database
                            if (targetId.isEmpty) {
                              final allKos = await _kosService.fetchAll();
                              if (allKos.isNotEmpty) {
                                targetId = allKos.first['id'].toString();
                              }
                            }
                            if (targetId.isEmpty) return;
                            Navigator.of(ctx).pop();

                            // Jalankan security test
                            final result = await securityTest(targetId);

                            if (!mounted) return;
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Hasil Security Testing'),
                                content: SingleChildScrollView(
                                  child: Text(
                                    result,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('Tutup'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Text('Jalankan Uji'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              // END TEMPORARY
              IconButton(
                tooltip: 'Refresh Data',
                icon: const Icon(Icons.refresh),
                onPressed: _loadData,
              ),
              IconButton(
                tooltip: 'Logout',
                icon: const Icon(Icons.logout),
                onPressed: _logout,
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async => _loadData(),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 80.0),
              children: [
                // Info Profil Pengguna
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          (p.name.isNotEmpty ? p.name[0] : p.email[0]).toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name.isEmpty ? p.email : p.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${p.email} • ${p.role.toUpperCase()}',
                              style: const TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Daftar Kos Tersedia',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Data Kos dari Supabase Database
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _kosFuture,
                  builder: (context, kosSnap) {
                    if (kosSnap.connectionState != ConnectionState.done) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (kosSnap.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Gagal memuat data kos: ${kosSnap.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    final items = kosSnap.data ?? [];
                    if (items.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.home_work_outlined, size: 60, color: Colors.grey),
                              SizedBox(height: 8),
                              Text(
                                'Belum ada data kos yang ditambahkan.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final kos = items[i];
                        // Tombol edit/hapus HANYA untuk Owner (pada kos miliknya) atau Admin
                        final canManage = (p.isOwner && kos['owner_id'] == myId) || p.isAdmin;

                        return ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.home),
                          ),
                          title: Text(
                            kos['name'] ?? 'Tanpa Nama',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${kos['address'] ?? "-"} • Rp ${kos['price'] ?? 0}/bln',
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    KosDetailPage(kosId: kos['id'].toString()),
                              ),
                            );
                          },
                          // Tombol Edit & Hapus TIDAK akan muncul untuk Seeker
                          trailing: canManage
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      tooltip: 'Edit Kos',
                                      onPressed: () => _showKosForm(kos: kos),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      tooltip: 'Hapus Kos',
                                      onPressed: () => _confirmDelete(
                                        kos['id'],
                                        kos['name'] ?? '',
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          // Tombol Tambah Kos HANYA muncul untuk Owner dan Admin
          floatingActionButton: RoleGuard(
            role: p.role,
            allowed: const ['owner', 'admin'],
            child: FloatingActionButton.extended(
              onPressed: () => _showKosForm(),
              icon: const Icon(Icons.add_home),
              label: const Text('Tambah Kos'),
            ),
          ),
        );
      },
    );
  }
}
