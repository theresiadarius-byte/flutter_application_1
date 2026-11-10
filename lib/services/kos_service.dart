import 'package:supabase_flutter/supabase_flutter.dart';

class KosService {
  final SupabaseClient _client = Supabase.instance.client;

  String get _uid => _client.auth.currentUser!.id;

  // Mengambil seluruh data kos dari yang terbaru
  Future<List<Map<String, dynamic>>> fetchAll() async {
    final data = await _client
        .from('kos')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  // Mengambil satu data kos berdasarkan ID
  Future<Map<String, dynamic>?> getById(String id) async {
    final data =
        await _client.from('kos').select().eq('id', id).maybeSingle();
    return data;
  }

  // Menambahkan data kos baru (owner_id otomatis diisi dengan ID user login)
  Future<void> add({
    required String name,
    required String address,
    required int price,
  }) async {
    await _client.from('kos').insert({
      'owner_id': _uid,
      'name': name,
      'address': address,
      'price': price,
    });
  }

  /// Memperbarui data kos
  /// True = berhasil, False = ditolak RLS / data tidak ditemukan
  /// Catatan: Jika ditolak oleh RLS, Supabase tidak melempar error,
  /// melainkan tidak ada baris yang terpengaruh (rows.isEmpty).
  Future<bool> update(String id, Map<String, dynamic> values) async {
    final rows =
        await _client.from('kos').update(values).eq('id', id).select();
    return rows.isNotEmpty;
  }

  /// Menghapus data kos
  /// True = berhasil, False = ditolak RLS / data tidak ditemukan
  Future<bool> delete(String id) async {
    final rows = await _client.from('kos').delete().eq('id', id).select();
    return rows.isNotEmpty;
  }
}
